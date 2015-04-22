<#
# ==============================================================================
#
# Node.js + Grunt and Bower for Windows
#
# ---- tools-node.ps1 v0.0.1
# ==============================================================================
#>

param(
    [switch]$checkonly = $false,
    [switch]$grunt = $true,
	[switch]$bower = $true
)

#############
# Variables #
#############
$vbVersion = "4.3.14"     # VirtualBox Target Version
$vbRevision = "95030"       # VirtualBox Revision linked to version
$vagrantVersion = "1.6.3" # Vagrant Target Version
$vvvVersion = "master"    # VVV Target Version

# http://nodejs.org/dist/latest/x64/node-v0.10.31-x64.msi


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
function getNodeVersion {
    
    function fetchNodeVersion() {

        $version = node -v

        return $version.Substring(1)

    } # END

    $version = fetchNodeVersion

    return $version

} # END

# @return current Node.js stable version
function getNodeStable {

    #the web address to retrieve
    $url= "http://nodejs.org/"
 
    #this is a one-time request
    $data = Invoke-Webrequest -Uri $url -DisableKeepAlive

    $text = $data.ParsedHtml.getElementsByTagName("p") | Where "classname" -match "version" | Select -ExpandProperty InnerText

    $version_text = $text.Split(" ")

    $version = $version_text[-1]

    return $version.Substring(1)

} # END

# @return current installed version of a npm package
function getNPMinstalled( $package ) {

    $installed = npm list -g $package

    $version = $installed.Split(" ")

    if ( $version[2] -ne "(empty)" ) {

        $v = $version[2].Split("@")
        $version = $v[1]

    }
    elseif ( $version[2] -eq "(empty)" ) {

        $version = $false

    }

    return $version

} # END

# @return current stable version of a npm package
function getNPMcurrent( $package ) {

    $version = npm show $package version

    return $version

} # END

# Compares two version numbers "a.b.c.d". If $version1 < $version2,
# returns -1. If $version1 = $version2, returns 0. If
# $version1 > $version2, returns 1.
function CompareVersions([String] $version1, [String] $version2) {
  $ver1 = GetVersionStringAsArray $version1
  $ver2 = GetVersionStringAsArray $version2
  if ($ver1[0] -lt $ver2[0]) {
    return -1
  }
  elseif ($ver1[0] -eq $ver2[0]) {
    if ($ver1[1] -lt $ver2[1]) {
      return -1
    }
    elseif ($ver1[1] -eq $ver2[1]) {
      return 0
    }
    else {
      return 1
    }
  }
  else {
    return 1
  }
}

# Returns a version number "a.b.c.d" as a two-element numeric
# array. The first array element is the most-significant 32 bits,
# and the second element is the least-significant 32 bits.
function GetVersionStringAsArray([String] $version) {
  $parts = $version.Split(".")
  if ($parts.Count -lt 4) {
    for ($n = $parts.Count; $n -lt 4; $n++) {
      $parts += "0"
    }
  }
  [UInt32] ((Lsh $parts[0] 16) + $parts[1])
  [UInt32] ((Lsh $parts[2] 16) + $parts[3])
}

# Bitwise left shift.
function Lsh([UInt32] $n, [Byte] $bits) {
  $n * [Math]::Pow(2, $bits)
}

function checkPackage($package, $installed, $stable) {

    if ( $installed -eq $false ) {
        Write-Host "Current Version: [Not Installed]"
        Write-Host "Stable Version:  $stable`n"

        if ($checkonly -eq !$true) {
            Write-Host "Starting Installation of stable version...`n`n"
            setupPackage $packages
        }
    }
    elseif ( (CompareVersions $installed $stable) -eq 0 ) {
        Write-Host "Current Version: $installed"
        Write-Host "Stable Version:  $stable`n"

        Write-Host "equal"

        if ($checkonly -eq !$true) {
            Write-Host "Nothing to do here. Skipping this step...`n`n"
        }
    }
    elseif ( (CompareVersions $installed $stable) -eq -1 ) {
        Write-Host "Current Version: $installed"
        Write-Host "Stable Version:  $stable`n"

        Write-Host "behind"

        if ($checkonly -eq !$true) {
            Write-Host "Starting Upgrade to stable version...`n`n"
            setupPackage $package
        }
    }
    
}

function setupPackage() {

    param (
        [string]$package
    )
    
    if ($package -eq "Node") {

        Write-Host "setupNode"

    }
    elseif ($package -eq "Grunt") {

        Write-Host "setupGrunt"

    }
    elseif ($package -eq "Bower") {

        Write-Host "setupBower"

    }

}


########################
# Installation Process #
########################

$tempDir = prepareTempDir "node" # set temp directory

# == Splesh Screen ==
Write-Host "# ==============================================================================`n"
Write-Host "# Node.js + Grunt and Bower for Windows`n"
Write-Host "# ==============================================================================`n`n"


# == Node.js ==
Write-Host "== Node.js =="

# === Check Node.js ===
$nodeInstalled = getNodeVersion # <$false|"version">
$nodeStable = getNodeStable
checkPackage "Node" $nodeInstalled $nodeStable


if ( $nodeInstalled -ne $false ) {

    # == Grunt ==
    Write-Host "== Grunt =="

    # === Check Grunt ===
    checkPackage "Grunt" (getNPMinstalled "grunt") (getNPMcurrent "grunt")

    # == Bower ==
    Write-Host "== Bower =="

    # === Check Bower ===
    checkPackage "Bower" (getNPMinstalled "bower") (getNPMcurrent "bower")

} else {
    Write-Host "`nGrunt and Bower checks skipped."
    Write-Host "You have no access to NPM because Node.js is not installed!`n"
}
