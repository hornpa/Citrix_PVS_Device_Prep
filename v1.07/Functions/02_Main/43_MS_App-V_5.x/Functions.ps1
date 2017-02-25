#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log

<#
    .SYNOPSIS
        Microsoft App-V 5.x
	.Description
      	PVS Requirements
    .NOTES
		Author: Patrik Horn
		Link:	www.hornpa.de
		History:
        2017-02-13 - Update Program detection (PHo)
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

    $ProgramName = "Microsoft Application Virtualization*"
    $ProgramVersion = "5.*"
    $ProgramVendor = "Microsoft Corporation"
    IF ($InstalledPrograms | Where-Object {($_.Displayname -like $ProgramName) -and ($_.DisplayVersion -like $ProgramVersion) -and ($_.Publisher -like $ProgramVendor)})
	{
	    Write-Log_hp -Path $LogPS -Value "$scriptName_Sub wurde erkannt."
		Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
        # Check for SCS Enable
        $AppV_SCS_Mode = Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\AppV\Client\Streaming -Name SharedContentStoreMode
        IF ($AppV_SCS_Mode.SharedContentStoreMode -eq "1")
		{
		    $Msg = "Microsoft App-V SharedContentStoreMode ist aktiviert. Lösche alle vorhandene Pakete"
			Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
            Get-AppvClientPackage -All | Remove-AppvClientPackage
		    # Error Handling / Last Command
		    IF ($?)
			{
				$Msg = "Es konnten alle Pakete gelöscht werden."
				Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Warning
		    }
			Else
			{
				$LogErrorTxt = "Es konnten nicht alle Pakete gelöscht werden!"  + [System.Environment]::NewLine + `
							   "Die Fehlermeldung lautet:"  + [System.Environment]::NewLine + `
							   "$($error[0])"
				$Msg = "$LogErrorTxt"
				Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Error
		    }
            Remove-Item -Path "$env:ProgramData\App-V" -Force -Recurse -ErrorAction SilentlyContinue
		}
		Else
		{
		    $Msg = "Microsoft App-V SharedContentStoreMode ist deaktiviert. Keine weitere Aktionen vorgesehen"
			Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
		}
	}
	Else
	{
	    $Msg = "$scriptName_Sub  wurde nicht auf dem System gefunden."
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