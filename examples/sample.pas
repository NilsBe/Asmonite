program Sample;

{$APPTYPE CONSOLE}

uses
  SysUtils;

(* Multi-line
   comment *)

function Sum(const Values: array of Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Low(Values) to High(Values) do
    Inc(Result, Values[I]);  // accumulate
end;

begin
  { brace comment }
  WriteLn('Sum = ', Sum([1, 2, 3, $10]), #13#10'It''s done.');
  WriteLn(FloatToStr(1.5e3));
end.
