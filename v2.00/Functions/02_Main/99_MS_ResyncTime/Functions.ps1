#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log
#Requires -Modules hp_Stuff

<#

.SYNOPSIS
    Resync Time
.Description
    Resync Time with Domain Controller
.NOTES
    Author: Patrik Horn (PHo)
    Link:	www.hornpa.de
    History:
    2017-06-04 - Changed option from XML to Popup Windows (PHo)
    2016-11-XX - Added Disable option (PHo)
    2016-08-01 - Update Log Output (PHo)
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

	$Service = Get-Service -Name W32Time
	if ($Service.Status -eq "Stopped") 
	{
		$Service.Start()
		$Service.WaitForStatus("Running")
	}
	$RUN = w32tm.exe /config /update
	$RUN = w32tm.exe /resync

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