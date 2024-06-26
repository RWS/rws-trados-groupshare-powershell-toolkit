<#
	.SYNOPSIS
	Connects to User Management Server.
#>
function Get-UMServer
{
	param(
		[String] $serverAddress,
		[String] $userName,
		[String] $password)
	
	[Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.IdentityInfoCache] $cache =
		[Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.IdentityInfoCache]::Default; 

	if($cache.Count -gt 1)
	{
		$cache.ClearAllIdentities();
	}

	# [Sdl.Enterprise2.Platform.Client.IdentityModel.PersistOption]::None as a 4th parameter if not working on other versions
	$cache.SetCustomIdentity($serverAddress, $userName, $password);
	return $cache;
}

<#
	.SYNOPSIS
	Get all users
#>
function Get-UserManager
{
	param([Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.IdentityInfoCache] $cache)
	$manager = New-Object Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserManagerClient($cache.DefaultKey);	
	return $manager;
}

<#
	.DESCRIPTION
	Connects to User Management Server.
#>
function Get-AllUsers
{
	param([Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserManagerClient] $manager)
	$allUsers = $manager.GetAllUsers();
	return $allUsers;
}

<#
	.DESCRIPTION
	Returns specified User. If User doesn't exist and $createNew is set to true new User is created.
#>
function Get-User
{
	param(
		[Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserManagerClient] $manager,
		$organizationID,
		[String] $userName,
		[String] $userDisplayName,
		[String] $userEmailAddress,
		[String] $userDescription,
		[String] $userPassword,
		[Boolean] $createNew)

	$userID = $null;

	$user = $null;
	$users = Get-AllUsers $manager;
	foreach ($current in $users)
	{
		if ($current.Name -eq $userName)
		{
			return $current;
		}
	}

	if ($createNew -eq $false)
	{
		return $null;
	}

	$user = New-Object SDL.ApiClientSDK.GS.Models.UserDetails($null);
	$user.Name = $userName;
	$user.DisplayName = $userDisplayName;
	$user.Description = $userDescription;
	$user.OrganizationId = $organizationID;
	$user.EmailAddress = $userEmailAddress;

	$manager.AddUser($user, $userPassword);
	return $manager.GetUserByUserName($userName);
}

<#
	.DESCRIPTION
	Connects to User Management Server.
#>
function Get-AllOrganizations
{
	param([Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserManagerClient] $manager)

	$allResources = $manager.GetResourceGroupHierarchy();
	$allOrganizations = @();
	foreach($resource in $allResources)
	{
		if($resource.ResourceGroupType -eq 'ORG')
		{
			$allOrganizations = $allOrganizations + $resource;
		}
	}
	return $allOrganizations;
}

<#
	.DESCRIPTION
	Removes specified user.
#>
function Remove-User
{
	param(
		[Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserManagerClient] $manager,
		[Guid] $userID)

		$users = @($userID);

		$manager.DeleteUsers($users);
}

Export-ModuleMember Get-UMServer; 
Export-ModuleMember Get-UserManager;
Export-ModuleMember Get-AllUsers;
Export-ModuleMember Get-AllOrganizations;
Export-ModuleMember Get-User;
Export-ModuleMember Remove-User;