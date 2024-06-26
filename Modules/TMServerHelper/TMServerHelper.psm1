<#
	.SYNOPSIS
	Connects to TM Server.

	.DESCRIPTION
	Connects to the TMServer by accessing the provided server address with the given credentials.

	.PARAMETER serverAddress
	Represents the server for the TM.

	.PARAMETER userName

	.PARAMETER password

	.EXAMPLE
	Get-TMServer "http://localhost/" "sa" "sa"
#>
function Get-TMServer
{
	param(
		[String] $serverAddress,
		[String] $userName,
		[String] $password)
		
	$uri = New-Object System.Uri ($serverAddress);
	$tmServer = New-Object Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer ($uri,$false,$userName,$password);
	return $tmServer;
}

<#
	.SYNOPSIS
	Return all DB servers associated with TM Server.

	.PARAMETER server
	Represents the TMServer object.
#>
function Get-DbServers
{
	param([Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] $server)
	#consider using DatabaseServerProperties enum properly to speed up the processing, you would like to avoid getting properties one by one
	return $server.GetDatabaseServers();
}

<#
	.SYNOPSIS
	Return all containers associated with TM Server.

	.PARAMETER server
	Represents the TMServer object.
#>
function Get-Containers
{
	param([Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] $server)
	#consider using ContainerProperties enum properly to speed up the processing, you would like to avoid getting properties one by one
	return $server.GetContainers()
}

<#
	.SYNOPSIS
	Return all TMs associated with TM Server.

	.PARAMETER server
	Represents the TMServer object.
#>
function Get-TMs
{
	param([Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] $server)
	
	return $server.GetTranslationMemories();
}

<#
	.SYNOPSIS
	Returns an existing container or creates a new one.

	.DESCRIPTION
	Returns a container if the specified container is found or creates a new one if no container is found and createNew parameter is true
	Or
	Returns a specified container or null if createNew parameter is false

	.PARAMETER server
	Represents the TM Server

	.PARAMETER dbServer
	Represents the Database server from the server

	.PARAMETER containerName
	The name of the container to search

	.PARAMETER createNew
	A boolean value indicating whether to create a new container or not if the specified container was not found

	.EXAMPLE
	Get-Container -server ([Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] existingServer)
			-dbServer ([Sdl.LanguagePlatform.TranslationMemoryApi.DatabaseServer] existingDatabaseServer)
			-containerName "ExistingContainer"
			-createNew $true

	returns the container with ExistingContainer name.
	
	.EXAMPLE
	Get-Container -server ([Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] existingServer)
			-dbServer ([Sdl.LanguagePlatform.TranslationMemoryApi.DatabaseServer] existingDatabaseServer)
			-containerName "ExistingContainer"
			-createNew $false

	returns the container with ExistingContainer name.

	.EXAMPLE
	Get-Container -server ([Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] existingServer)
			-dbServer ([Sdl.LanguagePlatform.TranslationMemoryApi.DatabaseServer] existingDatabaseServer)
			-containerName "NonExistingContainer"
			-createNew $true

	Creates a new container with the name NonExistingContainer and then returns it

	.EXAMPLE
	Get-Container -server ([Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] existingServer)
			-dbServer ([Sdl.LanguagePlatform.TranslationMemoryApi.DatabaseServer] existingDatabaseServer)
			-containerName "NonExistingContainer"
			-createNew $true

	Returns null
#>
function Get-Container
{
	param(
		[Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] $server,
		[Sdl.LanguagePlatform.TranslationMemoryApi.DatabaseServer] $dbServer,
		[System.String] $containerName,
		[System.Boolean] $createNew)
	
	$container = $null;
	$containers = Get-Containers $server;
	foreach ($current in $containers)
	{
		if ($current.Name -eq $containerName)
		{
			$container = $current;
		}
	}

	if($container -eq $null -and $createNew -eq $true)
	{
		#if container doesn't exist let's create one
        $container = New-Object Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryContainer ($server);
        $container.DatabaseServer = $dbServer;
        $container.DatabaseName = $containerName + "DB";
        $container.Name = $containerName;
        $container.ParentResourceGroupPath = $dbServer.ParentResourceGroupPath;
        $container.Save();
	}

	return $container;
}

<#
	.SYNOPSIS
	Returns specified TM. If TM doesn't exist and $createNew is set to true new TM is created.

	.DESCRIPTION
	Verify if any server based translation memory exists and if exists it returns it and ignores the other parameters
	If a serverbased translation memory is not found and createNew is set to true, creates a new serverbased translation memory and returns it
	otherwise returns null.

	.PARAMETER server
	Represents the TM Server
	
	.PARAMETER container
	Represents existing container

	.PARAMETER name
	The name of the serverbased translation memory

	.PARAMETER sourceLanguage
	The source language for the TM

	.PARAMETER targetLanguage
	The target language for the TM

	.PARAMETER createNew
	A value indicating whether to create a new serverbased translationmemory if no translation memory was found.

	.EXAMPLE
	Get-ServerBasedTM -server ([Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] tmServer)
		-container ([Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryContainer] existingContainer)
		-tmName "ExistingTM"
		-sourceLanguage ([System.Globalization.CultureInfo] en-US)
		-targetLanguage([System.Globalization.CultureInfo] de-DE)
		-createNew $true

	returns the existing TM.

	.EXAMPLE
	Get-ServerBasedTM -server ([Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] tmServer)
		-container ([Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryContainer] existingContainer)
		-tmName "ExistingTM"

	returns the existing TM.

	.EXAMPLE
	Get-ServerBasedTM -server ([Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] tmServer)
		-container ([Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryContainer] existingContainer)
		-tmName "NonExistingTM"
		-sourceLanguage ([System.Globalization.CultureInfo] en-US)
		-targetLanguage([System.Globalization.CultureInfo] de-DE)
		-createNew $true

	creates a new translation memory and returns it.

	.EXAMPLE
	Get-ServerBasedTM -server ([Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] tmServer)
		-container ([Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryContainer] existingContainer)
		-tmName "NonExistingTM"
		-sourceLanguage ([System.Globalization.CultureInfo] en-US)
		-targetLanguage([System.Globalization.CultureInfo] de-DE)
		-createNew $true

	returns null
