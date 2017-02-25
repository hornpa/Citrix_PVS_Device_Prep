#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log

<#
    .SYNOPSIS
        Clear User Profiles
	.Description
      	Delete all Local User Profiles
    .NOTES
		Author: 
         Patrik Horn (PHo)
		Link:	
         www.hornpa.de
		History:
         2016-11-XX - Added Disable option (PHo)
      	 2016-07-29 - Script created (PHo)
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
    
    # Profile that shouldn't be deleted
    [XML]$Settings = Get-Content -Path "$scriptDirectory_Sub\SettingsFile.xml"
    $IgnoreProfiles = $Settings.CTX_PVS_Device_Prep_Settings.ClearUserProfie.Profile
    #$IgnoreProfiles = "Administrator","Benutzer","Netzwerkdienst","Lokaler Dienst","SYSTEM","LOCAL SERVICE","NETWORK SERVICE"
    
    # Get all Profiles on this Computer
    $Profiles = Get-WmiObject -Class Win32_UserProfile

    foreach ($profile in $profiles) {

        # Get the User Profile Name
        $objSID = New-Object System.Security.Principal.SecurityIdentifier($profile.sid)
        $objuser = $objsid.Translate([System.Security.Principal.NTAccount])
        $profilename = $objuser.Value.Split("\")[1]
        Write-Verbose "Profile $($profilename)"

        # The current User Profile will not be deleted
        IF ($profilename -like $env:USERNAME)
		{
            
            Write-Verbose "Is Current User will not be deleted"

		}
		Else
		{

            # Check  Profile if it should ignored
            IF (@($IgnoreProfiles -like $profilename)){

                Write-Verbose "Profile will not be deleted"

			}
			Else
			{

                Write-Verbose "Profile will deleted"

                # Delete User Profile
                Try
				{

                    Get-CimInstance win32_userprofile | Where {$_.SID -like $profile.SID} |Remove-CimInstance -ErrorAction Stop
                    $Message = "Profil von Benutzer $($profilename) wurde gelöscht."
					Write-Log_hp -Path $LogPS -Message $Message -Component $scriptName_Sub -Status Info

				}
				Catch
				{

                    $Message = "Profil von Benutzer $($profilename) konnte nicht geloescht werden."  + [System.Environment]::NewLine + `
                                    "$($error[0])"
					Write-Log_hp -Path $LogPS -Message $Message -Component $scriptName_Sub -Status Error

                }
            
            }

        }

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