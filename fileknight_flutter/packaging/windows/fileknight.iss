; Inno Setup script for FileKnight (Windows installer).
; Build the app first: flutter build windows --release
; Then compile this script with Inno Setup (https://jrsoftware.org/isinfo.php).

#define AppVersion "1.0.0"

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
