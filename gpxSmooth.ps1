param (
    $inFile, $outFile
)

$datetimeRegex = "(?<year>\d{4})\-(?<month>\d{2})\-(?<day>\d{2})T(?<hour>\d{2}):(?<minute>\d{2}):(?<second>\d{2})Z";
$activityStartTime;
$removeStartOffset;
$removeEndOffset;

Get-Content $inFile | ForEach-Object { 
	if ($_ -match $datetimeRegEx) {
		echo $_;
		break;
	}
}
