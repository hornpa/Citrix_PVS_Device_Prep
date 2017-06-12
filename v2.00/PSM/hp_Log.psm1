####################################################################
$PSM_Name = "Logging - PowerShell Module"
$PSM_Autor =  "Patrik Horn"
$PSM_URL = "http://www.hornpa.de"
####################################################################
Write-Verbose "PSM Module: $PSM_Name "
Write-Verbose "PSM Date: $PSM_Date "
Write-Verbose "PSM URL: $PSM_URL "
####################################################################
Write-Verbose "Loading Functions..."
# -------------------------------------------------------------------
Function Write-Log_hp { 
 <#
    .SYNOPSIS
     Write-Log_hp
    .DESCRIPTION
     Erstellt ein Configuration Manager Trace freundliches Log mit zusätzliche Ausgabe auf der Console.
    .PARAMETER Path
     Vollständiger Pfad zum wo das Log gespeichert werden soll.
    .PARAMETER Message
     Die Nachricht welche im Log und auf der Console angezeigt werden soll.
    .PARAMETER Component
     Möglichkeit das Log in in Componenten auf zuteilen.
    .PARAMETER Status
     Gibt an ob es bei dem Eintrag um eine Info, Warnung oder Fehler handelt.
    .PARAMETER Prefix
     Gibt an ob es bei dem Eintrag um eine Info, Warnung oder Fehler handelt.
    .PARAMETER NoOutput
     Verhindert die Ausgabe auf der Console.
    .EXAMPLE
     Write-Log_hp -Path "C:\Temp\Test.log" -Value "Das ist ein Test" -Component "Test" -Status Info -NoOutput
    .EXAMPLE
     Write-Log_hp -Path "C:\Temp\Test.log" -Value "Das ist ein Test" -Component "Test" -Status Warning
    .EXAMPLE
     Write-Log_hp -Path "C:\Temp\Test.log" -Value "Das ist ein Test" -Status Error
    .EXAMPLE
     Write-Log_hp -Path "C:\Temp\Test.log" -Value "Das ist ein Test" -Component "Test" -Status Info -Prefix " - "
    .NOTES
      Author: 
        Patrik Horn
	  Link:	
        www.hornpa.de
	  History:
       2016-11-05 - Update code, new function No Console Output, change Severity to Status with validateset, completed informations (PHo)
       2016-07-29 - Update code and new function (PHo)
       2015-XX-XX - Script created (PHo)
#>
[CmdletBinding()] 
Param( 
      #Path to the log file 
      [parameter(Mandatory=$true)] 
      [String]$Path, 
 
      #The information to log 
      [parameter(Mandatory=$true)]
      [alias("Value")] 
      [String]$Message, 
 
      #The source of the error 
      [parameter(Mandatory=$false)] 
      [String]$Component = "Unknown", 
 
      #The Status (1 - Information, 2- Warning, 3 - Error) 
      [parameter(Mandatory=$false)] 
      [ValidateSet("Info","Warning","Error")] 
      [String]$Status,

      #The severity (1 - Information, 2- Warning, 3 - Error) for Legacy Support
      [parameter(,Mandatory=$false,DontShow)] 
      [ValidateRange(1,3)] 
      [Single]$Severity,
      
      #No Console Output
      [parameter(Mandatory=$false)] 
      [String]$Prefix, 

      #No Console Output
      [parameter(Mandatory=$false)] 
      [Switch]$NoOutput 

) 

# Check If Folder Exist
$Folder = Split-Path $Path
if (!(Test-Path -path $Folder)) {
    Write-Verbose "Create Folder"
    New-Item $LogFolder -Type Directory
}

# Change Status to Severity
Switch -Wildcard ($Status){
    Info {$Severity = "1"}
    Warning {$Severity = "2"}
    Error {$Severity = "3"}
}

#Obtain UTC offset 
$DateTime = New-Object -ComObject WbemScripting.SWbemDateTime  
$DateTime.SetVarDate($(Get-Date)) 
$UtcValue = $DateTime.Value 
$UtcOffset = $UtcValue.Substring(21, $UtcValue.Length - 21) 

#Create the line to be logged 
$LogLine =  "<![LOG[$($Prefix+$Message)]LOG]!>" +` 
            "<time=`"$(Get-Date -Format HH:mm:ss.fff)$($UtcOffset)`" " +` 
            "date=`"$(Get-Date -Format M-d-yyyy)`" " +` 
            "component=`"$Component`" " +` 
            "context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " +` 
            "type=`"$Severity`" " +` 
            "thread=`"$([Threading.Thread]::CurrentThread.ManagedThreadId)`" " +` 
            "file=`"`">" 

# Write the line to the passed log file
Add-Content -Path $Path -Value $LogLine

# Check for Console Output 
IF ($NoOutput){
        # Do Notihng
    }Else{
    # Write the line to the console
    Switch ($Severity){
        1{Write-Host ($Prefix+$Message)}
        2{Write-Warning ($Prefix+$Message)}
        3{Write-Error ($Prefix+$Message) -ErrorAction Continue}
    }
}

}


# -------------------------------------------------------------------
Write-Verbose "Finished"