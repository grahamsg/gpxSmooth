param (
    $inFile, $outFile
)

$datetimeRegex = "(?<date>\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:\d{2}Z)";
$activityStartTime;

# prompt the user for the start and end timespans


# for now I'll just set them
$removeStartOffset = New-TimeSpan -Minutes 5 -Seconds 27; # The first point that should be removed in days, hours, minutes, seconds after $activityStartTime
$removeEndOffset   = New-TimeSpan -Minutes 5 -Seconds 49; # The first point that should be kept in days, hours, minutes, seconds after $activityStartTime
$inRemove = "before"; # Status flag with values "before", "remove", and "after"



Get-Content $inFile | ForEach-Object { 
    $curLine = $_;
	if ((-not $activityStartTime) -and $curLine -match $datetimeRegEx) {
		$activityStartTime = Get-Date $matches['date'];
		"The activity started at $activityStartTime";
        $removeStartAbsolute = $activityStartTime.Add($removeStartOffset);
        $removeEndAbsolute   = $activityStartTime.Add($removeEndOffset);
        "Will remove $removeStartAbsolute through $removeEndAbsolute";
	}
    switch ($inRemove) {
        "before" {
            if (($curLine -match $datetimeRegEx) -and (((Get-Date $matches['date']) -ge $removeStartAbsolute))) {
                "{$curLine}: I was in the before time, now moving to remove time";
                $inRemove = "remove";
            }
            else {
                $curLine | Out-File -FilePath $outFile -Append;
            }
        }
        "remove" {
            if (($curLine -match $datetimeRegEx) -and (((Get-Date $matches['date']) -ge $removeEndAbsolute))) {
                "{$curLine}: I was in the remove time, now moving to the after time";
                $inRemove = "after";
                $curLine | Out-File -FilePath $outFile -Append;
            }
        }
        "after"  {
            $curLine | Out-File -FilePath $outFile -Append;
        }
    }
}
