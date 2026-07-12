; Script Inno Setup do FileKnight (instalador Windows).
; Primeiro compile o app: flutter build windows --release
; Depois compile este script com o Inno Setup (https://jrsoftware.org/isinfo.php).

; A versão pode ser sobrescrita na linha de comando: ISCC.exe /DAppVersion=0.1.0
#ifndef AppVersion
  #define AppVersion "0.1.0"
#endif

[Setup]
AppName=FileKnight
AppVersion={#AppVersion}
AppPublisher=jonathaxs
DefaultDirName={autopf}\FileKnight
DefaultGroupName=FileKnight
DisableProgramGroupPage=yes
OutputDir=..\..\dist
OutputBaseFilename=FileKnight-{#AppVersion}-windows-setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
SetupIconFile=..\..\windows\runner\resources\app_icon.ico

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{group}\FileKnight"; Filename: "{app}\fileknight.exe"
Name: "{commondesktop}\FileKnight"; Filename: "{app}\fileknight.exe"

[Run]
Filename: "{app}\fileknight.exe"; Description: "Launch FileKnight"; Flags: nowait postinstall skipifsilent
