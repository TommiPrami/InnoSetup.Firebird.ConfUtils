// InnoSetup.Firebird.ConfUtils.iss

function ScalePageSizeToAvailableMemory(const ACurrentAvailableMemory, AMemHighBound: Int64;
  const AMaxMemoryUsegeFactor: Double; const APageSize: Integer): Integer;
var
  LMaxMemToUse: Int64;
begin
  LMaxMemToUse := MinInt64(AMemHighBound, Round(ACurrentAvailableMemory * AMaxMemoryUsegeFactor));

  Result := Round(LMaxMemToUse / APageSize);
end;

const
  DEFAULT_PAGE_SIZE = 32768;
  DEFAULT_MAX_MEMORY_USAGE_FACTOR = 0.57595996889294543964;
  DEFAULT_MEM_HIGH_BOUND = 805306368; // 768MiB

function GetDefaultDbCachePagesByAvailableMemory: Integer;
var
  LCurrentAvailabnleMemory: Int64;
begin
  LCurrentAvailabnleMemory := AvailablePhysicalMemory;

  if LCurrentAvailabnleMemory = 0 then
    Result := 1048576 // 10K 
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
