# This looks through all the *.config files and replaces certain appsettings (See variables at bottom of script for the replacements)

function ReplaceInAllFiles($rootPath, $dictionary, $filter, $exclude)
{
    $Local:filePath = $null;
    $Local:file = $null;

    $Local:regexes = $dictionary.keys | foreach { [System.Text.RegularExpressions.Regex]::Escape($_) };
    $Local:regex = [regex]("(?i)(?<prefix><add\s+(key|name)="")(?<key>" + ($regexes -join '|') + ")(?<midfix>""\s+(value|connectionString)="")(?<value>[^""]{0,500})(?<postfix>""(\s+providerName=""[^""]+"")?\s*/>)");
    $Local:files = Get-ChildItem -Recurse -Filter $filter -Exclude $exclude $rootPath | foreach {$_.FullName};

    $Local:totalReplacements = 0;
    $Local:totalFilesChanged = 0;
    $Local:count = 0;

    function counterCallback($match)
    {
        $Private:key = $match.Groups["key"].ToString();
        $Private:value = $dictionary[$key];
        $Private:replacement = $match.Groups["prefix"].ToString() + $key + $match.Groups["midfix"].ToString() + $value + $match.Groups["postfix"].ToString();
        Write-Host "      $replacement";
        Set-Variable count ($count+1) -Scope 1
        Set-Variable totalReplacements ($totalReplacements+1) -Scope 1
        $replacement
    } 

    foreach ($filePath in $files)
    {
        $count = 0;
        $file = Get-Content -Raw $filePath ;
        $file = $regex.Replace($file, $function:counterCallback);

        if ($count -gt 0)
        {
            Write-Host "- $count - $filePath";
            [system.io.file]::WriteAllText($filePath, $file)
            [void]$totalFilesChanged++;
            Write-Host "";
        }
    }

    Write-Host "";
    Write-Host "$totalReplacements changes made to $totalFilesChanged files";
    Write-Host "";
    Write-Host "";
}


# All Projects
$all = @{
    # SMTP Email
    "SMTP_EnableSSL" = "true";
    "SMTP_Host"      = "";
    "SMTP_Password"  = "";
    "SMTP_Port"      = "";
    "SMTP_Username"  = "";
};

# AProject
$AProject = @{
    "connectionstring" = "Data Source=localhost;Initial Catalog=AProject; User Id=AProject; Password=AProject;";
};

ReplaceInAllFiles -rootPath "."           -dictionary $all        -filter "*.config"   -exclude "*.exe.config";
ReplaceInAllFiles -rootPath "./AProject"  -dictionary $AProject   -filter "*.config"   -exclude "*.exe.config";