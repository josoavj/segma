; Installateur Inno Setup de SEGMA
; Compilation : ISCC /DAppVersion=1.0.0 /DNumericVersion=1.0.0 /DStageDir=<dossier> /DOutDir=<sortie> segma.iss

#ifndef AppVersion
  #define AppVersion "0.0.0-dev"
#endif
#ifndef NumericVersion
  #define NumericVersion "0.0.0"
#endif
#ifndef StageDir
  #error StageDir doit être défini (/DStageDir=...)
#endif
#ifndef OutDir
  #define OutDir "."
#endif

#define AppName "SEGMA"
#define AppExeCmd "{sys}\WindowsPowerShell\v1.0\powershell.exe"
#define AppExeArgs "-NoProfile -ExecutionPolicy Bypass -File """"{app}\segma.ps1"""" -HideConsole"

[Setup]
AppId={{8F3C2A5E-6B1D-4C7A-9E2F-3A5D7B1C4E90}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=josoavj
AppPublisherURL=https://github.com/josoavj/segma
AppSupportURL=https://github.com/josoavj/segma/issues
AppUpdatesURL=https://github.com/josoavj/segma/releases
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
LicenseFile={#StageDir}\LICENSE
OutputDir={#OutDir}
OutputBaseFilename=segma-{#AppVersion}-windows-x64-setup
SetupIconFile={#StageDir}\segma.ico
UninstallDisplayIcon={app}\segma.ico
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
VersionInfoVersion={#NumericVersion}
VersionInfoProductName={#AppName}
CloseApplications=yes

[Languages]
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#StageDir}\app\*";     DestDir: "{app}\app";     Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#StageDir}\backend\*"; DestDir: "{app}\backend"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#StageDir}\segma.ps1";     DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\segma.bat";     DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\segma.ico";     DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\.env.example";  DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\LICENSE";       DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#AppName}"; Filename: "{#AppExeCmd}"; Parameters: "{#AppExeArgs}"; WorkingDir: "{app}"; IconFilename: "{app}\segma.ico"
Name: "{autodesktop}\{#AppName}"; Filename: "{#AppExeCmd}"; Parameters: "{#AppExeArgs}"; WorkingDir: "{app}"; IconFilename: "{app}\segma.ico"; Tasks: desktopicon

[Run]
Filename: "{#AppExeCmd}"; Parameters: "{#AppExeArgs}"; WorkingDir: "{app}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent

[Code]
// À la désinstallation, propose de supprimer l'environnement Python (plusieurs Go) et les journaux.
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  DataDir: String;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    DataDir := ExpandConstant('{localappdata}\segma');
    if DirExists(DataDir) then
      if SuppressibleMsgBox(
           'Supprimer aussi l''environnement Python, les journaux et la configuration de SEGMA ?' + #13#10 + DataDir,
           mbConfirmation, MB_YESNO or MB_DEFBUTTON2, IDNO) = IDYES then
        DelTree(DataDir, True, True, True);
  end;
end;
