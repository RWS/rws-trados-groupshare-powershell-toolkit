cls;
Write-Host "This script demonstrates how the PowerShell Toolkit can be used to automate small workflows";

Write-Host "Start with loading PowerShell Toolkit modules.";
$studioVersion = "Studio17";
Import-ToolkitModules $studioVersion;

Write-host "Now Let's Publish a Project to the server"
$credentialStore = Get-ProjectServer "http://wsamzn-ic6795n2.global.sdl.corp/" "sa" "sa"
$cache = Get-UMServer "http://wsamzn-ic6795n2.global.sdl.corp/" "sa" "sa";
$manager = Get-UserManager $cache;
$allOrganizations = Get-AllOrganizations $manager
$project = Get-Project "c:\Projects\PowerShellToolKit\PowerShellTest\$StudioVersion\SampleProject"

Publish-Project $credentialStore $project $allOrganizations[0];

Write-host "Now let's open the server project"

$serverProject = Get-ServerBasedProject $credentialStore $allOrganizations[0] "My Test Project" "c:\Projects\PowerShellToolKit\PowerShellTest\$StudioVersion\ServerBasedProjects";

Write-host "Finish!";
Remove-toolkitmodules;
Remove-module -name ToolkitInitializer;