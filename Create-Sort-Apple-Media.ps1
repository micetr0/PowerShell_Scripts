                                  #Main()
 <#*******************************************************************************
 Purpose: Create new dir by copying media in root dir to newly created year/month folders 
 for photo downloaded off iCloud

 Assumption: keep all different media format together, sort by time only

 Modifications
 Date           Author          Description                     
 -------------------------------------------------------------------------------
 14-NOV-2021   William Hu      Initial 
 *******************************************************************************#>


write-host "MAIN: begin"
$beginTime = (Get-Date).DateTime
$outputDir = "output"
$list = Get-ChildItem | Select-Object lastwriteTIme
$years = @()

foreach($file in $list)
{
    #write-host $l
    $years += $file.LastWriteTime.Year
}

$uniqueYears = $years | select -Unique
#write-host $uniqueYears

mkdir -name $outputDir
cd $outputDir

foreach ($uniqueYear in $uniqueYears)
{
    mkdir -name $uniqueYear

    #iteration thru the months
    for($month=1; $month -le 12; $month++)
    {        
        $medias = Get-childItem -Path $PSScriptRoot | where-object { $_.lastwritetime.month -eq $month -AND $_.lastwritetime.year -eq $uniqueYear -and $_.Extension -notlike "*.ps1" } | 
        where {!$_.PSisContainer}

        if ($medias.count -gt 0)
        {
            cd $uniqueYear
            mkdir -name $month

            foreach ($media in $medias)
            {
                #write-host $media.FullName
                Copy-Item -path $media.FullName -Destination "$PSScriptRoot\$outputdir\$uniqueYear\$month\$media"
            }

            cd..
        }
    }
}
cd..

#Run-Stats
$endTime = (get-Date).DateTime
$totalTime = New-TimeSpan -Start $beginTime -End $endTime
write-host "MAIN: total run time: $totalTime"
write-host "MAIN: end"













