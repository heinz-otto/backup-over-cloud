<#
.SYNOPSIS
    This Script copy Files from today to a folder wich is later syncronized the Cloud Transfer path
.DESCRIPTION
    copy the Files from today, build hash Files for the copy over the Cloud process and logs to the FHEM Server
.EXAMPLE
    CopyMagenta -fhemurl "http://s1:8083" -sourcepath "d:\Transfer" -destination "d:\Magenta"
    CopyMagenta -fhemurl "http://s1:8083" -sourcepath "d:\Transfer" -destination "d:\Magenta" -verbose
.NOTES
    This Script needs external Scripts
    .\fhemcl.ps1
#>
#region Params
param(
[Parameter(Mandatory = $true)]
[ValidateScript({$uri = $_ -as [System.URI];$uri.AbsoluteURI -ne $null -and $uri.Scheme -match '[http|https]'})]$fhemurl,
[Parameter(Mandatory = $true)][ValidateScript({Test-Path $_ -PathType ‘Container’})]$sourcepath,
[Parameter(Mandatory = $true)][ValidateScript({Test-Path $_ -PathType ‘Container’})]$destination
)
#endregion 
Set-Location $PSScriptRoot
$verbose = $PSCmdlet.MyInvocation.BoundParameters["Verbose"] 
Write-Verbose "$sourcepath $destination"

$FileHash = "LeftSideHash$(get-date -format "yyyyMMdd-HHmmss").txt"

if (!$verbose) {.\fhemcl.ps1 $fhemurl "set Sicherung Copy_2_$destination"}
Write-Verbose "Copy 2 $destination"
$path=$destination + "\Scripts"
If (-not (test-path $path)) {New-Item -Path $path -ItemType Directory| Out-Null} 
$path=$destination + "\Sicherung"
If (-not (test-path $path)) {New-Item -Path $path -ItemType Directory| Out-Null}

# temp export Variable 
get-item $path | Export-Clixml $destination\Scripts\destination.xml

# get only files from a certain date
# $sourcefiles = gci $sourcepath -File -Recurse |where {(get-date $_.CreationTime -f "dd/MM/yy") -eq "11.04.19"}
# get only files from today
$sourcefiles = gci $sourcepath -File -Recurse |where {(get-date $_.CreationTime -f "dd/MM/yy") -eq (get-date -f "dd/MM/yy")}
$LeftSideHash = $sourcefiles | Get-FileHash | select @{Label="Path";Expression={$_.Path.Replace($sourcepath,"")}},Hash 
$LeftSideHash |Export-Clixml $destination\Scripts\$FileHash
if (!$verbose) {.\fhemcl.ps1 $fhemurl "set Sicherung Hashfile_erzeugt"}
Write-Verbose "Hashfile_erzeugt"

# Dateien kopieren, da einzelne Files kopiert werden ist das mit den Pfaden etwas aufwendiger
foreach ($file in $sourcefiles)
{
    $newdir = $file.DirectoryName.Replace( $sourcepath, $($destination + "\Sicherung") )
    If (-not (test-path $newdir)) { md $newdir| Out-Null}
    Copy-Item -Path $file.FullName -Destination $newdir
    $cmd1 = $("set Sicherung " + $file.fullname)
    if (!$verbose) {.\fhemcl.ps1 $fhemurl $cmd1}
    Write-Verbose $("copy " + $file.fullname)
}

#Exportiere FileCollection nach XML
gci $destination\Scripts\LeftSideHash*.txt | Export-Clixml $destination\Scripts\Hashfiles.xml
gci $destination\Sicherung -r | Export-Clixml $destination\Scripts\Sicherung.xml
gci $destination\Sicherung -r | where {$_.attributes -notmatch "Directory"} |%{$_.FullName.Replace($($destination + "\Sicherung"),"")}|Export-Clixml $destination\Scripts\FilenamesRel.xml

$SicherungStat = gci $destination\Sicherung -r | measure-object -Property length -sum
$cmd1 = $("setreading Sicherung lastTransferCount " + $SicherungStat.count)
$cmd2 = $("setreading Sicherung lastTransferSizeB " + $SicherungStat.sum)
if (!$verbose) {.\fhemcl.ps1 $fhemurl $cmd1 $cmd2}
Write-Verbose "$("lastTransferCount " + $SicherungStat.count) $("lastTransferSizeB " + $SicherungStat.sum)"
 
