function Smooth-GPX { 
    param (
        $file
    )

	$datetimeRegex = "(?<year>\d{4})\-(?<month>\d{2})\-(?<day>\d{2})T(?<hour>\d{2}):(?<minute>\d{2}):(?<second>\d{2})Z";

	Get-Content $file | ForEach-Object { 
		if ($_ -match $datetimeRegEx) {
			echo $_;
			break;
		}
	}

}