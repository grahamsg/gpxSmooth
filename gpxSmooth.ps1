param (
    $inFile, $outFile
)

if (-not $outFile) {
    $outFile = New-Item (".\" + $inFile.Substring(0, $inFile.Length - 4) + "_edit" + ".gpx") -Type file;
}

$datetimeRegex = "(?<date>\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:\d{2}Z)";
$offsetRegex   = "(?<days>\d*?):?(?<hours>\d+):(?<minutes>\d+):(?<seconds>\d+)";
$activityStartTime;

$inRemove = "before"; # Status flag with values "before", "remove", and "after"

# prompt the user for the start and end timespans

# days are optional, hours and minutes can be 0. All values can be greater than 60 (could have 754 seconds)
$removeStartOffset = Read-Host -Prompt "Enter the offset time of the last point that should be kept (d:hh:mm:ss)";
$removeEndOffset   = Read-Host -Prompt "Enter the offset time of the last point that should be removed (d:hh:mm:ss)";

$removeStartOffset -Match $offsetRegex | Out-Null;
$removeStartOffset = New-TimeSpan -Days $Matches['days'] -Hours $Matches['hours'] -Minutes $Matches['minutes'] -Seconds $Matches['seconds'];
$removeEndOffset   -Match $offsetRegex | Out-Null;
$removeEndOffset   = New-TimeSpan -Days $Matches['days'] -Hours $Matches['hours'] -Minutes $Matches['minutes'] -Seconds $Matches['seconds'];

Get-Content $inFile | ForEach-Object { 
    $curLine = $_;
	if ((-not $activityStartTime) -and $curLine -match $datetimeRegEx) {
		$activityStartTime = Get-Date $matches['date'];
        $removeStartAbsolute = $activityStartTime.Add($removeStartOffset);
        $removeEndAbsolute   = $activityStartTime.Add($removeEndOffset);
	}
    
    switch ($inRemove) {
        "after"  {
            $curLine | Out-File -FilePath $outFile -Append;
        }
        "remove" {
            if (($curLine -match $datetimeRegEx) -and (((Get-Date $matches['date']) -ge $removeEndAbsolute))) {
                $inRemove = "after";
            }
        }
        "before" {
            if (($curLine -match $datetimeRegEx) -and (((Get-Date $matches['date']) -ge $removeStartAbsolute))) {
                $inRemove = "remove";
                $curLine | Out-File -FilePath $outFile -Append;
            }
            else {
                $curLine | Out-File -FilePath $outFile -Append;
            }
        }
    }
}


# here-string with the last few lines of a .gpx file.
$fileEnding = @'
   </trkpt>
  </trkseg>
 </trk>
</gpx>
'@;

if ($inRemove -eq "remove") { # if the last point in the file was deleted, add the closing tags back in
    $fileEnding | Out-File -FilePath $outFile -Append;
}
