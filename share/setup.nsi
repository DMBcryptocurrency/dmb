Name NovaCoin

RequestExecutionLevel highest
SetCompressor /SOLID lzma

# General Symbol Definitions
!define REGKEY "SOFTWARE\$(^Name)"
!define VERSION 0.3.0
!define COMPANY "NovaCoin project"
!define URL http://www.novacoin.ru/

# MUI Symbol Definitions
!define MUI_ICON "../share/pixmaps/novacoin.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "../share/pixmaps/nsis-wizard.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP "../share/pixmaps/nsis-header.bmp"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_STARTMENUPAGE_REGISTRY_ROOT HKLM
!define MUI_STARTMENUPAGE_REGISTRY_KEY ${REGKEY}
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME StartMenuGroup
!define MUI_STARTMENUPAGE_DEFAULTFOLDER NovaCoin
#!define MUI_FINISHPAGE_RUN $INSTDIR\novacoin-qt.exe
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "../share/pixmaps/nsis-wizard.bmp"
!define MUI_UNFINISHPAGE_NOAUTOCLOSE

# Included files
!include Sections.nsh
!include MUI2.nsh

# Variables
Var StartMenuGroup

# Installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuGroup
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

# Installer languages
!insertmacro MUI_LANGUAGE English

# Installer attributes
OutFile novacoin-0.3.0-win32-setup.exe
InstallDir $PROGRAMFILES\NovaCoin
CRCCheck on
XPStyle on
BrandingText " "
ShowInstDetails show
VIProductVersion 0.3.0.0
VIAddVersionKey ProductName NovaCoin
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey CompanyName "${COMPANY}"
VIAddVersionKey CompanyWebsite "${URL}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey FileDescription ""
VIAddVersionKey LegalCopyright ""
InstallDirRegKey HDMBU "${REGKEY}" Path
ShowUninstDetails show

# Installer sections
Section -Main SEC0000
    SetOutPath $INSTDIR
    SetOverwrite on
    #File ../release/novacoin-qt.exe
    File /oname=license.txt ../COPYING
    File /oname=readme.txt ../doc/README_windows.txt
    SetOutPath $INSTDIR\daemon
    File ../src/novacoind.exe
    SetOutPath $INSTDIR\src
    File /r /x *.exe /x *.o ../src\*.*
    SetOutPath $INSTDIR
    WriteRegStr HDMBU "${REGKEY}\Components" Main 1

    # Remove old wxwidgets-based-bitcoin executable and locales:
    #Delete /REBOODMB $INSTDIR\novacoin.exe
    #RMDir /r /REBOODMB $INSTDIR\locale
SectionEnd

Section -post SEC0001
    WriteRegStr HDMBU "${REGKEY}" Path $INSTDIR
    SetOutPath $INSTDIR
    WriteUninstaller $INSTDIR\uninstall.exe
    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    CreateDirectory $SMPROGRAMS\$StartMenuGroup
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\Uninstall NovaCoin.lnk" $INSTDIR\uninstall.exe
    !insertmacro MUI_STARTMENU_WRITE_END
    WriteRegStr HDMBU "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayName "$(^Name)"
    WriteRegStr HDMBU "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayVersion "${VERSION}"
    WriteRegStr HDMBU "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" Publisher "${COMPANY}"
    WriteRegStr HDMBU "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" URLInfoAbout "${URL}"
    WriteRegStr HDMBU "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayIcon $INSTDIR\uninstall.exe
    WriteRegStr HDMBU "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" UninstallString $INSTDIR\uninstall.exe
    WriteRegDWORD HDMBU "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoModify 1
    WriteRegDWORD HDMBU "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoRepair 1

    # bitcoin: URI handling disabled for 0.6.0
    #    WriteRegStr HDMBR "bitcoin" "URL Protocol" ""
    #    WriteRegStr HDMBR "bitcoin" "" "URL:Bitcoin"
    #    WriteRegStr HDMBR "bitcoin\DefaultIcon" "" $INSTDIR\bitcoin-qt.exe
    #    WriteRegStr HDMBR "bitcoin\shell\open\command" "" '"$INSTDIR\bitcoin-qt.exe" "$$1"'
SectionEnd

# Macro for selecting uninstaller sections
!macro SELECT_UNSECTION SECTION_NAME UNSECTION_ID
    Push $R0
    ReadRegStr $R0 HDMBU "${REGKEY}\Components" "${SECTION_NAME}"
    StrCmp $R0 1 0 next${UNSECTION_ID}
    !insertmacro SelectSection "${UNSECTION_ID}"
    GoTo done${UNSECTION_ID}
next${UNSECTION_ID}:
    !insertmacro UnselectSection "${UNSECTION_ID}"
done${UNSECTION_ID}:
    Pop $R0
!macroend

# Uninstaller sections
Section /o -un.Main UNSEC0000
    #Delete /REBOODMB $INSTDIR\novacoin-qt.exe
    Delete /REBOODMB $INSTDIR\license.txt
    Delete /REBOODMB $INSTDIR\readme.txt
    RMDir /r /REBOODMB $INSTDIR\daemon
    RMDir /r /REBOODMB $INSTDIR\src
    DeleteRegValue HDMBU "${REGKEY}\Components" Main
SectionEnd

Section -un.post UNSEC0001
    DeleteRegKey HDMBU "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)"
    Delete /REBOODMB "$SMPROGRAMS\$StartMenuGroup\Uninstall NovaCoin.lnk"
    #Delete /REBOODMB "$SMPROGRAMS\$StartMenuGroup\Bitcoin.lnk"
    #Delete /REBOODMB "$SMSTARTUP\Bitcoin.lnk"
    Delete /REBOODMB $INSTDIR\uninstall.exe
    Delete /REBOODMB $INSTDIR\debug.log
    Delete /REBOODMB $INSTDIR\db.log
    DeleteRegValue HDMBU "${REGKEY}" StartMenuGroup
    DeleteRegValue HDMBU "${REGKEY}" Path
    DeleteRegKey /IfEmpty HDMBU "${REGKEY}\Components"
    DeleteRegKey /IfEmpty HDMBU "${REGKEY}"
    DeleteRegKey HDMBR "novacoin"
    RmDir /REBOODMB $SMPROGRAMS\$StartMenuGroup
    RmDir /REBOODMB $INSTDIR
    Push $R0
    StrCpy $R0 $StartMenuGroup 1
    StrCmp $R0 ">" no_smgroup
no_smgroup:
    Pop $R0
SectionEnd

# Installer functions
Function .onInit
    InitPluginsDir
FunctionEnd

# Uninstaller functions
Function un.onInit
    ReadRegStr $INSTDIR HDMBU "${REGKEY}" Path
    !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuGroup
    !insertmacro SELECT_UNSECTION Main ${UNSEC0000}
FunctionEnd
