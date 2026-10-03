param(
    [Parameter(Mandatory=$true)]
    [string]$SourceDirectory,

    [switch]$ApplyCursors,
    [switch]$ApplySounds,
    [switch]$ApplyIcons
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Assert-Windows10

$source = (Resolve-Path $SourceDirectory).Path
$assetRoot = Join-Path $env:LOCALAPPDATA "Windows95ForWindows10\Assets"
$cursorDest = Join-Path $assetRoot "Cursors"
$soundDest = Join-Path $assetRoot "Sounds"
$iconDest = Join-Path $assetRoot "Icons"

New-Item -ItemType Directory -Force -Path $cursorDest,$soundDest,$iconDest | Out-Null

Write-Section "Importing user-owned assets"
Write-Host "Source: $source"
Write-Host "Destination: $assetRoot"
Write-Warning "This repository does not provide Microsoft Windows 95 assets. Import only files you are allowed to use."

function Copy-FirstAsset {
    param(
        [string[]]$Names,
        [string]$DestinationDirectory,
        [string]$DestinationName
    )
    foreach($name in $Names){
        $candidate=Join-Path $source $name
        if(Test-Path $candidate){
            $dest=Join-Path $DestinationDirectory $DestinationName
            Copy-Item $candidate $dest -Force
            return $dest
        }
    }
    return $null
}

$cursorMap=[ordered]@{
    Arrow       = @{Names=@("arrow.cur"); Dest="arrow.cur"}
    Help        = @{Names=@("help.cur"); Dest="help.cur"}
    AppStarting = @{Names=@("appstarting.ani","appstarting.cur"); Dest="appstarting.ani"}
    Wait        = @{Names=@("wait.ani","wait.cur"); Dest="wait.ani"}
    Crosshair   = @{Names=@("crosshair.cur","cross.cur"); Dest="crosshair.cur"}
    IBeam       = @{Names=@("ibeam.cur"); Dest="ibeam.cur"}
    NWPen       = @{Names=@("nwpen.cur"); Dest="nwpen.cur"}
    No          = @{Names=@("no.cur"); Dest="no.cur"}
    SizeNS      = @{Names=@("sizens.cur","size-ns.cur"); Dest="sizens.cur"}
    SizeWE      = @{Names=@("sizewe.cur","size-we.cur"); Dest="sizewe.cur"}
    SizeNWSE    = @{Names=@("sizenwse.cur","size-nwse.cur"); Dest="sizenwse.cur"}
    SizeNESW    = @{Names=@("sizenesw.cur","size-nesw.cur"); Dest="sizenesw.cur"}
    SizeAll     = @{Names=@("sizeall.cur","size-all.cur"); Dest="sizeall.cur"}
    UpArrow     = @{Names=@("uparrow.cur","up.cur"); Dest="uparrow.cur"}
    Hand        = @{Names=@("hand.cur"); Dest="hand.cur"}
}

$importedCursors=[ordered]@{}
foreach($role in $cursorMap.Keys){
    $spec=$cursorMap[$role]
    $dest=Copy-FirstAsset -Names $spec.Names -DestinationDirectory $cursorDest -DestinationName $spec.Dest
    if($dest){
        $importedCursors[$role]=$dest
        Write-Host "Cursor imported: $role"
    }
}

$soundMap=[ordered]@{
    ".Default\SystemAsterisk"     = @("asterisk.wav")
    ".Default\SystemExclamation"  = @("exclamation.wav")
    ".Default\SystemHand"         = @("critical-stop.wav")
    ".Default\SystemQuestion"     = @("question.wav")
    ".Default\SystemDefault"      = @("default-beep.wav")
    ".Default\SystemStart"        = @("startup.wav","logon.wav")
    ".Default\SystemExit"         = @("shutdown.wav","logoff.wav")
    ".Default\SystemNotification" = @("notification.wav")
    "Explorer\EmptyRecycleBin"    = @("empty-recycle-bin.wav")
}

$importedSounds=[ordered]@{}
foreach($event in $soundMap.Keys){
    $names=$soundMap[$event]
    $destName=$names[0]
    $dest=Copy-FirstAsset -Names $names -DestinationDirectory $soundDest -DestinationName $destName
    if($dest){
        $importedSounds[$event]=$dest
        Write-Host "Sound imported: $event"
    }
}

$iconSpecs=[ordered]@{
    Computer      = @{Names=@("computer.ico"); Dest="computer.ico"}
    Network       = @{Names=@("network.ico"); Dest="network.ico"}
    MyDocuments   = @{Names=@("my-documents.ico","documents.ico"); Dest="my-documents.ico"}
    ControlPanel  = @{Names=@("control-panel.ico"); Dest="control-panel.ico"}
    RecycleEmpty  = @{Names=@("recycle-empty.ico"); Dest="recycle-empty.ico"}
    RecycleFull   = @{Names=@("recycle-full.ico"); Dest="recycle-full.ico"}
}
$importedIcons=[ordered]@{}
foreach($role in $iconSpecs.Keys){
    $spec=$iconSpecs[$role]
    $dest=Copy-FirstAsset -Names $spec.Names -DestinationDirectory $iconDest -DestinationName $spec.Dest
    if($dest){
        $importedIcons[$role]=$dest
        Write-Host "Icon imported: $role"
    }
}

if($ApplyCursors){
    Write-Section "Applying imported cursor set"
    $cursorKey="HKCU:\Control Panel\Cursors"
    foreach($role in $importedCursors.Keys){
        Set-RegistryValue -Path $cursorKey -Name $role -Value $importedCursors[$role] -Type String
    }
    Set-RegistryValue -Path $cursorKey -Name "Scheme Source" -Value 1 -Type DWord
}

if($ApplySounds){
    Write-Section "Applying imported sound set"
    foreach($event in $importedSounds.Keys){
        $parts=$event -split "\\",2
        $app=$parts[0]
        $eventName=$parts[1]
        $currentKey="HKCU:\AppEvents\Schemes\Apps\$app\$eventName\.Current"
        New-Item -Path $currentKey -Force | Out-Null
        Set-Item -Path $currentKey -Value $importedSounds[$event]
    }
}

if($ApplyIcons){
    Write-Section "Applying imported desktop icons"

    function Set-ShellDefaultIcon {
        param([string]$Guid,[string]$Path)
        $key="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\$Guid\DefaultIcon"
        New-Item -Path $key -Force | Out-Null
        Set-Item -Path $key -Value $Path
    }

    if($importedIcons.Computer){Set-ShellDefaultIcon "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" $importedIcons.Computer}
    if($importedIcons.Network){Set-ShellDefaultIcon "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" $importedIcons.Network}
    if($importedIcons.MyDocuments){Set-ShellDefaultIcon "{59031A47-3F72-44A7-89C5-5595FE6B30EE}" $importedIcons.MyDocuments}
    if($importedIcons.ControlPanel){Set-ShellDefaultIcon "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" $importedIcons.ControlPanel}

    if($importedIcons.RecycleEmpty -or $importedIcons.RecycleFull){
        $key="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon"
        New-Item -Path $key -Force | Out-Null
        $empty=if($importedIcons.RecycleEmpty){$importedIcons.RecycleEmpty}else{$importedIcons.RecycleFull}
        $full=if($importedIcons.RecycleFull){$importedIcons.RecycleFull}else{$importedIcons.RecycleEmpty}
        Set-Item -Path $key -Value $empty
        Set-RegistryValue -Path $key -Name "empty" -Value $empty -Type String
        Set-RegistryValue -Path $key -Name "full" -Value $full -Type String
    }
}

Write-Host ""
Write-Host ("Imported cursors: {0}" -f $importedCursors.Count)
Write-Host ("Imported sounds:  {0}" -f $importedSounds.Count)
Write-Host ("Imported icons:   {0}" -f $importedIcons.Count)

if($ApplyCursors -or $ApplySounds -or $ApplyIcons){
    Write-Host "Sign out and sign back in for a complete resource refresh."
}
