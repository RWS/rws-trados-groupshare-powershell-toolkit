cls
Write-Host "This script demonstrates how the PowerShell Toolkit can be used to automate small workflows";

Write-Host "Start with loading PowerShell Toolkit modules.";
Import-Module -Name ToolkitInitializer;

$studioVersion = "Studio17";

Import-toolkitmodules $studioVersion;

Write-Host "Connect to the management server.";
$cache = Get-UMServer "http://wsamzn-ic6795n2.global.sdl.corp/" "sa" "sa";
$manager = Get-UserManager $cache;
$allUsers = Get-AllUsers $manager;

Write-Host "We have" $allUsers.Count "users..."
foreach($user in $allUsers)
{
	Write-Host $user.Name -ForegroundColor green;
}

Write-Host "List of all organizations on the server."
$allOrganizations = Get-AllOrganizations $manager;

#only traversing root organization with first level of suborganizations
foreach($organization in $allOrganizations)
{
	Write-Host $organization.Name -ForegroundColor green;
	foreach($suborganization in $organization.ChildResourceGroups)
	{
		Write-Host "--->" $suborganization.Name -ForegroundColor green;
	}
}

Write-Host "Now let's try to add a new user."
$userName = "APIUser_$studioVersion";
$userDisplayName = "API User $StudioVersion";
$userEmailAddress = "api@api.com";
$userDescription = "User created using API";
$userPassword = "ClearP@123";

Get-User $manager $allOrganizations.ParentResourceGroupId $userName $userDisplayName $userEmailAddress $userDescription $userPassword $true;

Write-Host "And now remove the newly added user."

Write-Host "Completed.";
Remove-ToolkitModules;
Remove-Module -name "ToolkitInitializer";