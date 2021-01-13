# Windows 10
## Directory Case Sensitivity
---

**Requirements** <br>
Windows 10’s April 2018 Update.

**Context** <br>
By default, the directory system in Windows is case insensitive. Case sensitivity was added in Windows 10’s April 2018 Update, but only on a per-directory basis.

**Action**
This powershell script allows you to apply Case-Sensitivity to a Directory Recursively.
You can either run the [powershell script](Windows\Directory%20Case%20Sensitivity\SetDirCaseSensitivity.ps1) yourself
```powershell
# Set Directories under current directory (inclusive) case sensitive
SetDirectoryCaseSensitivity "." -recurse`

# Set Directories under current directory (inclusive) case insensitive
SetDirectoryCaseSensitivity "." -recurse -disable`
```
or you can run the [AddToContextMenu.bat](Windows\Directory%20Case%20Sensitivity\AddToContextMenu.bat) to add the script to your context menut (Right click on Directory).

Depending upon who created the directory and type of directory, administrator permissions might be required, thus admin permissions is enabled by default for context menu.