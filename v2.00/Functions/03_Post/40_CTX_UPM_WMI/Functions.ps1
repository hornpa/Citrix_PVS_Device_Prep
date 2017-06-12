#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log
#Requires -Modules hp_Stuff

<#

.SYNOPSIS
    Citrix UPM WMI Reload
.Description
    Sometimes the WMI Names is lost This functions reload them.
.NOTES
    Author: Patrik Horn (PHo)
    Link:	www.hornpa.de
    History:
    2017-06-04 - Changed option from XML to Popup Windows and added try and catch (PHo)
    2016-11-XX - Added Disable option (PHo)
    2016-08-05 - Script created (PHo)

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
    $scriptRunning = New-Popup -Title "Make a decision" -Message ("Should the ""$scriptName_Sub"" function be executed?"  + [System.Environment]::NewLine + "(Time Out in 15 seconds, Default answer is Yes)") -Time 15 -Buttons YesNo -Icon Question
	Write-Verbose "Function Name: $scriptName_Sub"
	Write-Verbose "Function Directory: $scriptDirectory_Sub"
    Write-Host "Function: $($scriptName_Sub)" -ForegroundColor Green
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Process {
    IF ( ($scriptRunning -eq -1) -or ($scriptRunning -eq 6) ){
	####################################################################
	## Code Section - Start
	####################################################################

    $NETFrameWork64 = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\installutil.exe"

    $UPM_WMI_Metrics_DLL = "$env:ProgramFiles\Citrix\Virtual Desktop Agent\upmWmiMetrics.dll"
    $UPM_WMI_Admin_DLL = "$env:ProgramFiles\Citrix\Virtual Desktop Agent\upmWmiAdmin.dll"

	IF ((Test-Path $NETFrameWork64 ) -and (Test-Path $UPM_WMI_Metrics_DLL) -and (Test-Path $UPM_WMI_Admin_DLL))
	{

        Try
        {
            $RUN_UPM_WMI_Metrics_DLL = .$NETFrameWork64 $UPM_WMI_Metrics_DLL
            if ($LastExitCode -ne 0)
               { throw $RUN_UPM_WMI_Metrics_DLL }    
            $Message = "WMI Metrics erfolgreich neu registriert."
            Write-Log_hp -Path $LogPS -Message $Message -Component $scriptName_Sub -Status Info
        }
        Catch
        {
            $Message = "WMI Metrics konnte nicht neu registriert werden."
            Write-Log_hp -Path $LogPS -Message $Message -Component $scriptName_Sub -Status Error
        }
 
        Try
        {
            $RUN_UPM_WMI_Admin_DLL = .$NETFrameWork64 $UPM_WMI_Admin_DLL
            if ($LastExitCode -ne 0)
               { throw $RUN_UPM_WMI_Admin_DLL }    
            $Message = "WMI Admin erfolgreich neu registriert."
            Write-Log_hp -Path $LogPS -Message $Message -Component $scriptName_Sub -Status Info
        }
        Catch
        {
            $Message = "WMI Admin konnte nicht neu registriert werden."
            Write-Log_hp -Path $LogPS -Message $Message -Component $scriptName_Sub -Status Error
        }

	}
	Else
	{
		$Message = "$scriptName_Sub nicht auf dem System gefunden."
		Write-Log_hp -Path $LogPS -Message $Message -Component $scriptName_Sub -Status Warning
	}

	####################################################################
	## Code Section - End
	####################################################################
    }Else{
        $Message =  "Function wird nicht ausgefuehrt."  + [System.Environment]::NewLine + `
                    "$scriptName_Sub Wert lautet $scriptRunning."
        Write-Log_hp -Path $LogPS -Message $Message -Component $scriptName_Sub -Status Warning
    }
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