// InnoSetup.Firebird.ConfUtils.iss

// Requires Windows.iss

const
  // Define page size you prefer
  DEFAULT_PAGE_SIZE = 32768;
  // 
  DEFAULT_MAX_MEMORY_USAGE_FACTOR = 0.57595996889294543964;
  // Most memory allowed for page cache 
  DEFAULT_MEM_HIGH_BOUND = 805306368; // 768MiB
  // Min Pages used, if can't get available memory (shopuld nbot happen)
  MIN_PAGES_USED_ON_ERROR = 1048576; // 10K

function MaxMemToUse(const ACurrentAvailableMemory, AMemHighBound: Int64; const AMaxMemoryUsegeFactor: Double): Int64;
begin
  Result := MinInt64(AMemHighBound, Round(ACurrentAvailableMemory * AMaxMemoryUsegeFactor));
end;

function ScalePageSizeToAvailableMemory(const ACurrentAvailableMemory, AMemHighBound: Int64;
  const AMaxMemoryUsegeFactor: Double; const APageSize: Integer): Integer;
var
  LMaxMemToUse: Int64;
begin
  LMaxMemToUse := MaxMemToUse(ACurrentAvailableMemory, AMemHighBound, AMaxMemoryUsegeFactor); 

  Result := Round(LMaxMemToUse / APageSize);
end;

function GetDefaultDbCachePagesByAvailableMemory: Integer;
var
  LCurrentAvailabnleMemory: Int64;
begin
  LCurrentAvailabnleMemory := AvailablePhysicalMemory;

  if LCurrentAvailabnleMemory = 0 then
    Result := MIN_PAGES_USED_ON_ERROR
  else
    Result := ScalePageSizeToAvailableMemory(LCurrentAvailabnleMemory, DEFAULT_MEM_HIGH_BOUND, 
      DEFAULT_MAX_MEMORY_USAGE_FACTOR, DEFAULT_PAGE_SIZE);
end;

// Paremeters as Int64, so no need for typecast. Got overflow easily at Delphi while testing the code
function PagesMemUsage(const APagesCount, APageSize: Int64): Int64;
begin
  Result := APageSize * APagesCount;
end;

function PagesSettingToString(const APages: Integer; const AOutputKilopages: Boolean): string;
begin
  if AOutputKilopages then
    Result := IntToStr(APages div 1024) + 'k'
  else
    Result := IntToStr(APages);
end;

function GetDefaultDbCachePagesByAvailableMemoryStr: string;
begin
  Result := PagesSettingToString(GetDefaultDbCachePagesByAvailableMemory, True); 
end;

type
  TSettingIndexes = record
    PrototypeSettingIndex: Integer;
    SettingIndex: Integer;
  end;

function RemoveLeadingHashes(const AStrValue: string): string;
var
  LStartIndex: Integer; 
  LValueLength: Integer; 
begin
  LValueLength := Length(AStrValue);
  
  for LStartIndex := 1 to LValueLength do
  begin
    if AStrValue[LStartIndex] <> '#' then
      Break;
  end;

  Result := Copy(AStrValue, LStartIndex, LValueLength);
end;

function ParseSettingValue(const AFileContent: TStringList; const ASettingIndex: Integer): string;
var
  LSettingLine: string;
  LLength: Integer;
  LValuePos: Integer;
begin
  Result := '';

  LSettingLine := Trim(AFileContent[ASettingIndex]);

  LLength := Length(LSettingLine);
  
  if LLength > 1 then
  begin
    if LSettingLine[1] = '#' then
      LSettingLine := RemoveLeadingHashes(LSettingLine);

    LValuePos := Pos('=', LSettingLine);
    if LValuePos > 1 then
      Result := Trim(Copy(LSettingLine, LValuePos + 1, LLength));
  end;
end;

function StringStartsWith(const AText, APrefix: string): Boolean;
var
  LPrefixLength: Integer;
  LTextLength: Integer;
  LTextStart: string;
begin
  Result := False;

  LPrefixLength := Length(APrefix);
  LTextLength := Length(AText);

  if LTextLength < LPrefixLength then 
    Exit;

  LTextStart := AnsiUppercase(Copy(AText, 1, LPrefixLength));
  
  Result := AnsiUppercase(APrefix) = LTextStart;
end;

function HasIndexes(const ASettingIdexes: TSettingIndexes): Boolean;
begin
  Result := (ASettingIdexes.PrototypeSettingIndex <> -1) or (ASettingIdexes.SettingIndex <> -1)
end;

function GetSettingIndexes(const AFileContent: TStringList; const ASettingName: string): TSettingIndexes;
var
  LPrototypeSettingName: string;
  LCurrentLine: string;
  LIndex: Integer;
begin
  Result.PrototypeSettingIndex := -1;
  Result.SettingIndex := -1;

  LPrototypeSettingName := '#' + ASettingName;

  for LIndex := 0 to AFileContent.Count - 1 do
  begin
    LCurrentLine := Trim(AFileContent[LIndex]);
    
    if StringStartsWith(LCurrentLine, ASettingName) then
      Result.SettingIndex := LIndex
    else if StringStartsWith(LCurrentLine, LPrototypeSettingName) then
      Result.PrototypeSettingIndex := LIndex;

    if (Result.PrototypeSettingIndex <> -1) and (Result.SettingIndex <> -1) then
      Break;
  end;
end;

function GetFirebirdSettingValue(const AFirebirdConfContent: TStringList; const ASettingName: string): string;
var
  LSettingIdexes: TSettingIndexes;
begin
  Result := '';

  LSettingIdexes := GetSettingIndexes(AFirebirdConfContent, ASettingName);

  if LSettingIdexes.SettingIndex >= 0 then
    Result := ParseSettingValue(AFirebirdConfContent, LSettingIdexes.SettingIndex);
end;

function GetFirebirdSettingDefaultValue(const AFirebirdConfContent: TStringList; const ASettingName: string): string;
var
  LSettingIdexes: TSettingIndexes;
begin
  Result := '';

  LSettingIdexes := GetSettingIndexes(AFirebirdConfContent, ASettingName);

  if LSettingIdexes.PrototypeSettingIndex >= 0 then
    Result := ParseSettingValue(AFirebirdConfContent, LSettingIdexes.PrototypeSettingIndex);
end;

procedure SetFirebirdSettingValue(const AFirebirdConfContent: TStringList; const ASettingName, ANewValue: string);
begin
  // DO nothing for now
end;