#>
function Get-ServerBasedTM
{
	param(
		[Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] $server,
		[Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryContainer] $container,
		[System.String] $tmName,
		[System.Globalization.CultureInfo] $sourceLanguage,
		[System.Globalization.CultureInfo] $targetLanguage,
		[System.Boolean] $createNew)

	#consider using TranslationMemoryProperties enum properly to speed up the processing, you would like to avoid getting properties one by one
	[Sdl.LanguagePlatform.TranslationMemoryApi.ServerBasedTranslationMemory]$tm = $server.GetTranslationMemory($container.ParentResourceGroupPath + "/" + $tmName,
	[Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryProperties]::None);
	
	if($tm -eq $null -and $createNew -eq $true)
	{
		$tm = New-Object Sdl.LanguagePlatform.TranslationMemoryApi.ServerBasedTranslationMemory($server);
        $tm.Container = $container;
        $tm.Name = $tmName;
        $tm.Description = "A sample created as example of using TM API.";
        $tm.ParentResourceGroupPath = $container.ParentResourceGroupPath;
		#create language direction
		$tmDirection = New-Object Sdl.LanguagePlatform.TranslationMemoryApi.ServerBasedTranslationMemoryLanguageDirection($null);
		$tmDirection.SourceLanguage = $sourceLanguage;
		$tmDirection.TargetLanguage = $targetLanguage;
		#add into server TM
		$tm.LanguageDirections.Add($tmDirection);
		#if required a custom language resources (e.g. abbreviations) can be added programatically as well
        $tm.Save();
	}
	return $tm;
}

<#
	.SYNOPSIS
	Delete specified TM.

	.PARAMETER tmToDelete
	Represents an existing server based Translation Memory
#>
function Remove-TM
{
	param([Sdl.LanguagePlatform.TranslationMemoryApi.ServerBasedTranslationMemory] $tmToDelete)
	$tmToDelete.Delete();
}

<#
	.SYNOPSIS
	Delete specified container. You can set if the Database should be also deleted

	.PARAMETER containerToDelete
	Represents an existing container.
#>
function Remove-Container
{
	param(
		[Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryContainer] $containerToDelete)
	
		$containerToDelete.Delete();
}

<#
	.SYNOPSIS
	Imports TMX into specified TM

	.DESCRIPTION
	Import a TMX file from the Given Location to the given Server Based Translation Memory

	.PARAMETER tmForImport
	Represents the translation memory used for the import

	.PARAMETER importFilePath
	Represents the file location of the import

	.EXAMPLE
	Import-Tmx -tmForImport ([Sdl.LanguagePlatform.TranslationMemoryApi.ServerBasedTranslationMemory] existingServerTranslationMemory)
		-importFilePath "D:\Location\To\File.tmx"
#>
function Import-Tmx
{
	# Use TranslationMemoryImporter class
	param(
		[Sdl.LanguagePlatform.TranslationMemoryApi.ServerBasedTranslationMemory] $tmForImport,
		[System.String] $importFilePath)

	#pick first language direction - needs to be changed to pick the actual one
	$languageDirection = $tmForImport.LanguageDirections[0];

	$importer = New-Object Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryImporter ($languageDirection);
	$importer.Import($importFilePath);
}

<#
	.SYNOPSIS
	Exports a server based Translation Memory to the given location.

	.DESCRIPTION
	Extract the TMX from an existing Server Based Translation Memory and saves it to the given export location

	.PARAMETER tmForExport
	Represents the translation memory used for the export

	.PARAMETER exportFilePath
	Represents the location where the Tmx will be saved

	.EXAMPLE
	Import-Tmx -tmForExport ([Sdl.LanguagePlatform.TranslationMemoryApi.ServerBasedTranslationMemory] existingServerTranslationMemory)
		-exportFilePath "D:\Location\To\File.tmx"
#>
function Export-Tmx
{
	param(
		[Sdl.LanguagePlatform.TranslationMemoryApi.ServerBasedTranslationMemory] $tmForExport,
		[System.String] $exportFilePath
	)

	$languageDirection = $tmForImport.LanguageDirections[0];

	$exporter = New-Object Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryExporter($languageDirection);
	$exporter.Export($exportFilePath, $true);
}

Export-ModuleMember Get-TMServer;
Export-ModuleMember Get-DbServers;
Export-ModuleMember Get-Containers;
Export-ModuleMember Get-TMs;
Export-ModuleMember Get-Container;
Export-ModuleMember Get-ServerBasedTM; 
Export-ModuleMember Remove-TM; 
Export-ModuleMember Remove-Container;
Export-ModuleMember Import-Tmx;
Export-ModuleMember Export-Tmx;