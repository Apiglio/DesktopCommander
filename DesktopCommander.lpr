program DesktopCommander;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Apiglio_Useful, desktop_commander_unit, commandline_form;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TCommandForm, CommandForm);
  Application.CreateForm(TFormCommandLine, FormCommandLine);
  Application.Run;
end.

