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

#Source: https://powershell.org/2013/04/29/powershell-popup/
Function New-Popup {

<#
.Synopsis
Display a Popup Message
.Description
This command uses the Wscript.Shell PopUp method to display a graphical message
box. You can customize its appearance of icons and buttons. By default the user
must click a button to dismiss but you can set a timeout value in seconds to 
automatically dismiss the popup. 

The command will write the return value of the clicked button to the pipeline:
  OK     = 1
  Cancel = 2
  Abort  = 3
  Retry  = 4
  Ignore = 5
  Yes    = 6
  No     = 7

If no button is clicked, the return value is -1.
.Example
PS C:\> new-popup -message "The update script has completed" -title "Finished" -time 5

This will display a popup message using the default OK button and default 
Information icon. The popup will automatically dismiss after 5 seconds.
.Notes
Last Updated: April 8, 2013
Version     : 1.0

.Inputs
None
.Outputs
integer

Null   = -1
OK     = 1
Cancel = 2
Abort  = 3
Retry  = 4
Ignore = 5
Yes    = 6
No     = 7
#>

Param (
[Parameter(Position=0,Mandatory=$True,HelpMessage="Enter a message for the popup")]
[ValidateNotNullorEmpty()]
[string]$Message,
[Parameter(Position=1,Mandatory=$True,HelpMessage="Enter a title for the popup")]
[ValidateNotNullorEmpty()]
[string]$Title,
[Parameter(Position=2,HelpMessage="How many seconds to display? Use 0 require a button click.")]
[ValidateScript({$_ -ge 0})]
[int]$Time=0,
[Parameter(Position=3,HelpMessage="Enter a button group")]
[ValidateNotNullorEmpty()]
[ValidateSet("OK","OKCancel","AbortRetryIgnore","YesNo","YesNoCancel","RetryCancel")]
[string]$Buttons="OK",
[Parameter(Position=4,HelpMessage="Enter an icon set")]
[ValidateNotNullorEmpty()]
[ValidateSet("Stop","Question","Exclamation","Information" )]
[string]$Icon="Information"
)

#convert buttons to their integer equivalents
Switch ($Buttons) {
    "OK"               {$ButtonValue = 0}
    "OKCancel"         {$ButtonValue = 1}
    "AbortRetryIgnore" {$ButtonValue = 2}
    "YesNo"            {$ButtonValue = 4}
    "YesNoCancel"      {$ButtonValue = 3}
    "RetryCancel"      {$ButtonValue = 5}
}

#set an integer value for Icon type
Switch ($Icon) {
    "Stop"        {$iconValue = 16}
    "Question"    {$iconValue = 32}
    "Exclamation" {$iconValue = 48}
    "Information" {$iconValue = 64}
}

#create the COM Object
Try {
    $wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
    #Button and icon type values are added together to create an integer value
    $wshell.Popup($Message,$Time,$Title,$ButtonValue+$iconValue)
}
Catch {
    #You should never really run into an exception in normal usage
    Write-Warning "Failed to create Wscript.Shell COM object"
    Write-Warning $_.exception.message
}

} 

# -------------------------------------------------------------------
Write-Verbose "Finished"