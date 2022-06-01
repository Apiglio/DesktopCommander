unit commandline;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TCommandLineForm }

  TCommandLineForm = class(TForm)
    Memo_cmd: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  CommandLineForm: TCommandLineForm;

implementation

{$R *.lfm}

{ TCommandLineForm }

procedure TCommandLineForm.FormResize(Sender: TObject);
begin
  Memo_cmd.Width:=Width;
  Memo_cmd.Left:=0;
  Memo_cmd.Height:=Height;
  Memo_cmd.Top:=Top;
end;

procedure TCommandLineForm.FormCreate(Sender: TObject);
begin
  Show;
  Formresize(nil);
end;

end.

