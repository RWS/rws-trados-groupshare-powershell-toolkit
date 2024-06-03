cls
Write-Host "This script demonstrates how the PowerShell Toolkit can be used to automate small workflows";

Write-Host "Start with loading PowerShell Toolkit modules.";
Import-Module -Name ToolkitInitializer;

$studioVersion = "Studio17";
Import-ToolkitModules $studioVersion;


Write-Host "Now let's check the TM server.";
$server = Get-TMServer "http://wsamzn-ic6795n2.global.sdl.corp/" "sa" "sa";
Write-Host "Display all the DB servers.";
$dbServers = Get-DbServers $server;
foreach($dbServer in $dbServers)
{
	Write-Host $dbServer.Name -ForegroundColor green;
}

Write-Host "Display all the TM containers.";
$containers = Get-Containers $server;
foreach($container in $containers)
{
	Write-Host $container.Name "in organization" $container.ParentResourceGroupPath -ForegroundColor green;
}

Write-Host "Now let's look more closely on all the TMs.";
$tms = Get-TMs $server;
Write-Host "We have" $tms.Count "translation memories..."
foreach($tm in $tms)
{
	Write-Host $tm.Name "in container" $tm.Container.Name -ForegroundColor green;
}

Write-Host "Let's start doing some changes on the TM server.";
Write-Host "Get a container.";
$workingContainer = Get-Container $server $dbServers[0] "NewAPITest_$StudioVersion" $true;

Write-Host "Now create a TM.";
$serverTMSourceLang = Get-CultureInfo "en-US";
$serverTMTargetLang = Get-CultureInfo "de-DE";
$newTM = Get-ServerBasedTM $server $workingContainer "NewAPIMade $StudioVersion"  $serverTMSourceLang $serverTMTargetLang $true;

Write-Host "Now import a TMX file.";

$scriptPath = $MyInvocation.MyCommand.Path
$scriptParentDiv = Split-Path $scriptPath -Parent;

Import-Tmx $newTM "$scriptParentDiv\import.tmx";

Write-host "Finished";
Remove-ToolkitModules
Remove-Module -Name ToolkitInitializer