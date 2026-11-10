using Npgsql;

public sealed class MigrationRunner(NpgsqlConnection connection, string directory)
{
    public async Task RunAsync(bool apply)
    {
        if (!Directory.Exists(directory))
            throw new DirectoryNotFoundException($"Migration folder not found: {directory}");
        var files = Directory.GetFiles(directory, "*.sql")
            .OrderBy(Path.GetFileName, StringComparer.Ordinal).ToArray();

        // Serialize migration runners using a transaction-scoped database lock.
        await using var transaction = await connection.BeginTransactionAsync();
        if (apply)
        {
            await using var setup = new NpgsqlCommand("""
                CREATE TABLE IF NOT EXISTS public.schema_migrations (
                    version text PRIMARY KEY,
                    applied_at timestamptz NOT NULL DEFAULT now()
                );
                """, connection, transaction);
            await setup.ExecuteNonQueryAsync();
        }

        var applied = new HashSet<string>(StringComparer.Ordinal);
        await using var exists = new NpgsqlCommand(
            "SELECT to_regclass('public.schema_migrations') IS NOT NULL", connection, transaction);
        if (await exists.ExecuteScalarAsync() is true)
        {
            await using var history = new NpgsqlCommand("SELECT version FROM public.schema_migrations",
            connection, transaction);
            await using var reader = await history.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                applied.Add(reader.GetString(0));
        }

        var count = 0;
        foreach (var file in files)
        {
            var version = Path.GetFileNameWithoutExtension(file);
            if (!apply)
            {
                Console.WriteLine($"{(applied.Contains(version) ? "Applied" : "Pending")}  {version}");
                continue;
            }
            if (applied.Contains(version))
                continue;

            Console.WriteLine($"Applying {version}...");
            var sql = await File.ReadAllTextAsync(file);
            if (string.IsNullOrWhiteSpace(sql))
                throw new InvalidOperationException($"Migration {version} is empty.");
            await using var migration = new NpgsqlCommand(sql, connection, transaction);
            await migration.ExecuteNonQueryAsync();
            await using var record = new NpgsqlCommand(
                "INSERT INTO public.schema_migrations (version) VALUES ($1)", connection, transaction);
            record.Parameters.AddWithValue(version);
            await record.ExecuteNonQueryAsync();
            count++;
        }
        await transaction.CommitAsync();
        if (apply)
            Console.WriteLine(count == 0 ? "Database is up to date." : $"Applied {count} migration(s).");
        else if (files.Length == 0)
            Console.WriteLine("No migration files found.");
    }
}
