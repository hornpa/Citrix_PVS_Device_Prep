####################################################################
$PSM_Name = "PSWrapper - PowerShell Module"
$PSM_Notes =@"
Author:	Patrik Horn
Link:	www.hornpa.de
History:
2016-08-12 - v1.01 - Add Get-IniFile, Out-IniFile (PHo)
2016-05-10 - v1.00 - Release (PHo)
"@
####################################################################
Write-Verbose "PSM Module: $PSM_Name "
Write-Verbose "PSM Notes: $PSM_Notes "
####################################################################
Write-Verbose "Loading Functions..."
# -------------------------------------------------------------------
function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Test-Transcribing {
	$externalHost = $host.gettype().getproperty("ExternalHost",
		[reflection.bindingflags]"NonPublic,Instance").getvalue($host, @())

	try {
	    $externalHost.gettype().getproperty("IsTranscribing",
		[reflection.bindingflags]"NonPublic,Instance").getvalue($externalHost, @())
	} catch {
             write-warning "This host does not support transcription."
         }
}

# Source http://www.remkoweijnen.nl/blog/2014/07/29/handling-ini-files-powershell/
# PHo: Change regex Setting to read settings with '$' and '_'
function Get-IniFile {
    param (
    	[parameter(mandatory=$true, position=0, valuefrompipelinebypropertyname=$true, valuefrompipeline=$true)][string]$FilePath
    )

	$ini = New-Object System.Collections.Specialized.OrderedDictionary
	$currentSection = New-Object System.Collections.Specialized.OrderedDictionary
	$curSectionName = "default"

	switch -regex (gc $FilePath)
	{
	    "^\[(?<Section>.*)\]"
	    {
			$ini.Add($curSectionName, $currentSection)
			
			$curSectionName = $Matches['Section']
			$currentSection = New-Object System.Collections.Specialized.OrderedDictionary	
	    }
		"(?<Key>.*)\=(?<Value>.*)"
		{
			# add to current section Hash Set
			$currentSection.Add(($Matches['Key'] -replace "(['$''_'])"), $Matches['Value'])
		}
		"^$"
		{
			# ignore blank line
		}
		 
		"(?<Key>\;)(?<Value>.*)"
		{
			$currentSection.Add($Matches['Key'], $Matches['Value'])	  
		}
			default
		{
			throw "Unidentified: $_"  # should not happen
		}
	}
	if ($ini.Keys -notcontains $curSectionName) { $ini.Add($curSectionName, $currentSection) }
	
	return $ini
}

# Source http://www.remkoweijnen.nl/blog/2014/07/29/handling-ini-files-powershell/
function Out-IniFile{
    param (
    	[parameter(mandatory=$true, position=0, valuefrompipelinebypropertyname=$true, valuefrompipeline=$true)][System.Collections.Specialized.OrderedDictionary]$ini,
		[parameter(mandatory=$false,position=1, valuefrompipelinebypropertyname=$true, valuefrompipeline=$false)][String]$FilePath
    )
	
	$output = ""
	ForEach ($section in $ini.GetEnumerator())
	{
		if ($section.Name -ne "default") 
		{ 
			# insert a blank line after a section
			$sep = @{$true="";$false="`r`n"}[[String]::IsNullOrWhiteSpace($output)]
			$output += "$sep[$($section.Name)]`r`n" 
		}
		ForEach ($entry in $section.Value.GetEnumerator())
		{
			$sep = @{$true="";$false="="}[$entry.Name -eq ";"]
			$output += "$($entry.Name)$sep$($entry.Value)`r`n"
		}
		
	}
	
	$output = $output.TrimEnd("`r`n")
	if ([String]::IsNullOrEmpty($FilePath))
	{
		return $output
	}
	else
	{
		$output | Out-File -FilePath $FilePath -Encoding:ASCII
	}
}

# -------------------------------------------------------------------
Write-Verbose "Finished"