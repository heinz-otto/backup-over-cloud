<#
.SYNOPSIS
    This Script ist the Archiv Server Part for transferring Backup over Cloud
.DESCRIPTION
    The Script start synchronizing Folder from Cloud externally, compares than the content of  Folders with Hash Tables and move the files to the archiv
.EXAMPLE
    FolderSyncAblauf -fhemurl "http://s1:8083" -MagentaFolderLocal "D:\Magenta" -DestFolder "D:\Test\SicherungNeu" -verbose
.NOTES
    This Script needs two external Scripts
    .\fhemcl.ps1
    .\FolderCompare.ps1
#>
#region Params
param(
[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
[string]$fhemurl,
[string]$MagentaFolderLocal,
[string]$DestFolder
)
#endregion 

Set-Location $PSScriptRoot
$verbose = $PSCmdlet.MyInvocation.BoundParameters["Verbose"] 

#$fhemurl = "http://192.168.100.119:8083"
#$MagentaFolderLocal = "D:\MagentaCLOUD"
#$DestFolder = "S:\SicherungNeu"
#$OrgFolder = "Z:\Sicherung"
$SourceFolder = $MagentaFolderLocal + "\Sicherung"

# Set Status Server started
if (!$verbose) {.\fhemcl.ps1 $fhemurl "set Sicherung gestartet"}

# Wait that the linux station has synced the drives, verbose -> no wait 
# while(!$(.\fhemcl.ps1 $fhemurl "list Sicherung state").Item(1).contains("SyncEnde")) {sleep (5)}
if (!$verbose) {while(!$(.\fhemcl.ps1 $fhemurl "list Sicherung state").contains("SyncEnde")) {sleep (5)}}

# compare Files with on behalf of also transfered hashes
$Return = .\FolderCompare.ps1 -LeftHashFile ($MagentaFolderLocal + "\Scripts\LeftsideHash*.txt") -RightDir ($MagentaFolderLocal + "\Sicherung")

if ($Return -ne "nothing") {
    $SicherungStat = get-childitem -r $SourceFolder | Measure-Object -Property length -sum 
    if (!$verbose) {.\fhemcl.ps1 $fhemurl $("setreading Sicherung lastTransferCount " + $SicherungStat.count)}
    if (!$verbose) {.\fhemcl.ps1 $fhemurl $("setreading Sicherung lastTransferSizeB " + $SicherungStat.sum)}
    Write-Verbose "$("lastTransferCount " + $SicherungStat.count) $("lastTransferSizeB " + $SicherungStat.sum)"
  }

if ($Return -eq 0) {
    if (!$verbose) {.\fhemcl.ps1 $fhemurl "set Sicherung geprueft"}
    write-verbose "Sicherung geprueft"

    #$OrgDestination = Import-Clixml ($MagentaFolderLocal + "\Scripts\destination.xml")
    #$OrgFolder = $OrgDestination.FullName
    
   
    # Create Directorys if not exist
    #$FilesSicherung = Import-Clixml ($MagentaFolderLocal + "\Scripts\Sicherung.xml")
    #$FilesSicherung | where {$_.attributes -match "Directory"}| %{
    #    $newdir = $_.fullname.Replace($OrgFolder,$DestFolder)
    #    If (-not (Test-Path $newdir)) { 
    #    write-verbose "Erzeuge Pfad $newdir"
    #    md $newdir 
    #    }
    #  }
    
    # Move only Items that provided inside the xml Files
    #$FilesSicherung | where {$_.attributes -notmatch "Directory"} |% {move-item $_.Fullname.Replace($OrgFolder,$Sourcefolder) $_.Fullname.Replace($OrgFolder,$Destfolder)} 
 
    $FilesRel = Import-Clixml ($MagentaFolderLocal + "\Scripts\FilenamesRel.xml")
    $FilesRel | %{New-Item -ItemType File -path $($Destfolder + $_) -Force}|Out-Null
    $FilesRel | %{move-item -path $($Sourcefolder + $_) -destination $($Destfolder + $_) -force}
    
    # Use the Original DirectoryName inside from the XML File
    $FilesHash = Import-Clixml ($MagentaFolderLocal + "\Scripts\Hashfiles.xml")
    $FilesHash | % {$_.Fullname.Replace($_.DirectoryName,$MagentaFolderLocal+"\Scripts")}|Remove-Item 
   }
    
# Set final Status
if (!$verbose) {.\fhemcl.ps1 $fhemurl "set Sicherung PSEnde"}
Write-Verbose "Sicherung Synchronisation Ende"
