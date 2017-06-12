#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log

<#

.SYNOPSIS
    Clear Folder
.Description
    Clear Folder that defined in the XML File
.NOTES
    Author: Patrik Horn
    Link:	www.hornpa.de
    History:
    2017-06-04 - Removed "Costum option" (PHo)
    2017-01-30 - Bug fixing wrong paths in xml and expand try and catch (PHo)
    2016-08-02 - Update Log Output (PHo)
    2016-05-17 - Added Costum Part (PHo)
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

	[XML]$Settings = Get-Content -Path "$scriptDirectory_Sub\SettingsFile.xml"
	$Folders = $Settings.Settings.RemoveFolders.Folder
    $Folders_Costum = $Settings_Global.Settings.Costum.RemoveFolders.Folder
	$i = 1
    # Main Settings
	Foreach($Folder in $Folders){
		Write-Progress -Activity "Folders" -status "Remove Folder $Folder" -percentComplete ($i / $Folders.count*100)
		# Error Handling mit try catch finaly Block (Error Code bleibt Leer)
		try
		{
			# Achtung ohne ErrorACtion funktioniert der try catch Block nicht!
			Remove-Item $Folder -recurse -Force -ErrorAction Stop
			$Msg = "Ordner $Folder wurde gelöscht."
			Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
		}
		Catch [System.Management.Automation.ItemNotFoundException]
		{
			$Msg = "Ordner $Folder nicht vorhanden." 
			Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
		}
		catch [System.IO.IOException]
		{
			$Msg = "Ordner $Folder ist in verwendung."
			Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
		}
		Catch
		{
			$Msg = "Es ist unbekannter Fehler aufgetreten. Bitte Prüfen. Ordner $Folder."
			Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Warning
		}
		#$Error[0] | FL * -Force # Mit Diesem Befehlt bekommt man den entsprechend Fehler Code für den Catch Block
		sleep -Seconds 1
		$i++
	}

	Write-Progress -Activity "Folders" -status "Remove Folder $Folder" -completed
	Remove-Variable i

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