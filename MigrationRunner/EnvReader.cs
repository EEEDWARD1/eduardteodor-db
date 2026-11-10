using System;
using System.IO;

class EnvReader
{
    public static void LoadConnectionString(string filePath)
    {
        if (!File.Exists(filePath))
            throw new FileNotFoundException($"The file '{filePath}' does not exist.");

        string prefix1 = "DEFAULT_CONNECTION=";
        string prefix2 = "SCRIPTS=";

        foreach(var lines in File.ReadAllLines(filePath))
        {
            if(lines.StartsWith(prefix1))
            {
                Environment.SetEnvironmentVariable("DefaultConnection", lines.Substring(prefix1.Length));
            }
            if(lines.StartsWith(prefix2))
            {
                Environment.SetEnvironmentVariable("ScriptsDirectory", lines.Substring(prefix2.Length));
            }
        }
    }
}