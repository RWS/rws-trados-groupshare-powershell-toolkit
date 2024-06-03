# Trados Groupshare Powershell
## Introduction
The Trados Groupshare Powershell toolkit allow to script the [ProjectAutomationApi](http://producthelp.sdl.com/SDK/ProjectAutomationApi/3.0/html/b986e77a-82d2-4049-8610-5159c55fddd3.htm). In order to use the Project Automation API via the Trados PowerShell Toolkit , a Professional license for Trados Studio is required. PowerShell 2.0 comes pre-installed on Windows 7. On Windows XP, you may need to manually install PowerShell if it is not already installed.    
Additionally, a Groupshare running server is required in order to use the scripts that enable the functionality to perform operations on Groupshare servers.
## Structure
The Powershell toolkit consists of 8 modules and can be split in 3 parts.
- Modules that handle filebased resources
    - `GetGuids`
    - `PackageHelper`
    - `ProjectHelper`
    - `TMHelper`
- Modules that handle server resources        
    - `TMServerHelper`
    - `UserManagerHelper`
    - `ProjectServerHelper`
- `ToolkitInitializer` used to load all the modules and all the required dependencies.

and 5 samples files which contains examples on how to use the above modules:
- `FileBasedProject_Roundtrip.ps1`
- `ProjectServer_Roundtrip.ps1`
- `TMServer_Roundtrip.ps1`
- `UserManagement_Roundtrip.ps1`
- `import.tmx` - this one is used as an example file for importing a TMX into a server based TM

## Instalation
1. Ensure Trados Studio with a professional license is installed.
2. Ensure a Groupshare server is available.
3. Create the following 2 folders:
    - `C:\users\{your_user_name}\Documents\windowspowershell`
    - `C:\users\{your_user_name}\Documents\windowspowershell\modules`
4. Copy the sample files into `windowspowershell` module:
    - `...\windowspowershell\FileBasedProject_Roundtrip.ps1`
    - `...\windowspowershell\import.tmx`
    - `...\windowspowershell\ProjectServer_Roundtrip.ps1`
    - `...\windowspowershell\TMServer_Roundtrip.ps1`
    - `...\windowspowershell\UserManagement_Roundtrip.ps1`
    - `...\windowspowershell\import.tmx`
5. Copy the eight modules into `modules` folder:
    - `...\windowspowershell\modules\GetGuids`
    - `...\windowspowershell\modules\PackageHelper`
    - `...\windowspowershell\modules\ProjectHelper`
    - `...\windowspowershell\modules\TMHelper`
    - `...\windowspowershell\modules\TMServerHelper`
    - `...\windowspowershell\modules\ProjectServerHelper`
    - `...\windowspowershell\modules\UserManagerHelperHelper`
    - `...\windowspowershell\modules\ToolkitInitializer`
6. Open the PowerShell **(x86)** command prompt (since Trados Studio is a 32-bit application)
7. Before running the scripts make sure the `$StudioVersion` from the `ToolkitInitializer` module corresponds with the version of Studio you are using ("Studio17" for Studio 2022)

## Sample Scripts usage
1. Ensure that the `$StudioVersion` from the sample files correspons with the version of Studio you are using and the `$serverAddress` correspons with the Groupshare server address you are using.
2. Open the PowerShell **(x86)** command prompt
3. Change the directory to where the scripts are located e.g `C:\users\{your_user_name}\Documents\windowspowershell`
4. Ensure you have rights to run the script. You may first need to enter the following command: `Set-ExecutionPolicy remotesigned`
5. Run the scripts in the following order:
    - type `.\FileBasedProject_Roundtrip.ps1` and press enter
    - type `.\ProjectServer_Roundtrip.ps1` and press enter
    - type `.\TMServer_Roundtrip.ps1` and press enter
    - type `.\UserManagement_Roundtrip.ps1` and press enter

## Modules Usage
1. Ensure that the default `StudioVersion` from the `ToolkitInitializer.psm1` is set to the Trados Studio version you are using
2. Import the `ToolkitInitializer` module
3. Call the `Import-ToolkitModules` with your `StudioVersion` or with no paramter if the default StudioVersion paramter was set.
4. All the functions from the Trados Studio Toolkit are available to use.

## Changes
### v3.0.0.0
- Created the scripts and updated them to be compatible with latest versions of Trados (Trados 2022, Trados 2024)
- Added helpers for all the functions implemented.