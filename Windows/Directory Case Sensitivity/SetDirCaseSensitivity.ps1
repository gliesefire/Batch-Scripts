param (
        [Parameter(Mandatory = $true)][string]$parentDirectory,
        [switch]$recurse,
        [switch]$disable
    )
function SetDirCaseSensitivity {
    param (
        [Parameter(Mandatory = $true)][string]$parentDirectory,
        [bool]$recurse,
        [bool]$disable
    )

    Write-Debug "Requested Directory is : $parentDirectory";
    Write-Debug "User Input : $parentDirectory Is Recursive : $recurse";

    $SubDirectories = $null
    if ($recurse) {
        $SubDirectories = Get-ChildItem -Path $parentDirectory -Recurse -Directory -Force -ErrorAction SilentlyContinue
    }
    else {
        $SubDirectories = Get-ChildItem -Path $parentDirectory -Directory -Force -ErrorAction SilentlyContinue
    }

    if ($null -eq $SubDirectories -or $SubDirectories.Count -eq 0) {
        #Create an empty List
        $SubDirectories = [System.Collections.Generic.List[System.IO.DirectoryInfo]]::new()
    }
    else {
        #Explicitly cast to DirectoryInfo Array
        $SubDirectories = ([System.IO.DirectoryInfo[]]$SubDirectories)
        #Convert DirectoryInfo Array to List<DirectoryInfo>
        $SubDirectories = [System.Collections.Generic.List[System.IO.DirectoryInfo]]::new($SubDirectories)
    }

    #Include parent directory in the list
    $SubDirectories.Add([System.IO.DirectoryInfo]::new($parentDirectory))

    if ($disable) {
        $action = "disable"
    }
    else {
        $action = "enable";
    }

    ForEach ($dir in $SubDirectories) {
        $path = $dir.FullName
        fsutil.exe file setCaseSensitiveInfo "$path" $action
    }
}

SetDirCaseSensitivity $parentDirectory $recurse $disable

Write-Output "Press any key to exit..."
$Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown") | OUT-NULL
$Host.UI.RawUI.FlushInputbuffer()