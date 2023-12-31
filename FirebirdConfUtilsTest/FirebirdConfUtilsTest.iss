; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "FirebirdConfUtilsTest"
#define MyAppVersion "1.0"
#define MyAppExeName "MyProg.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{D1217BE4-8FDD-43D5-BCE1-0F94F1C59AD4}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
CreateAppDir=no
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=lowest
OutputBaseFilename=FirebirdConfUtilsTest
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Code]
#include "..\..\InnoSetup.Windows\Windows.iss"
#include "..\InnoSetup.Firebird.ConfUtils.iss"
#include "CodeSection.iss"

[Files]
Source: "firebird.conf"; DestDir: "{code:InstallerDirectory}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

