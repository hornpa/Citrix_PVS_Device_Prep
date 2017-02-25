#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log

<#
    .SYNOPSIS
        Antivirus Trend Micro Office Scan
	.Description
      	PVS Requirements
    .NOTES
		Author: Patrik Horn
		Link:	www.hornpa.de
		History:
        2016-07-10 - Code cleanup (PHo)
      	2016-05-09 - Script created (PHo)
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

    Write-Verbose "Stopping Services..."
	Stop-Service -Name tmlisten -Force -ErrorAction SilentlyContinue
	Stop-Service -Name ntrtscan -Force -ErrorAction SilentlyContinue

    Write-Verbose "Delete Registry Settings..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\TrendMicro\PC-cillinNTCorp\CurrentVersion" -Name "GUID" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\TrendMicro\PC-cillinNTCorp\CurrentVersion" -Name "IP" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\TrendMicro\PC-cillinNTCorp\CurrentVersion" -Name "MAC" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\TrendMicro\PC-cillinNTCorp\CurrentVersion" -Name "IP Template" -ErrorAction SilentlyContinue

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