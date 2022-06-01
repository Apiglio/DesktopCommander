unit dcer_crashtrack_unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Windows, Messages;

const
  WM_TestMsg = WM_USER + 100;

type

  { TForm1 }

  TForm1 = class(TForm)
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

function StartHook(MsgID:Word):Bool;stdcall;external 'DesktopCommander_dll.dll';
function StopHook:Bool;stdcall;external 'DesktopCommander_dll.dll';
procedure SetCallHandle(sender:HWND);stdcall;external 'DesktopCommander_dll.dll';

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  StopHook;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SetCallHandle(Self.Handle);
  if not StartHook(WM_TestMsg) then
  begin
    ShowMessage('挂钩失败！');
  end;
end;

end.

