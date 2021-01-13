[System.IO.Directory]::SetCurrentDirectory($PSScriptRoot)

function CaseInsensitiveCommand{
    param (
        [Parameter(Mandatory=$true)][Microsoft.Win32.RegistryKey]$key
        ,[Parameter(Mandatory=$true)][System.String]$command
    )
    $displayName = "Make Directory case insensitive";
    $insensitiveKey = $key.CreateSubKey($displayName);
    if($insensitiveKey -eq $null){
        Write-Error "Unable to Create sub key [$displayName]"
        return;
    }
    $inSensitiveCommand = $insensitiveKey.CreateSubKey("command");
    if($inSensitiveCommand -eq $null){
        Write-Error "Unable to Create sub key [command] under [$displayName]"
        return;
    }
    $inSensitiveCommand.SetValue("", $command -f "-recurse -disable");
}

function CaseSensitiveCommand{
    param (
        [Parameter(Mandatory=$true)][Microsoft.Win32.RegistryKey]$key
        ,[Parameter(Mandatory=$true)][System.String]$command
    )
    $displayName = "Make Directory case sensitive";
    $sensitiveKey = $key.CreateSubKey($displayName);
    if($sensitiveKey -eq $null){
        Write-Error "Unable to Create sub key [$displayName]"
        return;
    }
    $sensitiveCommand = $sensitiveKey.CreateSubKey("command");
    if($sensitiveCommand -eq $null){
        Write-Error "Unable to Create sub key [command] under [$displayName]"
        return;
    }
    
    $sensitiveCommand.SetValue("", $command -f "-recurse");
}

function GetRandomName{
    return -join ((48..57) + (97..122) | Get-Random -Count 13 | ForEach-Object {[char]$_});
}

$randomName = GetRandomName
$basePath = [System.Environment]::ExpandEnvironmentVariables("%ALLUSERSPROFILE%\DirectorySensitivity")
$scriptPath = [System.IO.Path]::Combine($basePath, "$randomName.ps1");

$executionScript = 'powershell -command "Start-Process cmd -ArgumentList ''/c cd /d ' + $basePath + ' && powershell -executionpolicy bypass -nologo -noExit -File ' + $scriptPath + ' {0} ""%1""'' -Verb runas"';

if(![System.IO.Directory]::Exists($basePath)){
    [System.IO.Directory]::CreateDirectory($basePath);
}

[System.IO.File]::Copy("SetDirCaseSensitivity.ps1", $scriptPath);

$rightPanelFolder = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey("Software\\Classes\\directory\\shell", $true);
CaseInsensitiveCommand $rightPanelFolder $executionScript
CaseSensitiveCommand $rightPanelFolder $executionScript