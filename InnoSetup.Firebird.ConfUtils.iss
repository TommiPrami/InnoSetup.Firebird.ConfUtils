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
