#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log

<#
    .SYNOPSIS
        Antivirus Sophos
	.Description
      	PVS Requirements
    .NOTES
		Author: Patrik Horn
		Link:	www.hornpa.de
		History:
      	2016-07-10 - Script created (PHo)
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
	Stop-Service -Name "Sophos Agent" -Force -ErrorAction SilentlyContinue
	Stop-Service -Name "Sophos AutoUpdate Service" -Force -ErrorAction SilentlyContinue
	Stop-Service -Name "Sophos Message Router" -Force -ErrorAction SilentlyContinue

    Write-Verbose "Delete Registry Settings..."
	Remove-ItemProperty -Path "HKLM:\Software\Sophos\Messaging System\Router\Private" -Name "pkc" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Sophos\Messaging System\Router\Private" -Name "pkp" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Sophos\Remote Management System\ManagementAgent" -Name "pkc" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Sophos\Remote Management System\ManagementAgent" -Name "pkp" -ErrorAction SilentlyContinue

    Write-Verbose "Delete Files..."
    Remove-Item -Path "C:\ProgramData\Sophos\AutoUpdate\data\machine_ID.txt" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\ProgramData\Sophos\AutoUpdate\data\status\status.xml" -Force -ErrorAction SilentlyContinue
    
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