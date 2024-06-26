<#
	.SYNOPSIS
	Creates a new file based TM.

	.DESCRIPTION
	Creates a file based Translation Memory given the path of the file to be created, description, source and target languages with
	- Default FuzzyIndexes, Recognizers, TokenizerFlags and WordCountFlags
	- Custom FuzzyIndexes, Recognizers, TokenizerFlags and WordCountFlags

	.PARAMETER filePath
	Represents the location where the TM will be located after creation.

	.PARAMETER description
	Represents the description of the TM

	.PARAMETER sourceLanguageName
	Represents the source language of the TM

	.PARAMETER targetLanguageName
	Represents the target language of the TM

	.PARAMETER fuzzyIndexes
	Reprezents the fuzzyIndexes options given or the default ones if paramter not provided.
	
	.PARAMETER recognizers
	Reprezents the recognizers options given or the default ones if paramter not provided.

	.PARAMETER tokenizerFlags
	Reprezents the tokenizer flags options given or the default ones if paramter not provided

	.PARAMETER wordCountFlag
	Reprezents the word count options given or the default ones if paramter not provided

	.EXAMPLE
	New-FileBasedTM -filePath "D:\Path\To\TM.sdltm" -description "TM Description" -sourceLanguageName "en-US" -targetLanguageName "de-DE";
#>
function New-FileBasedTM
{
param(
	[String] $filePath,
	[String] $description,
	[String] $sourceLanguageName,
	[String] $targetLanguageName,
	[Sdl.LanguagePlatform.TranslationMemory.FuzzyIndexes] $fuzzyIndexes = $(Get-DefaultFuzzyIndexes),
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers] $recognizers = $(Get-DefaultRecognizers),
	[Sdl.LanguagePlatform.Core.Tokenization.TokenizerFlags] $tokenizerFlags = $(Get-DefaultTokenizerFlags),
	[Sdl.LanguagePlatform.TranslationMemory.WordCountFlags] $wordCountFlag = $(Get-DefaultWordCountFlags)
	)

$sourceLanguage = Get-CultureInfo $sourceLanguageName;
$targetLanguage = Get-CultureInfo $targetLanguageName; 

return New-Object Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemory(
	$filePath, 
	$description,
	$sourceLanguage,
	$targetLanguage,
	$fuzzyIndexes,
	$recognizers,
	$tokenizerFlags,
	$wordCountFlag);
}

<#
	.SYNOPSIS
	Open an existing file based TM

	.DESCRIPTION
	Open and return a filse based TM based on the provided location.

	.PARAMETER filePath
	Reprezents the tm file location

	.EXAMPLE
	Open-FileBasedTM "D:\Path\To\TM.sdltm"
#>
function Open-FileBasedTM
{
	param([String] $filePath)
	[Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemory] $tm = 
	New-Object Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemory ($filePath);
	
	return $tm;
}

<#
	.SYNOPSIS
	Gets the target language of a given TM

	.DESCRIPTION
	Reads the target language of an existing TM based on the provided location.

	.PARAMETER filePath
	Location of the TM file

	.EXAMPLE
	Get-TargetTMLanguage "D:\Path\To\TM.sdltm"
#>
function Get-TargetTMLanguage
{
	param([String] $filePath)
	
	[Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemory] $tm = Open-FileBasedTM $filePath;
	[Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemoryLanguageDirection] $direction = $tm.LanguageDirection;
	return $direction.TargetLanguage;	
}

<#
	.SYNOPSIS
	Translates a string to a Trados Language.

	.DESCRIPTION
	Gets the [Sdl.Core.Globalization.Language] language as an object based on the provided language string

	.PARAMETER languageName
	Represents the language definition

	.EXAMPLE
	Get-Language "en-US"
#>
function Get-Language
{
	param([String] $languageName)
	
	[Sdl.Core.Globalization.Language] $language = New-Object Sdl.Core.Globalization.Language ($languageName)
	return $language;
}

<#
	.SYNOPSIS
	Translates multiple strings to a Trados Languages.

	.DESCRIPTION
	Gets [Sdl.Core.Globalization.Language] languages as an array of object based on the provided language strings

	.PARAMETER languageName
	Represents the list of language definitions

	.EXAMPLE
	Get-Language @("en-US", "de-DE")
#>
function Get-Languages
{
	param([String[]] $languageNames)
	[Sdl.Core.Globalization.Language[]]$languages = @();
	foreach($lang in $languageNames)
	{
		$newlang = Get-Language $lang;
		
		$languages = $languages + $newlang
	}

	return $languages
}

function Get-CultureInfo {
	param(
		[String] $Language
	)

	$CultureInfo = Get-Language $Language
	return $CultureInfo.CultureInfo
}

function Get-DefaultFuzzyIndexes
{
	 return [Sdl.LanguagePlatform.TranslationMemory.FuzzyIndexes]::SourceCharacterBased -band 
	 	[Sdl.LanguagePlatform.TranslationMemory.FuzzyIndexes]::SourceWordBased -band
		[Sdl.LanguagePlatform.TranslationMemory.FuzzyIndexes]::TargetCharacterBased -band
		[Sdl.LanguagePlatform.TranslationMemory.FuzzyIndexes]::TargetWordBased;
}

function Get-DefaultRecognizers
{
	return [Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeAcronyms -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeAll -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeDates -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeMeasurements -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeNumbers -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeTimes -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeVariables;
}

function Get-DefaultTokenizerFlags
{
	return [Sdl.LanguagePlatform.Core.Tokenization.TokenizerFlags]::DefaultFlags;
}

function Get-DefaultWordCountFlags
{
	return [Sdl.LanguagePlatform.TranslationMemory.WordCountFlags]::DefaultFlags;
}

Export-ModuleMember New-FileBasedTM;
Export-ModuleMember Get-Language;
Export-ModuleMember Get-Languages;
Export-ModuleMember Open-FileBasedTM;
Export-ModuleMember Get-CultureInfo;
Export-ModuleMember Get-TargetTMLanguage;