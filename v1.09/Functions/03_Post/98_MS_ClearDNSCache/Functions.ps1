#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log

<#
    .SYNOPSIS
        Clear DNS Cache
	.Description
      	Clear DNS Cache
    .NOTES
		Author: Patrik Horn
		Link:	www.hornpa.de
		History:
		2016-09-22 - Add multi language support, de and us (PHo)
      	2016-04-08 - Script created (PHo)
#>

Begin {
#-----------------------------------------------------------[Pre-Initialisations]------------------------------------------------------------

#-----------------------------------------------------------[Functions]------------------------------------------------------------

#-----------------------------------------------------------[Main-Initialisations]------------------------------------------------------------

	Write-Verbose "Function: Clear Error Variable Count"
	$Error.Clear()
	Write-Verbose "Function: Get PowerShell Start Date"
	$StartPS_Sub = (Get-Date)
	Write-Verbose "Set Variable with MyInvocation"
	$scriptDirectory_Sub = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
	$scriptName_Sub = (Get-Help "$scriptDirectory_Sub\Functions.ps1").SYNOPSIS
	Write-Verbose "Function Name: $scriptName_Sub"
	Write-Verbose "Function Directory: $scriptDirectory_Sub"
    Write-Host "Function: $($scriptName_Sub)" -ForegroundColor Green
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Process {
	####################################################################
	## Code Section - Start
	####################################################################

	Write-Verbose "Check OS Langauge"
	Switch ($Language){
		"de-DE" {
		$Search_Text = "*wurde geleert*"
		}
		"en-US" {
		$Search_Text = "*Successfully*" 
		}
	}
	
	$ClearDNSCache = ipconfig /flushdns
	# Error Handling / Last Command
	IF ($ClearDNSCache -like $Search_Text)
	{
		$Msg = "Der DNS Cache wurde erfolgreich bereinigt."
		Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
	}
	Else
	{
		$Msg =  "Der DNS Cache konnte nicht bereinigt werden." + [System.Environment]::NewLine + "Die Fehlermeldung lautet:" + [System.Environment]::NewLine + $ClearDNSCache
		Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Error
	}

	####################################################################
	## Code Section - End
	####################################################################
}

#-----------------------------------------------------------[End]------------------------------------------------------------

End {
	Write-Verbose "Function: Get PowerShell Ende Date"
	$EndPS_Sub = (Get-Date)
	Write-Verbose "Function: Calculate Elapsed Time"
	$ElapsedTimePS_Sub = (($EndPS_Sub-$StartPS_Sub).TotalSeconds)
	$Msg = "Elapsed Time: $ElapsedTimePS_Sub Seconds"
	Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
}