#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log

<#
    .SYNOPSIS
        CleanUp-Image
	.Description
      	Bereinigen des WinSxS-Ordners.
    .NOTES
		Author: 
         Patrik Horn (PHo)
		Link:	
         www.hornpa.de
		History:
         2016-11-XX - Added Disable option (PHo)
		 2016-09-22 - Add multi language support, de and us (PHo)
         2016-08-28 - Add Check if necessary (PHo)
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
    $scriptRunning = ($Settings_Global.Settings.Functions | select -ExpandProperty childnodes | Where-Object {$_.Name -like ($scriptName_Sub -replace " ","")} ).'#text'
	Write-Verbose "Function Name: $scriptName_Sub"
	Write-Verbose "Function Directory: $scriptDirectory_Sub"
    Write-Host "Function: $($scriptName_Sub)" -ForegroundColor Green
}
#-----------------------------------------------------------[Execution]------------------------------------------------------------

Process {
    IF ($scriptRunning  -like 1){
	####################################################################
	## Code Section - Start
	####################################################################
    
    $CMD = "C:\Windows\System32\cmd.exe"
    $CMD_ARG = "/C dism /online /cleanup-image "

    $CMD_ARG_SPSuperseded = "/SPSuperseded"
    $CMD_ARG_StartComponentCleanup = "/StartComponentCleanup /ResetBase"
    $CMD_ARG_AnalyzeComponentStore = "/AnalyzeComponentStore"

    $RUN_AnalyzeComponentStore = .$CMD ($CMD_ARG+$CMD_ARG_AnalyzeComponentStore)
	
	Write-Verbose "Check OS Langauge"
	Switch ($Language){
		"de-DE" {
		$Search_Text = "Bereinigung des Komponentenspeichers empfohlen"
		$Search_Result =  "Ja"
		}
		"en-US" {
		$Search_Text = "Component Store Cleanup Recommended" 
		$Search_Result =  "Yes"
		}
	}
	
	# Notiz - Switch Befehl für deutsches OS... 2016-08-31 PHo
    IF (($RUN_AnalyzeComponentStore | where-object {$_ –match $Search_Text} | foreach-object{$_.Split(“:”)[1].Trim()}) -like $Search_Result){

        $RUN_SPSuperseded = .$CMD ($CMD_ARG+$CMD_ARG_SPSuperseded)
        $RUN_StartComponentCleanup = .$CMD ($CMD_ARG+$CMD_ARG_StartComponentCleanup)

        $Message =  "Windows kann bereinigt werden" + [System.Environment]::NewLine + `
                    "AnalyzeComponentStore: " + [System.Environment]::NewLine + `
                    "$RUN_AnalyzeComponentStore" + [System.Environment]::NewLine + `
                    "SPSuperseded:" + [System.Environment]::NewLine + `
                    "$RUN_SPSuperseded" + [System.Environment]::NewLine + `
                    "StartComponentCleanup: " + [System.Environment]::NewLine + `
                    "$RUN_StartComponentCleanup"

        Write-Log_hp -Path $LogPS -Message $Message -Component $scriptName_Sub -Status Info

        }Else{

        $Message =  "Windows muss nicht bereinigt werden." + [System.Environment]::NewLine + `
                    "AnalyzeComponentStore: " + [System.Environment]::NewLine + `
                    "$RUN_AnalyzeComponentStore"

		Write-Log_hp -Path $LogPS -Message $Message -Component $scriptName_Sub -Status Info

    }

	####################################################################
	## Code Section - End
	####################################################################
    }Else{
        $Message =  "Function wird nicht ausgefuehrt laut XML Datei."  + [System.Environment]::NewLine + `
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