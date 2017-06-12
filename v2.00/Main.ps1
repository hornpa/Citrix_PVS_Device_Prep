#Requires -Version 3.0
#Requires -RunAsAdministrator

<#

.SYNOPSIS
    CTX PVS Device Prep
.Description
    -
.NOTES
    Author: Patrik Horn (PHo)
    Link:	www.hornpa.de
    History:
	Look at "ReleaseNotes.txt"
#>

Begin {
#-----------------------------------------------------------[Pre-Initialisations]------------------------------------------------------------

	#Set Error Action to Silently Continue
	$ErrorActionPreference = 'Stop'

	#Set Verbose Output
	$VerbosePreference = "SilentlyContinue" # Continue = Shows Verbose Output / SilentlyContinue = No Verbose Output

	#Get Start Time
	$StartPS = (Get-Date)

	#Set Enviorements
	Write-Verbose "Set Variable with MyInvocation"
	If ($($Host.Name) -like "* ISE *") 
	{ # Running script from Windows Powershell ISE
        $PSScriptFullName = $psise.CurrentFile.FullPath.ToLower()
        $scriptName_PS = Split-Path $psise.CurrentFile.FullPath.ToLower() -Leaf
        $scriptDirectory = Split-Path -Path $psise.CurrentFile.FullPath.ToLower() -Parent
    } 
	ELSE 
	{
        $PSScriptFullName = $MyInvocation.MyCommand.Definition.ToLower()
        $scriptName_PS = Split-Path $MyInvocation.MyCommand -Leaf
        $scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
    }
    $scriptHelp = Get-Help "$scriptDirectory\$scriptName_PS" -Full
    $scriptName_SYNOPSIS = $scriptHelp.SYNOPSIS
    $scriptName_NOTES =  Get-Content "$scriptDirectory\ReleaseNotes.txt"
	$scriptDebug = 0 # 0 = Disabled / 1 = Enabled
	
	# Load the Windows Forms assembly
	Add-Type -Assembly System.Windows.Forms

	#Check Log Folder
	Write-Verbose "Log Variables"
	$LogPS = "$env:windir\Logs\Scripts\"+(Get-Date -Format yyyy-MM-dd_HHmm)+"_"+$scriptName_SYNOPSIS+".log"
	IF (!(Test-Path (Split-Path $LogPS)))
	{
		Write-Verbose "Create Log Folder"
		New-Item (Split-Path $LogPS) -Type Directory | Out-Null
	}

#-----------------------------------------------------------[Functions]------------------------------------------------------------

	#Load all PowerShell Modules
	Write-Verbose "Load PowerShell Modules..."
	Foreach ($PSModule in (Get-ChildItem ($scriptDirectory+"\PSM") -Recurse -Filter "*.psm1")){
		Import-Module $PSModule.FullName -Force
		Write-Verbose "---"
	}

#-----------------------------------------------------------[Main-Initialisations]------------------------------------------------------------

	# Host Output
    $WelcomeMessage =   "##################################"  + [System.Environment]::NewLine + `
                        " $scriptName_SYNOPSIS"  + [System.Environment]::NewLine + `
                        " "  + [System.Environment]::NewLine + `
                        " $scriptName_NOTES"+ [System.Environment]::NewLine + `
                        "##################################"
                        
	Write-Host $WelcomeMessage -ForegroundColor Gray

    ## Load Preq
    Write-Host "Load Environments" -ForegroundColor Cyan
    [XML]$Settings_Global = Get-Content -Path "$scriptDirectory\SettingsGlobal.xml"
	$Personality = Get-IniFile "C:\Personality.ini" -ErrorAction SilentlyContinue
    $GUILanguage = (Get-Culture).Name
	$InstalledLanguages = (Get-WmiObject -Class Win32_OperatingSystem).MUILanguages
    $OS = Get-WmiObject -Class win32_operatingsystem
	$Services = Get-Service
	Write-Host "Load list with Installed Programs" -ForegroundColor Cyan
    $InstalledPrograms_x64 = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*
    $InstalledPrograms_x86 = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* 
    $InstalledPrograms = $InstalledPrograms_x64 + $InstalledPrograms_x86
	Write-Host "Load Functions List" -ForegroundColor Cyan
    $LoadFunctions_Pre = Get-ChildItem -Path "$scriptDirectory\Functions\01_Pre" -Include "Functions.ps1" -Recurse
    $LoadFunctions_Main = Get-ChildItem -Path "$scriptDirectory\Functions\02_Main" -Include "Functions.ps1" -Recurse
    $LoadFunctions_Costum = Get-ChildItem -Path "$scriptDirectory\Functions\99_Costum" -Include "Functions.ps1" -Recurse
    $LoadFunctions_AV = Get-ChildItem -Path "$scriptDirectory\Functions\98_Antivirus" -Include "Functions.ps1" -Recurse
    $LoadFunctions_Post = Get-ChildItem -Path "$scriptDirectory\Functions\03_Post" -Include "Functions.ps1" -Recurse
    ## Unblock all ps1 Files in Directory
    $UnblockFiles = Get-ChildItem -Path $scriptDirectory -Recurse -Filter "*.ps1" | Unblock-File
	## Progressbar (LoadFunction + LoadFunction + 1[Section AV])
    $ProgressBar_Summary = $LoadFunctions_Pre.Count + $LoadFunctions_Main.Count + $LoadFunctions_Costum.Count + 1 + $LoadFunctions_Post.Count
    $ProgressBar_Current = 0
	
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------


Process {
	####################################################################
	## Code Section - Start
	####################################################################

	#region Check if Disk Standard or Private Mode
	Write-Host "Checking Disk Mode" -ForegroundColor Cyan
	IF ($scriptDebug -like 0)
	{
		IF (($Personality.StringData.DiskMode -like "P*") -or ($Personality.ArdenceData.DiskMode -like "P"))
		{
			$Msg = 	"Disk befindet sich im Private Mode" + [System.Environment]::NewLine + "Das Skript wird weiter ausgefuehrt!"
			Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
		}
		Else
		{
			$Form_Titel = 	"Abbruch Skript"
			$Form_Message = "Disk befindet sich im Standard Mode!" + [System.Environment]::NewLine + "Das Skript wird abgebrochen!"
			Write-Log_hp -Path $LogPS -Message $Form_Message -Component $scriptName_Sub -Status Error
			New-Popup -Title $Form_Titel -Message $Form_Message -Buttons OK -Icon Exclamation | Out-Null
			Exit
		}
	}
    #endregion
	
    #region Run Functions Pre
    $Msg_Section = "Section Pre"
    Write-Host $Msg_Section -ForegroundColor Cyan 
    Foreach ($Function in $LoadFunctions_Pre){
        $FunctionName = Split-Path (Split-Path $Function.FullName) -Leaf
        $Msg_Status = " Running... $FunctionName"
        Write-Verbose $Msg_Status 
        $ProgressBar_Current++
        Write-Progress -Activity $Msg_Section -Status $Msg_Status -PercentComplete ([math]::Round((100*$ProgressBar_Current)/$ProgressBar_Summary))
        IF ($scriptDebug -like 0)
		{
			.($Function.FullName)
        }
	}
    #endregion

    #region Run Functions Main
    $Msg_Section = "Section Main"
    Write-Host $Msg_Section -ForegroundColor Cyan 
    Foreach ($Function in $LoadFunctions_Main){
        $FunctionName = Split-Path (Split-Path $Function.FullName) -Leaf
        $Msg_Status = " Running... $FunctionName"
        Write-Verbose $Msg_Status 
        $ProgressBar_Current++
        Write-Progress -Activity $Msg_Section -Status $Msg_Status -PercentComplete ([math]::Round((100*$ProgressBar_Current)/$ProgressBar_Summary))
        IF ($scriptDebug -like 0)
		{
			.($Function.FullName)
        }
	}
    #endregion

    #region Run Functions Costum
    $Msg_Section = "Section Costum"
    Write-Host $Msg_Section -ForegroundColor Cyan 
    Foreach ($Function in $LoadFunctions_Costum){
        $FunctionName = Split-Path (Split-Path $Function.FullName) -Leaf
        $Msg_Status = " Running... $FunctionName"
        Write-Verbose $Msg_Status 
        $ProgressBar_Current++
        Write-Progress -Activity $Msg_Section -Status $Msg_Status -PercentComplete ([math]::Round((100*$ProgressBar_Current)/$ProgressBar_Summary))
        IF ($scriptDebug -like 0)
		{
			.($Function.FullName)
        }
	}
    #endregion

    #region Run Functions AV
    $Msg_Section = "Section AV"
    Write-Host $Msg_Section -ForegroundColor Cyan 
    Switch -Wildcard ($InstalledPrograms.Name) 
	{
            "*Trend Micro OfficeScan Client*" 
			{
                Write-Verbose "Trend Micro office Scan Client erkannt!"
                $Msg = "AV: Trend Micro OfficeScan auf dem System gefunden."
                $ProgressBar_Current++
                Write-Progress -Activity $Msg_Section -Status $Msg -PercentComplete ([math]::Round((100*$ProgressBar_Current)/$ProgressBar_Summary))
				Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
				IF ($scriptDebug -like 0)
				{
			        ."$scriptDirectory\Functions\98_AntivirusTrend Micro OfficeScan Client\Functions.ps1"
				}
            }
            "*McAfee Agent*" 
			{
                Write-Verbose "McAffe erkannt!"
                $Msg = "AV: McAfee auf dem System gefunden."
                $ProgressBar_Current++
                Write-Progress -Activity $Msg_Section -Status $Msg -PercentComplete ([math]::Round((100*$ProgressBar_Current)/$ProgressBar_Summary))
				Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
				IF ($scriptDebug -like 0)
				{
					."$scriptDirectory\Functions\98_Antivirus\McAffee\Functions.ps1"
				}
            }
            "*Sophos*" 
			{
                Write-Verbose "Sophos erkannt!"
                $Msg = "AV: Sophos auf dem System gefunden."
                $ProgressBar_Current++
                Write-Progress -Activity $Msg_Section -Status $Msg -PercentComplete ([math]::Round((100*$ProgressBar_Current)/$ProgressBar_Summary))
				Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
				IF ($scriptDebug -like 0)
				{
					."$scriptDirectory\Functions\98_Antivirus\Sophos Client\Functions.ps1"
				}
            }
    }
    #endregion

    #region Run Functions Post
    $Msg_Section = "Section Post"
    Write-Host $Msg_Section -ForegroundColor Cyan 
    Foreach ($Function in $LoadFunctions_Post){
        $FunctionName = Split-Path (Split-Path $Function.FullName) -Leaf
        $Msg_Status = " Running... $FunctionName"
        Write-Verbose $Msg_Status 
        $ProgressBar_Current++
        Write-Progress -Activity $Msg_Section -Status $Msg_Status -PercentComplete ([math]::Round((100*$ProgressBar_Current)/$ProgressBar_Summary))
        IF ($scriptDebug -like 0)
		{
			.($Function.FullName)
        }
	}
    #endregion

	####################################################################
	## Code Section - End
	####################################################################
}

#-----------------------------------------------------------[End]------------------------------------------------------------

End {
    #region End Skript
    Write-Verbose "Get PowerShell Ende Date"
    $EndPS = (Get-Date)
	$ElapsedTimePS = (($EndPS-$StartPS).TotalSeconds)
    $Msg = "Elapsed Time: $ElapsedTimePS Seconds"
	Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
    #endregion

    #region Shutdown Computer
	IF ($scriptDebug -like 0)
	{
        $Shutdown = New-Popup -Title "Make a decision" -Message ("Should the computer be shut down?"  + [System.Environment]::NewLine + "(Time Out in 15 seconds, Default answer is Yes)") -Time 15 -Buttons YesNo -Icon Question
		IF ( ($scriptRunning -eq -1) -or ($scriptRunning -eq 6) )
		{
            $Msg_Section = "Finish Action: "
			$Msg = "Shutdown in 60 seconds"
            $ProgressBar_Current++
            Write-Progress -Activity $Msg_Section -Status $Msg -PercentComplete ([math]::Round((100*$ProgressBar_Current)/$ProgressBar_Summary))
            $Msg = "$Msg_Section Shutdown in 60 seconds"
			Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
			Start-Sleep -Seconds 60
            Try
            {
                Stop-Computer -Force
            }
            Catch
            {
                $Msg = "Finish Action: couldn't Shutdown with PowerShell command. Using ""shutdown.exe"""
                Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Info
                Start-Process -FilePath shutdown.exe -ArgumentList "/s /t 0 /f"
            }
		}
		Else
		{
			$Msg = "Finish Action: No Shutdown"
			Write-Log_hp -Path $LogPS -Message $Msg -Component $scriptName_Sub -Status Warning
		}
	}
    #endregion
}