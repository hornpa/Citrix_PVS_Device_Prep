#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log

<#

.SYNOPSIS
    Clear Event Logs
.Description
    All Event Logs will be cleared.
.NOTES
    Author: 
    Patrik Horn (PHo)
    Link:	
    www.hornpa.de
    History:
    2017-15-05 - Bug fixing "can not delete" (PHo)
    2016-11-XX - Added Disable option (PHo)
    2016-07-29 - Optimize Output (PHo)
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
	Write-Verbose "Set plete ($i / $Eventlogs.count*100)
        
        Try
        {
            wevtutil cl "$Entry"  

        }
        Catch
        {

            $Message = "Cloud not delete $($Entry)"
            Write-Log_hp -Path $LogPS -Message $Message -Component $scriptName_Sub -Status Warning
        
        }

		Write-Verbose "Das Log $Entry wurde gel??scht."
		$i++
	}
	Remove-Variable i

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