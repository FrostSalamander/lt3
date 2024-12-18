$rev = "4.0"
$revSuffix="-$rev"
$timestamp = Get-Date -Format "dd/MM/yyyy HH:mm"

$devFolderName = 'lt3'
$missionName = 'faffairs'
#$missionDir = "C:\games\darkmod\fms\$devFolderName"
$missionDir = $PSScriptRoot
$stagingDir = 'C:\Temp\dm_staging'
$stagingMissionDir = "$stagingDir\$devFolderName"
$darkmodtxt = "$stagingMissionDir\darkmod.txt"
$readme = "$stagingMissionDir\readme.txt"

# Uncomment this for development and use $missionName for release
#$pkg = "$stagingMissionDir\$missionName$revSuffix"
$pkg = "$stagingMissionDir\$missionName"

$dmap = Read-Host -Prompt 'Did you delete and recompile the map files?'
if ( $dmap -notin "Y","y") {
    exit 1
}

$playerStart = Read-Host -Prompt 'Did you reset the player start position?'
if ( $playerStart -notin "Y","y") {
    exit 1
}

$masterKey = Read-Host -Prompt 'Did you disable the master key?'
if ( $masterKey -notin "Y","y") {
    exit 1
}

# clean staging directory and copy latest code
remove-item -path $stagingDir\* -Filter * -Force -Recurse
copy-item -path $missionDir -destination $stagingDir -recurse

# remove unwanted files
remove-item -path $stagingMissionDir -include .git,savegames,.gitignore,.github,build.ps1,changelog.txt,consolehistory.dat,*.darkradiant,*.bak,README.md -Force -Recurse

# token replace version
(Get-Content $darkmodtxt).replace('[VERSION]', $rev) | Set-Content $darkmodtxt 
(Get-Content $readme).replace('[VERSION]', $rev) | Set-Content $readme 
(Get-Content $readme).replace('[TIMESTAMP]', $timestamp) | Set-Content $readme 

# compress and rename main pk4
$compress = @{
    Path = "$stagingMissionDir\*"
    CompressionLevel = "Optimal"
    DestinationPath = "$pkg.zip"
}
Compress-Archive @compress
rename-item -path "$pkg.zip" -newname "$pkg.pk4"

