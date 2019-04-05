Set-Location $PSScriptRoot

$MagentaFolderLocal = "D:\MagentaCLOUD"
$SourceFolder = $MagentaFolderLocal + "\Sicherung"
$DestFolder = "S:\SicherungNeu"
$fhemurl = "http://192.168.100.119:8083"

# Set Status Server started
.\fhemcl.ps1 $fhemurl "set Sicherung gestartet"

# Wait that the linux station has synced the drives 
while(!$(.\fhemcl.ps1 $fhemurl "list Sicherung state").Item(1).contains("SyncEnde")) {sleep (5)}

# compare Files with on behalf of also transfered hashes
$Return = .\FolderCompare.ps1 -LeftHashFile ($MagentaFolderLocal + "\Scripts\LeftsideHash*.txt") -RightDir ($MagentaFolderLocal + "\Sicherung")

if ($Return -ne "nothing") {
    $SicherungStat = get-childitem -r $SourceFolder | Measure-Object -Property length -sum 
    .\fhemcl.ps1 $fhemurl "setreading Sicherung lastTransferCount $SicherungStat.count"
    .\fhemcl.ps1 $fhemurl "setreading Sicherung lastTransferSizeB $SicherungStat.sum"
    }

if ($Return -eq 0) {
    .\fhemcl.ps1 $fhemurl "set Sicherung geprueft"
    write-verbose "$SicherungStat.count Dateien geprüft"
    $FilesSicherung = Import-Clixml ($MagentaFolderLocal + "\Scripts\Sicherung.xml")
    $FilesHash = Import-Clixml ($MagentaFolderLocal + "\Scripts\Hashfiles.xml")
    
    # Create Directorys if not exist
    $FilesSicherung | where {$_.attributes -match "Directory"}| %{
        $newdir = $_.fullname.Replace("Z:\Sicherung",$DestFolder)
        If (-not (Test-Path $newdir)) { 
        write-verbose "Erzeuge Pfad $newdir"
        md $newdir 
        }
      }
    
    # Move only Items that provided inside the xml Files
    $FilesSicherung | where {$_.attributes -notmatch "Directory"} |% {move-item $_.Fullname.Replace("Z:\Sicherung",$Sourcefolder) $_.Fullname.Replace("Z:\Sicherung",$Destfolder)} 
    $FilesHash | % {$_.Fullname.Replace("Z:",$MagentaFolderLocal)}|Remove-Item 

    }
    
# Set final Status
.\fhemcl.ps1 $fhemurl "set Sicherung PSEnde"
Write-Verbose "Sicherung Synchronisation Ende"
