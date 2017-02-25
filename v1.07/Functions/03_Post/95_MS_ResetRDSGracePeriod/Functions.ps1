#Requires -Version 3.0
#Requires -RunAsAdministrator 
#Requires -Modules hp_Log

<#
    .SYNOPSIS
        Reset RDS Grace Period
	.Description
      	Defuse RDS Time Bomb
    .NOTES
		Author: Patrik Horn
		Link:	www.hornpa.de
        Based on: https://gallery.technet.microsoft.com/Reset-Terminal-Server-RDS-44922d91
		History:
		2016-08-31 - Add Language (PHo
      	2016-08-26 - Script created (PHo)
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
    
$definition = @"
using System;
using System.Runtime.InteropServices; 
namespace Win32Api
{
	public class NtDll
	{
		[DllImport("ntdll.dll", EntryPoint="RtlAdjustPrivilege")]
		public static extern int RtlAdjustPrivilege(ulong Privilege, bool Enable, bool CurrentThread, ref bool Enabled);
	}
}
"@ 
	
	# Notiz ggf. Out-Null um Ausgabe in der Konsole zu unterdrücken... 2016-08-31 PHo
    Add-Type -TypeDefinition $definition -PassThru
    $bEnabled = $false

	Write-Verbose "Check OS Langauge"
	Switch ($Language){
		"de-DE" {
		$ADM_Group = "Administratoren"
		}
		"en-US" {
		$ADM_Group = "Administrators" 
		}
	}
	
	$Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod'

	IF (Test-Path $Path) 
	{
		$Msg =  "RDS Timebomb (Grace Period) wurde gefunden! Wird auf 120 Tage zurueckgesetzt"
		Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
		
		Write-Verbose "Enable SeTakeOwnershipPrivilege"
		$res = [Win32Api.NtDll]::RtlAdjustPrivilege(9, $true, $false, [ref]$bEnabled)

		Write-Verbose "Take Ownership on the Key"
		$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod", [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::takeownership)
		$acl = $key.GetAccessControl()
		$acl.SetOwner([System.Security.Principal.NTAccount]"$ADM_Group")
		$key.SetAccessControl($acl)

		Write-Verbose "Assign Full Controll permissions to Administrators on the key."
		$rule = New-Object System.Security.AccessControl.RegistryAccessRule ("$ADM_Group","FullControl","Allow")
		$acl.SetAccessRule($rule)
		$key.SetAccessControl($acl)

		Write-Verbose "Finally Delete the key which resets the Grace Period counter to 120 Days."
		Remove-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod'
	}
	Else
	{
		$Msg =  "RDS Timebomb (Grace Period) wurde nicht gefunden!"
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