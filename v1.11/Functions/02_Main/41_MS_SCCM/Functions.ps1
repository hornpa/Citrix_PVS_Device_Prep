#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log

<#
    .SYNOPSIS
        Microsoft SCCM Agent
	.Description
      	PVS Requirements
    .NOTES
		Author: Patrik Horn
		Link:	www.hornpa.de
		History:
        2016-08-12 - Add ErrorAction SilentlyContinue (PHo)
        2016-07-30 - Optimiaze Output Messages (PHo)
      	2016-05-18 - Script created (PHo)
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

	$SCCM_Path = "C:\Windows\CCM"
	$SCCM_EXE = "ccmexec.exe"
	$SCCM_INI = "SMSCFG.INI"
	$SCCM_Service = "CcmExec"
	
	IF ($Services | Where-Object {$_.Name -like $SCCM_Service})
	{
		$Msg = "$scriptName_Sub auf dem System gefunden."
		Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
		# Stop SCCM Agent
		Stop-Service -Name $SCCM_Service  -Force -ErrorAction SilentlyContinue
		# Remove INI
		Remove-Item -Path $SCCM_Path$SCCM_INI -Force -ErrorAction SilentlyContinue
		# Delete SMS Cert Store
		& Invoke-Expression 'certutil -delstore SMS "SMS"'
	}
	Else
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