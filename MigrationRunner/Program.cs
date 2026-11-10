using Npgsql;
using Npgsql.Replication;

var command = args.FirstOrDefault()?.ToLowerInvariant() ?? "help";

if(command == "help")
{
    Console.WriteLine("dotnet run - help|migrate|status|test");
    return 0;
}
if(command != "help" && command != "connect" && command != "migrate" && command != "test" && command != "status")
{
    Console.WriteLine("UNKNOWN COMMAND \t PLEASE RUN dotnet run - help|connect|migrate|status|test");
    return 1;
}

EnvReader.LoadConnectionString("../.env");
var connectionString = Environment.GetEnvironmentVariable("DefaultConnection");
if(string.IsNullOrWhiteSpace(connectionString)){ Console.WriteLine("CONNECTION STRING INVALID"); return 1;}
var scriptDirectory = Environment.GetEnvironmentVariable("ScriptsDirectory");
if(string.IsNullOrWhiteSpace(scriptDirectory)){Console.WriteLine("SCRIPTS DIRECTORY IS INVALID"); return 1;}

try
{
    await using var conn = new NpgsqlConnection(connectionString);
    await conn.OpenAsync();
    if (command == "test") Console.WriteLine("Connection Successful!");
    else
    {
        var runner = new MigrationRunner(conn, scriptDirectory);
        await runner.RunAsync(command == "migrate");
    }
} 
catch (Exception ex)
{
    Console.WriteLine($"Connection Failed: {ex.Message}");
    return 1;
}

return 0;
