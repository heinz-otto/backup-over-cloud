<#
	.SYNOPSIS
		The script compares deals with Filehashes from folders and Files  
#>
#region Params
param(
		[Parameter(Position=0, Mandatory=$false,ValueFromPipeline=$false)]
		[ValidateScript({Test-Path -LiteralPath $_ -PathType 'Container'})] 
		[System.String]
		$LeftDir="",
		[Parameter(Position=1, Mandatory=$false,ValueFromPipeline=$false)]
		[ValidateScript({Test-Path -LiteralPath $_ -PathType 'Container'})] 
		[System.String]
		$RightDir="",
		[Parameter(Position=2, Mandatory=$false,ValueFromPipeline=$true)]
		[ValidateNotNullOrEmpty()]  
		[System.String]
		$LeftHashFile="",
		[Parameter(Position=3, Mandatory=$false,ValueFromPipeline=$false)]
		[ValidateNotNullOrEmpty()]  
		[System.String]
		$RightHashFile="",
		[Parameter(Position=4, Mandatory=$false,ValueFromPipeline=$false)]
		[ValidateNotNullOrEmpty()]  
		[System.String]
		$LogFile=".\Backup-Files.log"
		)
#endregion 
#C:\Users\heinz\MagentaCLOUD\backupdata
#.\Test.xml
begin{
    function GetHashFromDir {
    param(
		[Parameter(Mandatory=$false,ValueFromPipeline=$true)]
		[ValidateScript({Test-Path -LiteralPath $_ -PathType 'Container'})] 
		[System.String]
		$HashDir=""
		)
       Get-ChildItem $HashDir -Recurse | Get-FileHash | select @{Label="Path";Expression={$_.Path.Replace($HashDir,"")}},Hash 
    }

    function GetHashFromFile {
    param(
		[Parameter(Mandatory=$false,ValueFromPipeline=$false)]
		[ValidateNotNullOrEmpty()]  
		[System.String]
		$HashFile=""
		)
       Import-Clixml $HashFile
    }

    function CompareLeftFileRightFolder{
    param(
		[Parameter(Mandatory=$false,ValueFromPipeline=$false)]
		[ValidateNotNullOrEmpty()]  
		[System.String]
		$HashFile="",
		[Parameter(Mandatory=$false,ValueFromPipeline=$false)]
		[ValidateScript({Test-Path -LiteralPath $_ -PathType 'Container'})] 
		[System.String]
		$HashDir=""
		)
        $LeftSideHash = Import-Clixml $HashFile
        $RightSideHash = foreach ($Line in $LeftSideHash) {
            $File = $($HashDir + $Line.path)
            write-verbose ("Bilde Hash von der Datei: " + $File)
            Get-FileHash $File| select @{Label="Path";Expression={$_.Path.Replace($HashDir,"")}},Hash
            }
        $Result = Compare-Object $LeftSideHash $RightSideHash -Property Path,Hash
        $Result
    }

#0 - is OK. 1 - some error
$exitValue="Nichts gelaufen"
}

process{
	try{
        if ($LeftDir -ne "" -and $RightDir -eq "" -and $LeftHashFile -ne "" -and $RightHashFile -eq "") {
            GetHashFromDir $LeftDir |Export-Clixml $LeftHashFile
            $exitValue = 0
            }
        if ($LeftDir -eq "" -and $RightDir -ne "" -and $LeftHashFile -eq "" -and $RightHashFile -ne "") {
            GetHashFromDir $RightDir |Export-Clixml $RightHashFile
            $exitValue = 0
            }
        if ($LeftDir -eq "" -and $RightDir -ne "" -and $LeftHashFile -ne "" -and $RightHashFile -eq "") {
                if ($LeftHashFile -match "\*") {
                    $cnt=0
                    $SourceFiles = gci $LeftHashFile
                    foreach ($file in $sourcefiles) {
                        write-verbose ("Verwende Hashfile" + $file)
                        $Return = CompareLeftFileRightFolder $File $RightDir
                        if ($Return) {$cnt++}
                    }
                    $Return = $cnt
                   } 
                else {
                    write-verbose ("Verwende Hashfile -------------- " + $LeftHashFile)
                    $Return = CompareLeftFileRightFolder $LeftHashFile $RightDir
                   }
                If ($Return) {$exitValue = $Return} else {$exitValue = 0}
            }
 
        if ($LeftDir -ne "" -and $RightDir -ne "" -and $LeftHashFile -eq "" -and $RightHashFile -eq "") {
                $Return = Compare-Object (GetHashFromDir $LeftDir) (GetHashFromDir $RightDir) -Property Path,Hash
                If ($Return) {$exitValue = $Return} else {$exitValue = 0}
            }
        if ($LeftDir -eq "" -and $RightDir -eq "" -and $LeftHashFile -ne "" -and $RightHashFile -ne "") {
            $Return = Compare-Object (GetHashFromFile $LeftHashFile) (GetHashFromFile $RightHashFile)
            If ($Return) {$exitValue = $Return} else {$exitValue = 0}
            }
            $exitValue
        }
	catch { 
    }
}
end{exit $exitValue}