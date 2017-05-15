#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log

<#

.SYNOPSIS
    Rearm OS
.Description
    -
.NOTES
    Author: Patrik Horn (PHo)
    Link:	www.hornpa.de
    History:
    2017-04-26 - Script created (PHo)

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
    
    #region Check ReArm Count
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform"
    $RegName = "SkipRearm"
    $RegValue = (Get-ItemProperty -Path $RegPath -Name $RegName).$RegName

    IF ($RegValue -gt 0)
    {
    
        $Msg = "The current ReArm count is $RegValue, will be reset to 0..."
        Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
        Try
        {

            $Msg = "successfully" 
            Set-ItemProperty -Path $RegPath -Name $RegName -Value 1
	        Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info

        }
        Catch
        {

            $Msg = "error, could not reset Key to 0"
            Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Error

        }

    }
    Else
    {
        
        $Msg = "The current ReArm count is $RegValue, everything is fine."
        Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
    
    }
    #endregion

    #region ReArm OS
    $cscript = "$env:windir\system32\cscript.exe" 
    $Invoke = $cscript + " " + "slmgr.vbs /ReArm"

    try 
    { 
        $Msg = "Succesfully, rearmed OS"
	    Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
        $Exe = Invoke-Expression $Invoke
        $result = $true
    }
    catch 
    {
        $Msg = "Error, could not rearm OS."
	    Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Error
        $result = $false
    }
    #endregion
	
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