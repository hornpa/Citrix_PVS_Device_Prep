!include "MUI.nsh"
!include FileFunc.nsh

!define VAR_VENDOR "hornpa"
!define VAR_PRODUCT "Citrix PVS Device Prep"
!define VAR_VERSION "2.00"
!define VAR_URL "http://www.hornpa.de"
!define VAR_FILEPATHS "S:\_IT\PowerShell\hp_Citrix_PVS_Device_Prep\v${VAR_VERSION}"

Name "${VAR_VENDOR} - ${VAR_PRODUCT} - ${VAR_VERSION}"
OutFile "S:\_IT\PowerShell\hp_Citrix_PVS_Device_Prep\${VAR_VENDOR}_${VAR_PRODUCT}_${VAR_VERSION}.exe"
InstallDir "$PROGRAMFILES64\${VAR_VENDOR}\${VAR_PRODUCT}"

!insertmacro MUI_PAGE_components
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

!insertmacro GetParameters
!insertmacro GetOptions

Function .onInit
	${GetParameters} $R0
	${GetOptionsS} $R0 "/s" $0
	IfErrors +2 0
	SetSilent silent
	ClearErrors
FunctionEnd

Section "${VAR_PRODUCT}"

	SetOutPath $INSTDIR
	File /r "${VAR_FILEPATHS}"
	
	WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${VAR_PRODUCT}" "UninstallString" "$INSTDIR\v${VAR_VERSION}\uninstall.exe"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${VAR_PRODUCT}" "DisplayName" "${VAR_PRODUCT}"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${VAR_PRODUCT}" "DisplayVersion" "${VAR_VERSION}"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${VAR_PRODUCT}" "Publisher" "${VAR_VENDOR}"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${VAR_PRODUCT}" "URLInfoAbout" "${VAR_URL}"
	WriteRegDword HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${VAR_PRODUCT}" "NoModify" "00000001"
	WriteRegDword HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${VAR_PRODUCT}" "NoRepair" "00000001" 
	
	WriteUninstaller $INSTDIR\v${VAR_VERSION}\uninstall.exe
	
SectionEnd

Section "Administrative Start Menu Shortcuts"

	SetShellVarContext all
	CreateShortCut "$SMPROGRAMS\Administrative Tools\${VAR_PRODUCT}.lnk" "$INSTDIR\v${VAR_VERSION}\Main.cmd" "" "$INSTDIR\v${VAR_VERSION}\Main.cmd" 0
	
SectionEnd

Section /o "Current User Desktop Shortcut"

	SetShellVarContext current
	CreateShortCut "$DESKTOP\${VAR_PRODUCT}.lnk" "$INSTDIR\v${VAR_VERSION}\Main.cmd" "" "$INSTDIR\v${VAR_VERSION}\Main.cmd" 0
	
SectionEnd

Section "Uninstall"

	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${VAR_PRODUCT}"
	
	Delete $INSTDIR\v${VAR_VERSION}\uninstall.exe
	
	RMDir /r $INSTDIR
	
	SetShellVarContext all
	Delete "$SMPROGRAMS\Administrative Tools\${VAR_PRODUCT}.lnk"
	
	SetShellVarContext current
	Delete "$DESKTOP\${VAR_PRODUCT}.lnk"
	
SectionEnd