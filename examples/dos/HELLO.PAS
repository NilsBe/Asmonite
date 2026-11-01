{ Counts up and writes each number on a line of its own, without end (Pause
  or Ctrl+F2 stops it in the debugger). HELLO.EXE is this file translated by
  Turbo Pascal 7 (TPC HELLO.PAS with the TURBO.TPL of 1993); dbgtest checks
  that both still match. }
var
  I: Integer;
begin
  while True do
  begin
    WriteLn(I);
    Inc(I)
  end
end.
