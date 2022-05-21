 
 #Set-ExecutionPolicy unrestricted


 #Specify final display
 $g_canvas_wd = 1000
 $g_canvas_ht = 1000
 $g_folder_name = "RESIZED" #this will be created in root folder


 Function Resize-Img
{

 <#*******************************************************************************
 Purpose: Resize image

 Reference: https://benoitpatra.com/2014/09/14/resize-image-and-preserve-ratio-with-powershell/

 Modifications
 Date			Author			Description						
 ---------------------------------------------------------
 2019-09-28     William Hu      modified parm / destination
 *******************************************************************************#>

Param ( [Parameter(Mandatory=$True)] [ValidateNotNull()] $imageSource,
[Parameter(Mandatory=$True)] [ValidateNotNull()] $imageTarget,
[Parameter(Mandatory=$true)][ValidateNotNull()] $quality,
[Parameter(Mandatory=$true)][ValidateNotNull()] $canvasWidth,
[Parameter(Mandatory=$true)][ValidateNotNull()] $canvasHeight
)
 
if (!(Test-Path $imageSource)){throw( "Cannot find the source image")}
if(!([System.IO.Path]::IsPathRooted($imageSource))){throw("please enter a full path for your source path")}
if(!([System.IO.Path]::IsPathRooted($imageTarget))){throw("please enter a full path for your target path")}
if ($quality -lt 0 -or $quality -gt 100){throw( "quality must be between 0 and 100.")}
 
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
$bmp = [System.Drawing.Image]::FromFile($imageSource)
 
#hardcoded canvas size... 370 x 208

#$canvasWidth = 370.0
#$canvasHeight = 208.0
 
#Encoder parameter for image quality
$myEncoder = [System.Drawing.Imaging.Encoder]::Quality
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($myEncoder, $quality)
# get codec
$myImageCodecInfo = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()|where {$_.MimeType -eq 'image/jpeg'}
 
#compute the final ratio to use
$ratioX = $canvasWidth / $bmp.Width;
$ratioY = $canvasHeight / $bmp.Height;
$ratio = $ratioY
if($ratioX -le $ratioY){
  $ratio = $ratioX
}
 
#create resized bitmap
$newWidth = [int] ($bmp.Width*$ratio)
$newHeight = [int] ($bmp.Height*$ratio)
$bmpResized = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
$graph = [System.Drawing.Graphics]::FromImage($bmpResized)
 
$graph.Clear([System.Drawing.Color]::White)
$graph.DrawImage($bmp,0,0 , $newWidth, $newHeight)
 
#save to file
$bmpResized.Save($imageTarget,$myImageCodecInfo, $($encoderParams))
$graph.Dispose()
$bmpResized.Dispose()
$bmp.Dispose()

}


 <#*******************************************************************************
 Purpose: Main

 Modifications
 Date			Author			Description						
 ---------------------------------------------------------
 2019-09-28     William Hu      Initial
 *******************************************************************************#>

write-host "process begin"


#creating customized output folder if not exist
#if dir already exist then on re-run delete all item before starting
 $current_path = Get-Location
 $output_dir = "$current_path\$g_folder_name\$g_canvas_wd x $g_canvas_ht\"
 if(!(Test-Path $output_dir))
 {  
    write-host "folder does not exists - creating dir"
    md -path $output_dir
 }
 else
 {
    write-host "folder exists - remove existing items"
    Get-ChildItem $output_dir | Remove-Item
 }


$dir = Get-ChildItem -Exclude R* #filter out the resize folder based on first char

foreach ($d in $dir)
{   

    $imgs = Get-ChildItem "$d"  -Include *.jpg , *.png -Recurse

    foreach ($img in $imgs)
    {    
        $sourceName = $img.FullName        
        $newName = $d.name.Substring(0,4) + $img.Name.Substring(0,$img.Name.Length - 4) + "_" + "$g_canvas_wd" + "x" + "$g_canvas_ht" +".jpg"
        Resize-Img $sourceName "$output_dir$newName" 100 $g_canvas_wd $g_canvas_ht
    }   
}

write-host "process completed"

