<#
# ==============================================================================
#
# Git + SSH for Windows
#
# ---- git-ssh.ps1 v0.0.1
# ==============================================================================
#>

param(
    [switch]$checkonly = $false,
    [switch]$tortoisegit = $false
)

#############
# Variables #
#############
$vbVersion = "4.3.14"     # VirtualBox Target Version
$vbRevision = "95030"       # VirtualBox Revision linked to version
$vagrantVersion = "1.6.3" # Vagrant Target Version
$vvvVersion = "master"    # VVV Target Version


####################
# Helper Functions #
####################
function prepareTempDir( $folder ) {

    $tempDir = Join-Path $env:TEMP $folder

    function createDir($dir) {
        [System.IO.Directory]::CreateDirectory($dir)
    }
    
    if ( ![System.IO.Directory]::Exists($tempDir) ) {
        createDir($tempDir)
    }
    #else { # no need to delete the temp directory if present
    #    [System.IO.Directory]::Delete($tempDir,1)
    #    createDir($tempDir)
    #}

    return $tempDir

} # END prepareTempDir

function downloadFile {
    <#
    .SYNOPSIS
        Downloads a file showing the progress of the download
    .DESCRIPTION
        This Script will download a file locally while showing the progress of the download
    .EXAMPLE
        .\Download-File.ps1 'http:\\someurl.com\somefile.zip'
    .EXAMPLE
        .\Download-File.ps1 'http:\\someurl.com\somefile.zip' 'C:\Temp\somefile.zip'
    .PARAMETER url
        url to be downloaded
    .PARAMETER localFile
        the local filename where the download should be placed
    .NOTES
        FileName     : Download-File.ps1
        Author       : CrazyDave
        LastModified : 18 Jan 2011 9:39 AM PST
    #Requires -Version 2.0
    #>
    param(
        [Parameter(Mandatory=$true)]
        [String] $url,
        [Parameter(Mandatory=$false)]
        [String] $localFile = (Join-Path $pwd.Path $url.SubString($url.LastIndexOf('/')))
    )
       
    begin {
        $client = New-Object System.Net.WebClient
        $Global:downloadComplete = $false
     
        $eventDataComplete = Register-ObjectEvent $client DownloadFileCompleted `
            -SourceIdentifier WebClient.DownloadFileComplete `
            -Action {$Global:downloadComplete = $true}
        $eventDataProgress = Register-ObjectEvent $client DownloadProgressChanged `
            -SourceIdentifier WebClient.DownloadProgressChanged `
            -Action { $Global:DPCEventArgs = $EventArgs }    
    }
     
    process {
        Write-Progress -Activity 'Downloading file' -Status $url
        $client.DownloadFileAsync($url, $localFile)
       
        while (!($Global:downloadComplete)) {                
            $pc = $Global:DPCEventArgs.ProgressPercentage
            if ($pc -ne $null) {
                Write-Progress -Activity 'Downloading file' -Status $url -PercentComplete $pc
            }
        }
       
        Write-Progress -Activity 'Downloading file' -Status $url -Complete
    }
     
    end {
        Unregister-Event -SourceIdentifier WebClient.DownloadProgressChanged
        Unregister-Event -SourceIdentifier WebClient.DownloadFileComplete
        $client.Dispose()
        $Global:downloadComplete = $null
        $Global:DPCEventArgs = $null
        Remove-Variable client
        Remove-Variable eventDataComplete
        Remove-Variable eventDataProgress
        [GC]::Collect()    
    }

} # END downloadFile

# @return <$false|"version">
function getGitVersion {

    function fetchGitVersion() {

        # @todo
        #    git version => git version 1.9.4.msysgit.0
        #    if not installed: => ????
		#	

        $version = "git version 1.9.4.msysgit.0" # temp 

        return $version
    }

    $gitInstalledVersion = fetchGitVersion

    if ( $gitInstalledVersion -ne "└── (empty)" ) {

        $gitInstalledVersion = $gitInstalledVersion.Split(" ")
        $versionfull = $gitInstalledVersion[2]

        $versionsplit = $versionfull.Split(".msysgit.")

        $version = $versionsplit[0]
    }
    else {
        $version = $false
    }

    return $version

} # END 


########################
# Installation Process #
########################

$tempDir = prepareTempDir "gitssh" # set temp directory

# == Splesh Screen ==
Write-Host "# ==============================================================================`n"
Write-Host "# Git + SSH for Windows`n"
Write-Host "# ==============================================================================`n`n"


# == Git ==
Write-Host "== Git =="

# === Check Git ===
$gitInstalled = getGitVersion # <$false|"version">
compareVersion "Git" $gitInstalled $vbRevision

# == TortoiseGit ==
if ( $tortoisegit ) {
    
    Write-Host "== TortoiseGit =="

    # === Check TortoiseGit ===
    $tortoiseInstalled = getTortoiseGitVersion # <$false|"version">
    compareVersion "TortoiseGit" $tortoiseInstalled $vagrantVersion

}

## == SSH ==
#Write-Host "== SSH =="
#
## === Check SSH ===
#$gruntInstalled = getGruntVersion # <$false|"version">
#compareVersion "SSH" $gruntInstalled $vagrantVersion
