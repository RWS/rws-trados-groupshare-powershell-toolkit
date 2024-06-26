$scriptPath = $MyInvocation.MyCommand.Path
$scriptParentDiv = Split-Path $scriptPath -Parent;
$global:moduleNames = @()
$defaultModules = @(
    "TMHelper",
    "ProjectHelper",
    "ProjectServerHelper",
    "PackageHelper",
    "GetGuids",
    "TMServerHelper",
    "UserManagerHelper"
)

<#
    .SYNOPSIS
    Import all the necessary or given modules from the Modules folder.

    .DESCRIPTION
    Loads all the types and dependencies together with the modules and export their functions globally.
    Additionally it can load only the given modules

    .PARAMETER StudioVersion
    Represents the Version of the Studio the user is using | Studio17 for Studio 2022, Studio18 for Studio 2024
    The User can change its default value to the Trados Studio version he/she is using.

    .PARAMETER Modules
    Optional. Represents the module names to load into the powershell session.

    .EXAMPLE
    Import-ToolkitModules

    Loads all the modules and the depedencies on the default version. User can change this to the used Trados Studio version

    Import-ToolkitModules -StudioVersion "Studio16"

    Loads all the modules and the dependencies for the Studio 2021 (Studio16 version name).

    Import-ToolkitModules -StudioVersion "Studio16" -Modules @("GetGuids")

    Loads all the dependencies and only the GetGuids modules for the Studio 2021 (STudio16 version name).

    Import-ToolkitModules -Modules@("GetGuids")

    Loads all the dependencies only for the GetGuids module for the default Studio Version.
#>
function Import-ToolkitModules {
    param ([String] $StudioVersion = "Studio17",
    [String[]] $Modules = @())

    Add-Dependencies $StudioVersion

    if ($Modules.Count -ne 0)
    {
        $global:moduleNames = $Modules;
    }
    else {
        $global:moduleNames = $defaultModules;
    }

    foreach ($moduleName in $global:moduleNames)
    {
        Import-Module -Name $moduleName -Scope Global
    }
}

<#
    .SYNOPSIS
    Remove all the used modules

    .DESCRIPTION
    Removes all the modules the user has loaded that are part of the Trados Powershell Toolkit except the ToolkitInitializer

    .EXAMPLE
    Remove-ToolkitModules
#>
function Remove-ToolkitModules {
    foreach ($moduleName in $global:moduleNames)
    {
        Remove-Module -Name $moduleName;
    }

    $global:moduleNames = @();
}

function Add-Dependencies {
    param([String] $StudioVersion)

    $assemblyResolverPath = $scriptParentDiv + "\DependencyResolver.dll"

    if ("${Env:ProgramFiles(x86)}") {
        $ProgramFilesDir = "${Env:ProgramFiles(x86)}"
    }
    else {
        $ProgramFilesDir = "${Env:ProgramFiles}"
    }
    
    $appPath = "$ProgramFilesDir\Trados\Trados Studio\$StudioVersion\"
    # Use this for debugging
    # $appPath = "D:\Code\Bin\Mixed Platforms\Debug\";

    # Solve dependency conficts
    Add-Type -Path $assemblyResolverPath;

    $assemblyResolver = New-Object DependencyResolver.AssemblyResolver("$appPath\");
    # Use this for debugging
    # $assemblyResolver = New-Object DependencyResolver.AssemblyResolver("D:\Code\Bin\Mixed Platforms\Debug\");
    $assemblyResolver.Resolve();

    Add-Type -Path "$appPath\Sdl.ProjectAutomation.FileBased.dll"
    Add-Type -Path "$appPath\Sdl.ProjectAutomation.Core.dll"
    Add-Type -Path "$appPath\Sdl.LanguagePlatform.TranslationMemory.dll"
    Add-Type -Path "$appPath\Sdl.Desktop.Platform.ServerConnectionPlugin.dll"
}

Export-ModuleMember Import-ToolkitModules
Export-ModuleMember Remove-ToolkitModules