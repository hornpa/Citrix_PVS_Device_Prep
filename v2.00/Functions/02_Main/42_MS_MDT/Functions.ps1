#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log

<#
    .SYNOPSIS
        Microsoft Deployment Toolkit
	.Description
      	PVS Requirements
    .NOTES
		Author: Patrik Horn
		Link:	www.hornpa.de
		History:
        2016-07-30 - Optimiaze Output Messages (PHo)
      	2016-07-15 - Script created (PHo)
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

	$MDT1 = "C:\MININT"
	$MDT2 = "C:\_SMSTaskSequence"
	$MDT3 = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\LiteTouch.lnk"

	IF ((Test-Path $MDT1 ) -or (Test-Path $MDT2) -or (Test-Path $MDT3))
	{
		$Msg = "$scriptName_Sub wurde erkannt."
		Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
		Remove-Item -Path $MDT1 -Recurse -Force -ErrorAction SilentlyContinue
		Remove-Item -Path $MDT2 -Recurse -Force -ErrorAction SilentlyContinue
		Remove-Item -Path $MDT3 -Recurse -Force -ErrorAction SilentlyContinue
	}Else
	{
		$Msg = "$scriptName_Sub nicht auf dem System gefunden."
		Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
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