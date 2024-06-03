Add-Type -TypeDefinition @"

public class CredentialStore 
{
    public System.Uri ServerUri { get; private set; }

    public string UserName { get; private set; }

    public string Password {get; private set; }

    public CredentialStore(
        string uri,
        string userName,
        string password)
        {
            ServerUri = new System.Uri(uri);
            UserName = userName;
            Password = password;
        }
}
"@

<#
    .SYNOPSIS
    Stores the project connection info in a class.

    .DESCRIPTION
    Stores the given address, username and password in a custom class to be used for the other functions.
#>
function Get-ProjectServer 
{
    param(
        [String] $serverAddress,
        [String] $userName, 
        [String] $password)

    return New-Object CredentialStore($serverAddress, $userName, $password);
}

<#
    .SYNOPSIS
    Gets all the projects from the organizations.

    .DESCRIPTION
    Gets all the projects within the organization and the suborganizations.
#>
function Get-AllServerProjectsInfo
{
      param(
        [CredentialStore] $server,
        [SDL.ApiClientSDK.GS.Models.ResourceGroup] $organization)

    $projectServer = New-Object Sdl.ProjectAutomation.FileBased.ProjectServer(
        $server.ServerUri, $false, $server.UserName, $server.Password);
    return $projectServer.GetServerProjects($organization.Path, $true, $true);
}

<#
    .SYNOPSIS
    Syncs any changes done on the project to the groupshare server.
#>
function Update-ServerProject
{
    param ([Sdl.ProjectAutomation.FileBased.FileBasedProject] $project)

    $project.SynchronizeServerProjectData();
}

<#
    .SYNOPSIS
    Copies the server based project on the given path.
#>
function Get-ServerbasedProject
{
    param (
        [CredentialStore] $server,
        [SDL.ApiClientSDK.GS.Models.ResourceGroup] $organization,
        [String] $projectName,
        [String] $outputProjectFolder
    )

    $projectServer = New-Object Sdl.ProjectAutomation.FileBased.ProjectServer(
        $server.ServerUri, $false, $server.UserName, $server.Password);
    $projectInfo = $projectServer.GetServerProject("$($organization.Path)/$projectName");
    return $ProjectServer.OpenProject($projectInfo.ProjectId, $outputProjectFolder + "\" + $projectInfo.Name);
}

<#
    .SYNOPSIS
    Publish an existing project on the groupshare.
#>
function Publish-Project 
{
    param(
        [CredentialStore] $server,
        [Sdl.ProjectAutomation.FileBased.FileBasedProject] $project,
        [SDL.ApiClientSDK.GS.Models.ResourceGroup] $organization)

    $project.PublishProject(
        $server.ServerUri, $false, $server.UserName, $server.Password, $organization.Path, $null);
}

<#
    .SYNOPSIS
    Remove the given project from the server.
#>
function Remove-ServerbasedProject
{
    param([Sdl.ProjectAutomation.FileBased.FileBasedProject] $project)

    $project.DeleteFromServer();
}

Export-ModuleMember Get-ProjectServer;
Export-ModuleMember Get-AllServerProjectsInfo;
Export-ModuleMember Get-ServerbasedProject; 
Export-ModuleMember Publish-Project;
Export-ModuleMember Update-Project;
Export-ModuleMember Remove-ServerbasedProject;
