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
#region Params
param(
[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
[string]$fhemurl,
[string]$sourcepath,
[string]$destination
)
#endregion 
Write-Verbose $sourcepath
Write-Verbose $destination
Set-Location $PSScriptRoot

#exit

$FileHash = "LeftSideHash$(get-date -format "yyyyMMdd-HHmmss").txt"

if ($fhemurl -ne "leer") {.\fhemcl.ps1 $fhemurl "set Sicherung Copy_2_$destination"} else {Write-Verbose "set Sicherung Copy_2_$destination"}
$path=$destination + "\Scripts"
If (-not (test-path $path)) {New-Item -Path $path -ItemType Directory| Out-Null} 
$path=$destination + "\Sicherung"
If (-not (test-path $path)) {New-Item -Path $path -ItemType Directory| Out-Null}

# get only files from a certain date
# $sourcefiles = gci $sourcepath -File -Recurse |where {(get-date $_.CreationTime -f "dd/MM/yy") -eq "11.04.19"}
$sourcefiles = gci $sourcepath -File -Recurse |where {(get-date $_.CreationTime -f "dd/MM/yy") -eq (get-date -f "dd/MM/yy")}
$LeftSideHash = $sourcefiles | Get-FileHash | select @{Label="Path";Expression={$_.Path.Replace($sourcepath,"")}},Hash 
$LeftSideHash |Export-Clixml $destination\Scripts\$FileHash
if ($fhemurl -ne "leer") {.\fhemcl.ps1 $fhemurl "set Sicherung Hashfile_erzeugt"}else {Write-Verbose "set Sicherung Hashfile_erzeugt"}

# Dateien kopieren, da einzelne Files kopiert werden ist das mit den Pfaden etwas aufwendiger
foreach ($file in $sourcefiles)
{
    $newdir = $file.DirectoryName.Replace( $sourcepath, $($destination + "\Sicherung") )
    If (-not (test-path $newdir)) { md $newdir| Out-Null}
    Copy-Item -Path $file.FullName -Destination $newdir
    if ($fhemurl -ne "leer") {.\fhemcl.ps1 $fhemurl $("set Sicherung " + $file.fullname)}else {Write-Verbose $("set Sicherung " + $file.fullname)}
}

#Exportiere FileCollection nach XML
    
gci $destination\Scripts\LeftSideHash*.txt | Export-Clixml $destination\Scripts\Hashfiles.xml
gci $destination\Sicherung -r | Export-Clixml $destination\Scripts\Sicherung.xml

$SicherungStat = gci $destination\Sicherung -r | measure-object -Property length -sum

if ($fhemurl -ne "leer") {.\fhemcl.ps1 $fhemurl $("setreading Sicherung lastTransferCount " + $SicherungStat.count)}else {Write-Verbose $("setreading Sicherung lastTransferCount " + $SicherungStat.count)}
if ($fhemurl -ne "leer") {.\fhemcl.ps1 $fhemurl $("setreading Sicherung lastTransferSizeB " + $SicherungStat.sum)}else {Write-Verbose $("setreading Sicherung lastTransferSizeB " + $SicherungStat.sum)}
 
