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

procedure DoTestGetFirebirdSettingValue(const AFirebirdConfContent: TStringList; const ASettingName, AExpectedValue: string; var ATestResults: TTestResults);
var
  LSetting: string;
begin
  Inc(ATestResults.TestCount);

  LSetting := GetFirebirdSettingValue(AFirebirdConfContent, ASettingName);

  if LSetting <> AExpectedValue then
  begin
    Inc(ATestResults.ErrorCount);

    AbortInstallation('Error testing GetFirebirdSettingValue with SettingName: "' + ASettingName 
      + '" SettingValue form file: "' + LSetting + '" Expected value: "' + AExpectedValue + '"');
  end
  else
    Inc(ATestResults.SuccessfullCount);
end;

procedure DoTestGetFirebirdSettingDefaultValue(const AFirebirdConfContent: TStringList; const ASettingName, AExpectedValue: string; var ATestResults: TTestResults);
var
  LSetting: string;
begin
  Inc(ATestResults.TestCount);

  LSetting := GetFirebirdSettingDefaultValue(AFirebirdConfContent, ASettingName);

  if LSetting <> AExpectedValue then
  begin
    Inc(ATestResults.ErrorCount);

    AbortInstallation('Error testing GetFirebirdSettingValue with SettingName: "' + ASettingName 
      + '" SettingValue form file: "' + LSetting + '" Expected value: "' + AExpectedValue + '"');
  end
  else
    Inc(ATestResults.SuccessfullCount);
end;

procedure DoTestSetFirebirdSettingValue(const AFirebirdConfContent: TStringList; const ASettingName, ANewValue: string;
  const ASettingInxex: Integer; var ATestResults: TTestResults);
var
  LTempFileContent: TStringList;
  LSettingIndexes: TSettingIndexes;
  LSetting: string;
begin
  Inc(ATestResults.TestCount);

  LTempFileContent := TStringList.Create;
   try
     LTempFileContent.AddStrings(AFirebirdConfContent);

    SetFirebirdSettingValue(LTempFileContent, ASettingName, ANewValue);

    LSetting := GetFirebirdSettingValue(LTempFileContent, ASettingName);

    if LSetting <> ANewValue then
    begin
      Inc(ATestResults.ErrorCount);

      AbortInstallation('Error testing GetFirebirdSettingValue with SettingName: "' + ASettingName 
        + '" SettingValue form file: "' + LSetting + '" Expected new value: "' + ANewValue + '"');
    end
    else
    begin
      LSettingIndexes := GetSettingIndexes(LTempFileContent, ASettingName);

      if LSettingIndexes.SettingIndex <> ASettingInxex then
      begin
        Inc(ATestResults.ErrorCount);

        AbortInstallation('Error testing GetFirebirdSettingValue with SettingName: "' + ASettingName 
          + '" SettingIndex form file: "' + IntToStr(LSettingIndexes.SettingIndex) 
          + '" Expected Index value: "' + IntToStr(ASettingInxex) + '"');
      end
      else
        Inc(ATestResults.SuccessfullCount);
    end;
  finally
    LTempFileContent.Free;
  end;
end;

procedure TestGetFirebirdSettingValue(const AFirebirdConfContent: TStringList; var ATestResults: TTestResults);
begin
  DoTestGetFirebirdSettingValue(AFirebirdConfContent, 'Foo', '', ATestResults);
  DoTestGetFirebirdSettingValue(AFirebirdConfContent, 'FoO', '', ATestResults);
  DoTestGetFirebirdSettingValue(AFirebirdConfContent, 'foo', '', ATestResults);
  DoTestGetFirebirdSettingValue(AFirebirdConfContent, 'FOO', '', ATestResults);
  // 
  DoTestGetFirebirdSettingValue(AFirebirdConfContent, 'DefaultDbCachePages', '11K', ATestResults);
  DoTestGetFirebirdSettingValue(AFirebirdConfContent, 'DEFAULTDBCACHEPAGES', '11K', ATestResults);
  DoTestGetFirebirdSettingValue(AFirebirdConfContent, 'defaultdbcachepages', '11K', ATestResults);
  DoTestGetFirebirdSettingValue(AFirebirdConfContent, 'InlineSortThreshold', '16384', ATestResults);
end;

procedure TestGetFirebirdSettingDefaultValue(const AFirebirdConfContent: TStringList; var ATestResults: TTestResults);
begin
  DoTestGetFirebirdSettingDefaultValue(AFirebirdConfContent, 'Foo', '', ATestResults);
  DoTestGetFirebirdSettingDefaultValue(AFirebirdConfContent, 'FoO', '', ATestResults);
  DoTestGetFirebirdSettingDefaultValue(AFirebirdConfContent, 'foo', '', ATestResults);
  DoTestGetFirebirdSettingDefaultValue(AFirebirdConfContent, 'FOO', '', ATestResults);

  DoTestGetFirebirdSettingDefaultValue(AFirebirdConfContent, 'DefaultDbCachePages', '2048', ATestResults);
  DoTestGetFirebirdSettingDefaultValue(AFirebirdConfContent, 'DEFAULTDBCACHEPAGES', '2048', ATestResults);
  DoTestGetFirebirdSettingDefaultValue(AFirebirdConfContent, 'defaultdbcachepages', '2048', ATestResults);
end;

procedure TestSetFirebirdSettingValue(const AFirebirdConfContent: TStringList; var ATestResults: TTestResults);
begin
  DoTestSetFirebirdSettingValue(AFirebirdConfContent, 'Foo', 'Foo', 1215, ATestResults);
  DoTestSetFirebirdSettingValue(AFirebirdConfContent, 'DefaultDbCachePages', '33554432', 258, ATestResults);
  DoTestSetFirebirdSettingValue(AFirebirdConfContent, 'TcpRemoteBufferSize', FormatIntegerValue(16384), 866, ATestResults);
end;

const
  FIREBIRD_CONF_FILE = 'firebird.conf';

procedure CurStepChanged(CurStep: TSetupStep);
var
  LTestsResults: TTestResults;
  LInstallerDirectory: string;
  LFirebirdConfFilename: string;
  LConfFileContent: TStringList;
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

        LConfFileContent := TStringList.Create;
        try
          LConfFileContent.LoadFromFile(LFirebirdConfFilename);

          // Test code into here...
          TestGetFirebirdSettingValue(LConfFileContent, LTestsResults);
          TestGetFirebirdSettingDefaultValue(LConfFileContent, LTestsResults);

          //
          TestSetFirebirdSettingValue(LConfFileContent, LTestsResults);
          // Kind of Kludge, but beats the Access denied etc message we get now.
          AllTestsAreOK(' Total : ' + IntToStr(LTestsResults.TestCount) + #13#10 + ' Successful: ' + IntToStr(LTestsResults.SuccessfullCount) + #13#10
            + ' failed: ' + IntToStr(LTestsResults.ErrorCount));
        finally
          LConfFileContent.Free;
        end;
      end;
  end;
end;