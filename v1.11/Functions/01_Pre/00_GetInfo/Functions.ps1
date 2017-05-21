#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log
#Requires -Modules hp_PSWrapper

<#
    .SYNOPSIS
        Get-Info
	.Description
      	PVS Requirements
    .NOTES
		Author: Patrik Horn
		Link:	www.makrofactory.com
		History:
        2016-08-25 - Change Variable Name
		2016-08-12 - Add Get-IniFile to read INI Files
      	2016-07-30 - Script created (PHo)
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
    
    $Diskspace = Get-WMIObject Win32_Logicaldisk -filter "deviceid='C:'" 

    $CTX_Personality = Get-IniFile "C:\Personality.ini"

    $Message =  "Username: $env:USERNAME" + [System.Environment]::NewLine + ` 
                "Computername: $env:COMPUTERNAME" + [System.Environment]::NewLine + `
                "HDD Size in GB: $([math]::Round($Diskspace.Size/1GB,2))" + [System.Environment]::NewLine +
                "HDD Free in GB: $([math]::Round($Diskspace.Freespace/1GB,2))" + [System.Environment]::NewLine +
                "HDD Used in GB: $([math]::Round(($Diskspace.Size-$Diskspace.Freespace)/1GB,2))" + [System.Environment]::NewLine +
                "PVS Name: $($CTX_Personality.StringData.DiskName)" + [System.Environment]::NewLine + `
                "PVS Disk Mode: $($CTX_Personality.ArdenceData.DiskMode)"
	Write-Log_hp -Path $LogPS -Message $Message -Component $scriptName_Sub -Status Info

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