// CodeSection.iss

var 
  CancelWithoutPrompt: Boolean;

function InstallerDirectory(const AParam: string): string;
begin
  Result := ExtractFilePath(ExpandConstant('{srcexe}'));
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  if CancelWithoutPrompt then
    Confirm := False; { hide confirmation prompt }
end;

procedure AbortInstallation(const AErrorMessage: string);
begin
  if AErrorMessage <> '' then
    MsgBox(AErrorMessage, mbCriticalError, MB_OK);
  
  CancelWithoutPrompt := True;
  WizardForm.Close;
end;

const
  FIREBIRD_CONF_FILE = 'firebird.conf';

procedure CurStepChanged(CurStep: TSetupStep);
var
  LInstallerDirectory: string;
  LFirebirdConf: string;
begin
  case CurStep of
    ssPostInstall:
      begin
        LInstallerDirectory := InstallerDirectory('');
        LFirebirdConf := LInstallerDirectory + FIREBIRD_CONF_FILE;

        if not DirExists(LInstallerDirectory) then
          AbortInstallation('Something truly weird going on... installer dir not found: "' + LInstallerDirectory + '"');

        if not FileExists(LFirebirdConf) then
          AbortInstallation(FIREBIRD_CONF_FILE + ' -file not installed yeet at : "' + LFirebirdConf + '"');

        // Test code into here...
        

        // 
      end;
  end;
end;