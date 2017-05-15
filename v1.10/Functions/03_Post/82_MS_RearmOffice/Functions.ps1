#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log

<#

.SYNOPSIS
    Rearm Office
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
    
    $ProgramName = "Microsoft Office*"
    $ProgramVersion = "*"
    $ProgramVendor = "Microsoft Corporation"

    IF ($InstalledPrograms | Where-Object {($_.Displayname -like $ProgramName) -and ($_.DisplayVersion -like $ProgramVersion) -and ($_.Publisher -like $ProgramVendor)})
	{
        
        $Msg = "One or more Office where found on the System."
        Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info

        #region Find Office Versions
        $OSPPREARM_2k10x86 = "${env:CommonProgramFiles(x86)}\microsoft shared\OfficeSoftwareProtectionPlatform\OSPPREARM.EXE"
        $OSPPREARM_2k13x86 = "${env:ProgramFiles(x86)}\Microsoft Office\Office15\OSPPREARM.EXE"
        $OSPPREARM_2k16x86 = "${env:ProgramFiles(x86)}\Microsoft Office\Office16\OSPPREARM.EXE"
        $OSPPREARM = @()

        $Office = $InstalledPrograms | Where-Object {($_.Displayname -like $ProgramName)}

        Switch -Wildcard ($Office)
        {
        
            "*2010*"{
            $OSPPREARM += $OSPPREARM_2k10x86
            }
            "*2013*"{
            $OSPPREARM += $OSPPREARM_2k13x86
            }
            "*2016*"{
            $OSPPREARM += $OSPPREARM_2k16x86
            }
        
        }

        # Remove Dupilcates
        $OSPPREARM = $OSPPREARM | Sort-Object -unique

        #endregion

        #region ReArm OS
        Foreach ($Element in $OSPPREARM)
        {
        
            $Invoke = "$Element"

            try 
            { 
                $Msg = "Succesfully, rearmed Office $Element"
	            Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
                $Exe = . $Invoke
                $result = $true
            }
            catch 
            {
                $Msg = "Error, could not rearm Office $Element."
	            Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Error
                $result = $false
            }
        }
        #endregion

    }
    Else
    {

        $Msg = "No Office where found on the System."
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