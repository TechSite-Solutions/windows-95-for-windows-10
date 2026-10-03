param(
    [string]$AssetRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) "local-assets")
)

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Assert-Windows10

if(-not(Test-Path $AssetRoot)){throw "Asset directory not found: $AssetRoot"}

Write-Section "Importing local Windows 95 assets"
Write-Warning "Use only assets you are legally allowed to use. These files remain local and are not uploaded by this script."

function Find-LocalAsset {
    param([string]$Directory,[string[]]$Names)
    foreach($name in $Names){
        $path=Join-Path $Directory $name
        if(Test-Path $path){return (Resolve-Path $path).Path}
    }
    return $null
}

$cursorDir=Join-Path $AssetRoot "cursors"
$cursorKey="HKCU:\Control Panel\Cursors"
$cursorMap=[ordered]@{
    Arrow=@("arrow.cur"); Help=@("help.cur"); AppStarting=@("appstarting.ani","appstarting.cur");
    Wait=@("wait.ani","wait.cur"); Crosshair=@("cross.cur"); IBeam=@("ibeam.cur"); No=@("no.cur");
    SizeNS=@("size-ns.cur"); SizeWE=@("size-we.cur"); SizeNWSE=@("size-nwse.cur");
    SizeNESW=@("size-nesw.cur"); SizeAll=@("size-all.cur"); UpArrow=@("up.cur"); Hand=@("hand.cur")
}
$cursorCount=0
foreach($item in $cursorMap.GetEnumerator()){
    $file=Find-LocalAsset -Directory $cursorDir -Names $item.Value
    if($file){
        Set-RegistryValue -Path $cursorKey -Name $item.Key -Value $file -Type String
        Write-Host "Cursor $($item.Key) -> $file"
        $cursorCount++
    }
}

$soundDir=Join-Path $AssetRoot "sounds"
$sounds=[ordered]@{
    SystemAsterisk="asterisk.wav"; SystemExclamation="exclamation.wav"; SystemHand="critical-stop.wav";
    SystemQuestion="question.wav"; SystemDefault="default-beep.wav"; EmptyRecycleBin="empty-recycle-bin.wav";
    WindowsLogon="logon.wav"; WindowsLogoff="logoff.wav"; SystemNotification="notification.wav"
}
$soundCount=0
foreach($item in $sounds.GetEnumerator()){
    $file=Find-LocalAsset -Directory $soundDir -Names @($item.Value)
    if($file){
        $regPath="HKCU\AppEvents\Schemes\Apps\.Default\$($item.Key)\.Current"
        & reg.exe add $regPath /ve /d $file /f | Out-Null
        Write-Host "Sound $($item.Key) -> $file"
        $soundCount++
    }
}

$iconDir=Join-Path $AssetRoot "icons"
$computer=Find-LocalAsset -Directory $iconDir -Names @("computer.ico")
$network=Find-LocalAsset -Directory $iconDir -Names @("network.ico")
$recycleEmpty=Find-LocalAsset -Directory $iconDir -Names @("recycle-empty.ico")
$recycleFull=Find-LocalAsset -Directory $iconDir -Names @("recycle-full.ico")
$iconCount=0

if($computer){
    $k='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\DefaultIcon'
    & reg.exe add $k /ve /d $computer /f | Out-Null
    Write-Host "This PC icon -> $computer"
    $iconCount++
}
if($network){
    $k='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}\DefaultIcon'
    & reg.exe add $k /ve /d $network /f | Out-Null
    Write-Host "Network icon -> $network"
    $iconCount++
}
if($recycleEmpty -or $recycleFull){
    $k='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon'
    if($recycleEmpty){
        & reg.exe add $k /v empty /d $recycleEmpty /f | Out-Null
        if(-not $recycleFull){$recycleFull=$recycleEmpty}
    }
    if($recycleFull){
        & reg.exe add $k /v full /d $recycleFull /f | Out-Null
        if(-not $recycleEmpty){$recycleEmpty=$recycleFull}
    }
    & reg.exe add $k /ve /d $recycleEmpty /f | Out-Null
    Write-Host "Recycle Bin icons configured."
    $iconCount++
}

Write-Host ""
Write-Host "Imported cursor mappings: $cursorCount"
Write-Host "Imported sound mappings:  $soundCount"
Write-Host "Imported icon groups:     $iconCount"
Write-Host "Sign out/in (or restart Explorer where appropriate) to refresh all shell resources."
