<#
	.SYNOPSIS
	Gets the task files of the given target language from an existing file based project.

	.DESCRIPTION
	Get the files from an existing filebased project based by the target language provided.

	.PARAMETER language
	The target language to be used to get the task files.

	.PARAMETER project
	An existing file based project.

	.EXAMPLE
	Get-TaskFileInfoFiles -language ([[Sdl.Core.Globalization.Language] targetLanguage)
		-project ([Sdl.ProjectAutomation.FileBased.FileBasedProject] existingProject)

#>
function Get-TaskFileInfoFiles
{
	param(
		[Sdl.Core.Globalization.Language] $language,
		[Sdl.ProjectAutomation.FileBased.FileBasedProject] $project)

	[Sdl.ProjectAutomation.Core.TaskFileInfo[]]$taskFilesList = @();
	
	foreach($taskfile in $project.GetTargetLanguageFiles($language))
	{
		$fileInfo = New-Object Sdl.ProjectAutomation.Core.TaskFileInfo;
		$fileInfo.ProjectFileId = $taskfile.Id;
		$fileInfo.ReadOnly = $false;
		$taskFilesList = $taskFilesList + $fileInfo;
	}
	return $taskFilesList;
}

<#
	.SYNOPSIS
	Removes an existing file based project.

	.DESCRIPTION
	Removes an existing file based project based on the project provided

	.PARAMETER projectToDelete
	The project to be removed

	.EXAMPLE
	Remove-Project -projectToDelete ([Sdl.ProjectAutomation.FileBased.FileBasedProject] projectToDelete)
#>
function Remove-Project
{
	param ([Sdl.ProjectAutomation.FileBased.FileBasedProject] $projectToDelete)
	$projectToDelete.Delete();
}

<#
	.SYNOPSIS
	Creates a new file based project.

	.DESCRIPTION
	Creates a new file based project. TM's are automatically assigned to the target languages.
	Following tasks are run automatically:
	- scan
	- convert to translatable format
	- copy to target languages
	- analyze
	- pretranslate

	.PARAMETER projectName
	Represents the name of the project

	.PARAMETER projectDestination
	Represents the destination where the project will be stored.

	.PARAMETER sourceLanguage
	Represents the source language of the project

	.PARAMETER targetLanguages
	Represents the target languages of the project.

	.PARAMETER pathToTMs
	Represents the path to the translation memories to be used in the project

	.PARAMETER sourceFilesFolder
	Represents the directory where the translatable files are located.

	.EXAMPLE
	New-Project -projectName "Sample Project" -projectDestination "D:\Destination\To\Project"
		-sourceLanguage ([Sdl.Core.Globalization.Language] sourceLanguage)
		-targetLanguages $([Sdl.Core.Globalization.Language] targetLanguage1, [Sdl.Core.Globalization.Language] targetLanguage2)
		-pathToTMs @("D:\Path\To\TM1.sdltm", "D:\Path\To\TM2.sdltm")
		-sourceFilesFolder "D:\Location\To\Source\Files"
#>
function New-Project
{
	param(
		[String] $projectName,
		[String] $projectDestination,
		[Sdl.Core.Globalization.Language] $sourceLanguage, 
		[Sdl.Core.Globalization.Language[]] $targetLanguages,
		[String[]] $pathToTMs,
		[String] $sourceFilesFolder)
	
	#create project info
	$projectInfo = new-object Sdl.ProjectAutomation.Core.ProjectInfo;
	$projectInfo.Name = $projectName;
	$projectInfo.LocalProjectFolder = $projectDestination;
	$projectInfo.SourceLanguage = $sourceLanguage;
	$projectInfo.TargetLanguages = $targetLanguages;
	
	#create file based project

	$fileBasedProject = New-Object Sdl.ProjectAutomation.FileBased.FileBasedProject $projectInfo

    #Copy-Item $pathSampleFile -Destination $sourceFilesFolder;
	$projectFiles = $fileBasedProject.AddFolderWithFiles($sourceFilesFolder, $false);

	#Assign TM's to project languages
	foreach($tmPath in $pathToTMs)
	{
		$tmTargetLanguageCulture = Get-TargetTMLanguage $tmPath;
		$tmTargetLanguage = Get-Language $tmTargetLanguageCulture.Name;
		[Sdl.ProjectAutomation.Core.TranslationProviderConfiguration] $tmConfig = $fileBasedProject.GetTranslationProviderConfiguration($tmTargetLanguage);
		$entry = New-Object Sdl.ProjectAutomation.Core.TranslationProviderCascadeEntry ($tmPath, $true, $true, $true);
		$tmConfig.Entries.Add($entry);
        $tmConfig.OverrideParent = $true;
		$fileBasedProject.UpdateTranslationProviderConfiguration($tmTargetLanguage, $tmConfig);	
	}

	#Get source language project files IDs
	[Sdl.ProjectAutomation.Core.ProjectFile[]] $projectFiles = $fileBasedProject.GetSourceLanguageFiles();
	[System.Guid[]] $sourceFilesGuids = Get-Guids $projectFiles;

	#run preparation tasks
	Confirm-Task $fileBasedProject.RunAutomaticTask($sourceFilesGuids,[Sdl.ProjectAutomation.Core.AutomaticTaskTemplateIds]::Scan);
	Confirm-Task $fileBasedProject.RunAutomaticTask($sourceFilesGuids,[Sdl.ProjectAutomation.Core.AutomaticTaskTemplateIds]::ConvertToTranslatableFormat);
	Confirm-Task $fileBasedProject.RunAutomaticTask($sourceFilesGuids,[Sdl.ProjectAutomation.Core.AutomaticTaskTemplateIds]::CopyToTargetLanguages);
	
	#run analyze and pretranslate
	foreach($targetLanguage in $targetLanguages)
	{
		#Get target language project files IDs
		$targetFiles = $fileBasedProject.GetTargetLanguageFiles($targetLanguage);
		[System.Guid[]] $targetFilesGuids = Get-Guids $targetFiles;

		# This is not working in beta
		Confirm-Task $fileBasedProject.RunAutomaticTask($targetFilesGuids,[Sdl.ProjectAutomation.Core.AutomaticTaskTemplateIds]::AnalyzeFiles);
		Confirm-Task $fileBasedProject.RunAutomaticTask($targetFilesGuids,[Sdl.ProjectAutomation.Core.AutomaticTaskTemplateIds]::PreTranslateFiles);
	}

	#save whole project
	$fileBasedProject.Save();
	return $fileBasedProject;
}

<#
	.SYNOPSIS
	Opens project on specified path.

	.DESCRIPTION
	Opens a file based project based on the location of the project

	.PARAMETER projectDestinationPath
	Destination of the file based project's directory

	.EXAMPLE
	Get-Project "D:\Path\To\Project"
#>
function Get-Project
{
	param([String] $projectDestinationPath)

	#open file based project
    $projectFilePath = Get-ChildItem $projectDestinationPath -Filter *.sdlproj -Recurse | ForEach-Object { $_.FullName };
	$fileBasedProject = New-Object Sdl.ProjectAutomation.FileBased.FileBasedProject($projectFilePath.ToString());
	return $fileBasedProject;
}

<#
	.SYNOPSIS
	Gets the given file based project's statistics

	.DESCRIPTION
	Gets the following statistics from the provided project:
	- Exact Matches (characters)
	- Exact Matches (words)
	- New Matches (characters)
	- New Matches (words)
	- New Matches (segments)
	- New Matches (placeable)
	- New Matches (tags)

	.PARAMETER project
	Represent the existing file based project

	.EXAMPLE
	Get-AnalyzeStatistics -project ([Sdl.ProjectAutomation.FileBased.FileBasedProject] existingProject)
#>
function Get-AnalyzeStatistics
{
	param([Sdl.ProjectAutomation.FileBased.FileBasedProject] $project)
	
	$projectStatistics = $project.GetProjectStatistics();
	
	$targetLanguagesStatistics = $projectStatistics.TargetLanguageStatistics;
	
	foreach($targetLanguageStatistic in  $targetLanguagesStatistics)
	{
		Write-Host ("Exact Matches (characters): " + $targetLanguageStatistic.AnalysisStatistics.Exact.Characters);
		Write-Host ("Exact Matches (words): " + $targetLanguageStatistic.AnalysisStatistics.Exact.Words);
		Write-Host ("New Matches (characters): " + $targetLanguageStatistic.AnalysisStatistics.New.Characters);
		Write-Host ("New Matches (words): " + $targetLanguageStatistic.AnalysisStatistics.New.Words);
		Write-Host ("New Matches (segments): " + $targetLanguageStatistic.AnalysisStatistics.New.Segments);
		Write-Host ("New Matches (placeables): " + $targetLanguageStatistic.AnalysisStatistics.New.Placeables);
		Write-Host ("New Matches (tags): " + $targetLanguageStatistic.AnalysisStatistics.New.Tags);
	}
}

function Confirm-Task
{
	param ([Sdl.ProjectAutomation.Core.AutomaticTask] $taskToValidate)

	if($taskToValidate.Status -eq [Sdl.ProjectAutomation.Core.TaskStatus]::Failed)
	{
		Write-Host "Task "$taskToValidate.Name"was not completed.";  
		foreach($message in $taskToValidate.Messages)
		{
			Write-Host $message.Message -ForegroundColor red ;
		}
	}
	if($taskToValidate.Status -eq [Sdl.ProjectAutomation.Core.TaskStatus]::Invalid)
	{
		Write-Host "Task "$taskToValidate.Name"was not completed.";  
		foreach($message in $taskToValidate.Messages)
		{
			Write-Host $message.Message -ForegroundColor red ;
		}
	}
	if($taskToValidate.Status -eq [Sdl.ProjectAutomation.Core.TaskStatus]::Rejected)
	{
		Write-Host "Task "$taskToValidate.Name"was not completed.";  
		foreach($message in $taskToValidate.Messages)
		{
			Write-Host $message.Message -ForegroundColor red ;
		}
	}
	if($taskToValidate.Status -eq [Sdl.ProjectAutomation.Core.TaskStatus]::Cancelled)
	{
		Write-Host "Task "$taskToValidate.Name"was not completed.";  
		foreach($message in $taskToValidate.Messages)
		{
			Write-Host $message.Message -ForegroundColor red ;
		}
	}
	if($taskToValidate.Status -eq [Sdl.ProjectAutomation.Core.TaskStatus]::Completed)
	{
		Write-Host "Task "$taskToValidate.Name"was completed." -ForegroundColor green;  
	}
}

Export-ModuleMember Remove-Project;
Export-ModuleMember New-Project;
Export-ModuleMember Get-Project;
Export-ModuleMember Get-AnalyzeStatistics;
Export-ModuleMember Get-TaskFileInfoFiles;