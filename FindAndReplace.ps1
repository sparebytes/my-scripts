# This looks through all the files and replaces values

function ReplaceInAllFiles($rootPath, $dictionary, $filter)
{
    $Local:filePath = $null;
    $Local:file = $null;

    $Local:regexes = $dictionary.keys | foreach {[System.Text.RegularExpressions.Regex]::Escape($_)};
    $Local:regex = [regex]("(?i)" + ($regexes -join '|'));
    $Local:files = Get-ChildItem -Recurse -Filter $filter $rootPath | foreach {$_.FullName};

    $Local:totalReplacements = 0;
    $Local:totalFilesChanged = 0;
    $Local:count = 0;

    function counterCallback($match)
    {
        $private:replacement = $dictionary[$match.Value];
        Write-Host "      $replacement  <-  $match";
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

$r = @{
    "dog" = "cat";
    "left" = "right";
    "up" = "down";
    "white" = "black";
}

ReplaceInAllFiles -rootPath "." -dictionary $r -filter "*.txt" -exclude "*.txt.bak";
