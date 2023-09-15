// CodeSection.iss

type
  TTestResults = record
    TestCount: Integer;
    SuccessfullCount: Integer;
    ErrorCount: Integer;
  end;

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

procedure AllTestsAreOK(const AErrorMessage: string);
begin
  MsgBox(AErrorMessage, mbInformation, MB_OK);
  
  CancelWithoutPrompt := True;
  WizardForm.Close;
end;

procedure DoTestGetFirebirdSettingValue(const AFirebirdConfFilename, ASettingName, AExpectedValue: string; var ATestResults: TTestResults);
var
  LSetting: string;
begin
  Inc(ATestResults.TestCount);

  LSetting := GetFirebirdSettingValue(AFirebirdConfFilename, ASettingName);

  if LSetting <> AExpectedValue then
  begin
    Inc(ATestResults.ErrorCount);

    AbortInstallation('Error testing GetFirebirdSettingValue with SettingName: "' + ASettingName 
      + '" SettingValue form file: "' + LSetting + '" Expected value: "' + AExpectedValue + '"')
  end
  else
    Inc(ATestResults.SuccessfullCount);
end;

procedure DoTestGetFirebirdSettingDefaultValue(const AFirebirdConfFilename, ASettingName, AExpectedValue: string; var ATestResults: TTestResults);
var
  LSetting: string;
begin
  Inc(ATestResults.TestCount);

  LSetting := GetFirebirdSettingDefaultValue(AFirebirdConfFilename, ASettingName);

  if LSetting <> AExpectedValue then
  begin
    Inc(ATestResults.ErrorCount);

    AbortInstallation('Error testing GetFirebirdSettingValue with SettingName: "' + ASettingName 
      + '" SettingValue form file: "' + LSetting + '" Expected value: "' + AExpectedValue + '"')
  end
  else
    Inc(ATestResults.SuccessfullCount);
end;


procedure TestGetFirebirdSettingValue(const AFirebirdConfFilename: string; var ATestResults: TTestResults);
begin
  DoTestGetFirebirdSettingValue(AFirebirdConfFilename, 'Foo', '', ATestResults);
  DoTestGetFirebirdSettingValue(AFirebirdConfFilename, 'FoO', '', ATestResults);
  DoTestGetFirebirdSettingValue(AFirebirdConfFilename, 'foo', '', ATestResults);
  DoTestGetFirebirdSettingValue(AFirebirdConfFilename, 'FOO', '', ATestResults);
  // 
  DoTestGetFirebirdSettingValue(AFirebirdConfFilename, 'DefaultDbCachePages', '11K', ATestResults);
  DoTestGetFirebirdSettingValue(AFirebirdConfFilename, 'DEFAULTDBCACHEPAGES', '11K', ATestResults);
  DoTestGetFirebirdSettingValue(AFirebirdConfFilename, 'defaultdbcachepages', '11K', ATestResults);
  DoTestGetFirebirdSettingValue(AFirebirdConfFilename, 'InlineSortThreshold', '16384', ATestResults);
end;

procedure TestGetFirebirdSettingDefaultValue(const AFirebirdConfFilename: string; var ATestResults: TTestResults);
begin
  DoTestGetFirebirdSettingDefaultValue(AFirebirdConfFilename, 'Foo', '', ATestResults);
  DoTestGetFirebirdSettingDefaultValue(AFirebirdConfFilename, 'FoO', '', ATestResults);
  DoTestGetFirebirdSettingDefaultValue(AFirebirdConfFilename, 'foo', '', ATestResults);
  DoTestGetFirebirdSettingDefaultValue(AFirebirdConfFilename, 'FOO', '', ATestResults);

  DoTestGetFirebirdSettingDefaultValue(AFirebirdConfFilename, 'DefaultDbCachePages', '2048', ATestResults);
  DoTestGetFirebirdSettingDefaultValue(AFirebirdConfFilename, 'DEFAULTDBCACHEPAGES', '2048', ATestResults);
  DoTestGetFirebirdSettingDefaultValue(AFirebirdConfFilename, 'defaultdbcachepages', '2048', ATestResults);
end;

const
  FIREBIRD_CONF_FILE = 'firebird.conf';

procedure CurStepChanged(CurStep: TSetupStep);
var
  LTestsResults: TTestResults;
  LInstallerDirectory: string;
  LFirebirdConfFilename: string;
begin
  LTestsResults.TestCount := 0;
  LTestsResults.SuccessfullCount := 0;
  LTestsResults.ErrorCount := 0;
  
  case CurStep of
    ssInstall:
      begin
        LInstallerDirectory := InstallerDirectory('');
        LFirebirdConfFilename := LInstallerDirectory + FIREBIRD_CONF_FILE;

        if not DirExists(LInstallerDirectory) then
          AbortInstallation('Something truly weird going on... installer dir not found: "' + LInstallerDirectory + '"');

        if FileExists(LFirebirdConfFilename) then 
          if not DeleteFile(LFirebirdConfFilename) then
            AbortInstallation('Could not delete existing conf file:  "' + LFirebirdConfFilename + '"');

        if not FileCopy('..\' + FIREBIRD_CONF_FILE, LFirebirdConfFilename, True) then
            AbortInstallation('Could not copy peistine conf file to :  "' + LFirebirdConfFilename + '"');

        if not FileExists(LFirebirdConfFilename) then
          AbortInstallation(FIREBIRD_CONF_FILE + ' -file not installed yeet at : "' + LFirebirdConfFilename + '"');

        // Test code into here...
        TestGetFirebirdSettingValue(LFirebirdConfFilename, LTestsResults);
        TestGetFirebirdSettingDefaultValue(LFirebirdConfFilename, LTestsResults);

        // Kind of Kludge, but beats the Access denied etc message we get now.
        AllTestsAreOK('OK: ' + IntToStr(LTestsResults.SuccessfullCount) + ' failed: ' + IntToStr(LTestsResults.ErrorCount)
          + ' Totals : ' + IntToStr(LTestsResults.TestCount));
      end;
  end;
end;