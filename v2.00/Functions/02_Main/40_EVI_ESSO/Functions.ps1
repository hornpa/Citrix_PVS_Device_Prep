#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log

<#
    .SYNOPSIS
        Evidian ESSO
	.Description
      	PVS Requirements
    .NOTES
		Author: Patrik Horn
		Link:	www.makrofactory.com
		History:
		2017-02-13 - Update Program detection (PHo)
		2016-09-22 - Add Registry who disabeld auto restart of security services (PHo)
		2016-08-26 - Added some registry keys (TNe)
        2016-07-30 - Optimiaze Output Messages (PHo)
      	2016-05-10 - Script created (PHo)
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

	$ProgramName = "User Access Client*"
	$ProgramVersion = "8.*"
	$ProgramVendor = "Evidian"
	
	IF ($InstalledPrograms | Where-Object {($_.Displayname -like $ProgramName) -and ($_.DisplayVersion -like $ProgramVersion) -and ($_.Publisher -like $ProgramVendor)})
	{
		$Msg = "$scriptName_Sub wurde erkannt."
		Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
		# If this key is not set to 1, the services will automatic restart
		New-ItemProperty -Path HKLM:\SOFTWARE\Enatel\WiseGuard\AdvancedLogin -Name "DontRestartSecurityServices" -Value 1 -PropertyType DWORD -ErrorAction SilentlyContinue | Out-Null
		Start-Sleep -Seconds 3
		Stop-Service -Name EvidianWGSS -Force -ErrorAction SilentlyContinue
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Enatel\WiseGuard\Framework\AccessPoint" -Name "ComputerID" -ErrorAction SilentlyContinue
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Enatel\WiseGuard\Framework\AccessPoint" -Name "LastRegisteredComputerName" -ErrorAction SilentlyContinue
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Enatel\WiseGuard\Framework\AccessPoint" -Name "LastRegisteredOSVersion" -ErrorAction SilentlyContinue
	}
	Else
	{
		$Msg = "Evidian ESSO wurde nicht auf dem System gefunden."
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