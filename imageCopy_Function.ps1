#Simple PS script to move all target string into designated directory"

#dialogue
$monthFrom = read-host 'Enter the month FROM which image will be read'
$dateFrom  = read-host 'Enter the day FROM which the image will be read'
$monthTo   = read-host 'Enter the month TO which the image will be read'
$dateTo    = read-host 'Enter the day TO which the image will be read'

function imageCopy()
{
    #validation tag included for inputs
    Param
    (
        [ValidateRange(1,12)]
        [Int]
        $monthFrom,

        [ValidateRange(1,30)]
        [Int]
        $dateFrom,

        [ValidateRange(1,12)]
        [Int]
        $monthTo,

        [ValidateRange(1,30)]
        [Int]
        $dateTo
    )

    #directory set
    $dir = Get-Location
    $dirOut = "$dir\mod"

    #iterate from 18-31
    For ($i=$monthFrom; $i -lt $monthTo; $i++)
    {
        write-host "moonth is $i"
        For ($j=$dateFrom; $j -lt $dateTo; $j++)
        {
            write-host "day is $j"

            #do a check through the directory list - if match regex then put the name of the file into the array
            $matchedList = @()
            $matchedList = Get-ChildItem $dir | Where-Object {$_.Name -imatch "IMG_20170$i+$j"}

            foreach ($matchedItem in $matchedList)
            {
                #if directory does not exist - create
                if(!(Test-Path -path $dirOut\$i)) 
                {
                    New-Item $dirOut\$i -Type Directory
                } 
                #copy to destination  
                $copyCounter = 0 
                Copy-Item $dir\$matchedItem -Destination $dirOut\$i\ -Recurse -Force
                $copyCounter++
            } #foreach     
        } #for j
    } #for i
} #function end    


write-host " outside of function - operation completed :) "