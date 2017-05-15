#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log

<#
    .SYNOPSIS
        Citrix Clear UPM Log
	.Description
      	PVS Requirements
    .NOTES
		Author: 
         Patrik Horn
		Link:	
         www.hornpa.de
		History:
		 2016-12-06 - Bug fixing getting UPM path (PHo)
      	 2016-11-08 - Script created (PHo)
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

    $Registry_Path = "HKLM:\SOFTWARE\Policies\Citrix\UserProfileManagerHDX"
    $LogFileName = $env:USERDNSDOMAIN+"#"+$env:COMPUTERNAME+"_pm.log"

    $UPMSettings = Get-ItemProperty -Path $Registry_Path -ErrorAction SilentlyContinue

    IF (Test-Path ($UPMSettings.PathToLogFile+"\"+$LogFileName))
	{
        $Msg = "Citrix UPM Logs gefunden, wird bereinigt..."
		Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
        Get-ChildItem $UPMSettings.PathToLogFile -Filter "*.log" | Remove-Item
	}
	Else
	{
        $Msg = "Kein Citrix UPM Logs gefunden."
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