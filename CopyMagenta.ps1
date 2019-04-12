<#
.SYNOPSIS
    This Script copy Files from today to a folder wich is later syncronized the Cloud Transfer path
.DESCRIPTION
    The Script copy the Files from today, build hash Files for the copy over the Cloud process
.EXAMPLE
    CopyMagenta # No Arguments
.NOTES
    This Script needs two external Scripts
    .\fhemcl.ps1
#>
Set-Location $PSScriptRoot

$FileHash = "LeftSideHash$(get-date -format "yyyyMMdd-HHmmss").txt"
$sourcepath = "D:\Transfer"
$destination = "D:\Magenta"
$fhemurl = "http://192.168.178.104:8083"

.\fhemcl.ps1 $fhemurl "set Sicherung Copy_2_$destination" 

If (-not (test-path $destination\Scripts)) { md $destination\Scripts}
If (-not (test-path $destination\Sicherung)) { md $destination\Sicherung}

# get only files from a certain date
# $sourcefiles = gci $sourcepath -File -Recurse |where {(get-date $_.CreationTime -f "dd/MM/yy") -eq "11.04.19"}
$sourcefiles = gci $sourcepath -File -Recurse |where {(get-date $_.CreationTime -f "dd/MM/yy") -eq (get-date -f "dd/MM/yy")}
$LeftSideHash = $sourcefiles | Get-FileHash | select @{Label="Path";Expression={$_.Path.Replace($sourcepath,"")}},Hash 
$LeftSideHash |Export-Clixml $destination\Scripts\$FileHash
.\fhemcl.ps1 $fhemurl "set Sicherung Hashfile_erzeugt"


# Dateien kopieren, da einzelne Files kopiert werden ist das mit den Pfaden etwas aufwendiger
foreach ($file in $sourcefiles)
{
    $newdir = $file.DirectoryName.Replace( $sourcepath, $($destination + "\Sicherung") )
    If (-not (test-path $newdir)) { md $newdir}
    Copy-Item -Path $file.FullName -Destination $newdir
    .\fhemcl.ps1 $fhemurl $("set Sicherung " + $file.fullname)
}

#Exportiere FileCollection nach XML
    
gci $destination\Scripts\LeftSideHash*.txt | Export-Clixml $destination\Scripts\Hashfiles.xml
gci $destination\Sicherung -r | Export-Clixml $destination\Scripts\Sicherung.xml

$SicherungStat = gci $destination\Sicherung -r | measure-object -Property length -sum

.\fhemcl.ps1 $fhemurl $("setreading Sicherung lastTransferCount " + $SicherungStat.count)
.\fhemcl.ps1 $fhemurl $("setreading Sicherung lastTransferSizeB " + $SicherungStat.sum)
 
