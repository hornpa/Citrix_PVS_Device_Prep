#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log

<#
    .SYNOPSIS
        Release IP
	.Description
      	Release the IP for your Production NIC (not your PVS NIC)
    .NOTES
		Author: 
		 Patrik Horn
		Link:	
		 www.hornpa.de
		History:
		 2017-01-30 - Bug fixing wrong paths in xml(PHO)
		 2016-07-15 - Change Log Message
         2016-07-10 - Add Check for multi LAN-Adapter (PHo)
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

    Remove-Variable NIC_Found -ErrorAction SilentlyContinue
	$NIC = Get-NetAdapter
	$NICs_XML = $Settings_Global.Settings.Global.ReleaseIPAdressName
    $NICs_XML = $NICs_XML.Split(";")

    # Seaching for Network Interface Controllers

    Foreach ($NIC_Prod in  $NICs_XML){
        Write-Verbose "Searching for NIC : $NIC_Prod"
	    If ($NIC | Where-Object {$_.Name -like $NIC_Prod}) {
            Write-Verbose "Found NIC"
		    $Result = ipconfig /release $NIC_Prod
			$Msg = 	"LAN-Adapter $NIC_Prod wurde erkannt, Release IP...!"  + [System.Environment]::NewLine + `
						"$Result"
			Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
            $NIC_Found = $true
	    }

    }

    # Error Message and Log if no Adapter was found

    IF (!($NIC_Found)){
        Write-Verbose "Error - No NIC was found!"
        $Form_Titel = "Abbruch Skript"
		$Form_Message = "Der LAN-Adapter konnte nicht gefunden ($NIC_Prod)!"  + [System.Environment]::NewLine + `
						"Das Image wurde nicht sauber verschlossen!"  + [System.Environment]::NewLine + `
                        "Es kann zu fehlern bei der GPO verarbeitung kommen!"
		[System.Windows.Forms.MessageBox]::Show($Form_Message,$Form_Titel,0,[System.Windows.Forms.MessageBoxIcon]::Exclamation)
		Write-Log_hp -Path $LogPS -Message $Form_Message -Component $scriptName_Sub -Status Error
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