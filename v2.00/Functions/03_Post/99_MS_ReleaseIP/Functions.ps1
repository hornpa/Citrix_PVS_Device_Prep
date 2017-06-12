#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log

<#

.SYNOPSIS
    Release IP
.Description
    Release the IP for your Production NIC (not your PVS NIC)
.NOTES
    Author: Patrik Horn
    Link:	www.hornpa.de
    History:
    2017-06-04 - Redesign Code from "foreach" to "compare" (PHo)
    2017-01-30 - Bug fixing wrong paths in xml (PHo)
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

	$NIC = (Get-NetAdapter).Name
	$NICs_XML = $Settings_Global.Settings.Global.ReleaseIPAdressName
    $NICs_XML = $NICs_XML.Split(";")

    # Check if Adapter match with the default list

    $CompareResult = Compare-Object -ReferenceObject $NICs_XML -DifferenceObject $NIC -ExcludeDifferent -IncludeEqual

    IF ( $CompareResult.InputObject.Count -eq 1 )
    {

        $NIC_Prod = $CompareResult.InputObject
        $Msg = "LAN-Adapter wurde gefunden!"
        Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info

    }
    ElseIF ( $CompareResult.InputObject.Count -ge 2 )
    {

        $Msg = "Es wurden mehrere LAN-Adapter uebereinstimmungen gefunden! Bitte Prüfen"
        Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
        $NIC_Prod = (Get-NetAdapter | Select-Object Name | Out-GridView -Title "Bitte LAN-Adapter für Ihre Produktion Netz (AD Zugriff) auswählen." -PassThru).Name
    
    }
    Else
    {

        $Msg = "Es konnte kein LAN-Adapter gefunden werden!"
        Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
        $NIC_Prod = (Get-NetAdapter | Select-Object Name | Out-GridView -Title "Bitte LAN-Adapter für Ihre Produktion Netz (AD Zugriff) auswählen." -PassThru).Name
    
    }


    # Seaching for Network Interface Controllers

    $Msg = 	"LAN-Adapter wurde erkannt ($($NIC_Prod))."
    Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
    $Result = ipconfig /release $NIC_Prod

    # Check if IP was released
    $ResultCheck = Get-NetIPAddress -InterfaceAlias $NIC_Prod
    IF ( $ResultCheck.IPAddress -like "169.*" )
    {

        $Msg = 	"IP Adresse für Adapter ($($NIC_Prod)) wurde erfolgreich freigegeben ($($ResultCheck.IPAddress))."
        Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info

    }
    Else
    {
			    
        $Form_Titel = "Fehler"
        $Form_Message = "Die IP Adresse konnte nicht freigeben! Bitte Prüfen!" + [System.Environment]::NewLine + "Es kann zu fehlern bei der GPO verarbeitung kommen!"
        New-Popup -Title $Form_Titel -Message $Form_Message -Buttons OK -Icon Exclamation | Out-Null
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