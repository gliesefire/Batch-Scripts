 	
param (
    [Parameter(Mandatory = $false)]
    [Switch]$InstallSystemWide = $false
)

[System.IO.Directory]::SetCurrentDirectory($PSScriptRoot)

function CaseInsensitiveCommand {
    param (
        [Parameter(Mandatory = $true)][Microsoft.Win32.RegistryKey]$key
        , [Parameter(Mandatory = $true)][System.String]$command
    )
    $displayName = "Make Directory case insensitive";
    $insensitiveKey = $key.CreateSubKey($displayName, $true);
    if ($insensitiveKey -eq $null) {
        Write-Error "Unable to Create sub key [$displayName]. Make sure to run the script as administrator"
        return;
    }
    $inSensitiveCommand = $insensitiveKey.CreateSubKey("command", $true);
    if ($inSensitiveCommand -eq $null) {
        Write-Error "Unable to Create sub key [command] under [$displayName]. Make sure to run the script as administrator"
        return;
    }
    $inSensitiveCommand.SetValue("", $command -f "-recurse -disable");
}

function CaseSensitiveCommand {
    param (
        [Parameter(Mandatory = $true)][Microsoft.Win32.RegistryKey]$key
        , [Parameter(Mandatory = $true)][System.String]$command
    )
    $displayName = "Make Directory case sensitive";
    $sensitiveKey = $key.CreateSubKey($displayName, $true);
    if ($sensitiveKey -eq $null) {
        Write-Error "Unable to Create sub key [$displayName]"
        return;
    }
    $sensitiveCommand = $sensitiveKey.CreateSubKey("command", $true);
    if ($sensitiveCommand -eq $null) {
        Write-Error "Unable to Create sub key [command] under [$displayName]"
        return;
    }
    
    $sensitiveCommand.SetValue("", $command -f "-recurse");
}

function GetRandomName {
    return -join ((48..57) + (97..122) | Get-Random -Count 13 | ForEach-Object { [char]$_ });
}

$randomName = GetRandomName
$basePath = [System.Environment]::ExpandEnvironmentVariables("%ALLUSERSPROFILE%\DirectorySensitivity")
$scriptPath = [System.IO.Path]::Combine($basePath, "$randomName.ps1");

$executionScript = 'powershell -command "Start-Process cmd -ArgumentList ''/c cd /d ' + $basePath + ' && powershell -executionpolicy bypass -nologo -noExit -File ' + $scriptPath + ' {0} ""%1""'' -Verb runas"';

if (![System.IO.Directory]::Exists($basePath)) {
    [System.IO.Directory]::CreateDirectory($basePath);
}

[System.IO.File]::Copy("SetDirCaseSensitivity.ps1", $scriptPath);

$rightPanelFolder = $null;
$baseKeyLocation = "Software\\Classes\\directory\\shell";
if($InstallSystemWide){
    Write-Output 'Commensing system wide installation'
    $rightPanelFolder = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($baseKeyLocation, $true);
}
else{
    Write-Output 'Commensing current user installation'
    $rightPanelFolder = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($baseKeyLocation, $true);
}

if ($rightPanelFolder) {
    CaseInsensitiveCommand $rightPanelFolder $executionScript
    CaseSensitiveCommand $rightPanelFolder $executionScript
    Write-Output 'Added to context menu'
}
else {
    Write-Output 'Unable to add to context menu. Try installing for current user.'
}
