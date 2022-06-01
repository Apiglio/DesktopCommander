unit desktop_commander_unit;

{$mode objfpc}{$H+}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Apiglio_Useful;

const
  WM_TestMsg = WM_User + 100;
  C_MouseMove = 512;
  C_MouseLD = 513;
  C_MouseLU = 514;
  C_MouseRD = 516;
  C_MouseRU = 517;
  C_MouseMD = 519;
  C_MouseMU = 520;
  C_MouseMR = 522;
  C_KeyDown = 256;
  C_KeyUp = 257;
  C_lower=['a'..'z','0'..'9'];

type

  { TCommandForm }

  TCommandForm = class(TForm)
    Button_clear: TButton;
    Button_alterna: TButton;
    Button_option: TButton;
    Memo_cmd: TMemo;
    procedure Button_alternaClick(Sender: TObject);
    procedure Button_clearClick(Sender: TObject);
    procedure Button_optionClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure GetMessageUpdate(var Msg:TMessage);message WM_TestMsg;
  end;


var
  CommandForm: TCommandForm;
  State:record
    Alt,Ctrl,Shift,Win:Boolean;
    LBut,RBut,MBut:Boolean;
  end;
  Trace:boolean;
  Loop:array[0..255]of char;

implementation

uses commandline_form;



{ TCommandForm }

function StartHookM(MsgID:Word):Bool;stdcall;external 'DesktopCommander_mouse_dll.dll' name 'StartHook';
function StopHookM:Bool;stdcall;external 'DesktopCommander_mouse_dll.dll' name 'StopHook';
procedure SetCallHandleM(sender:HWND);stdcall;external 'DesktopCommander_mouse_dll.dll' name 'SetCallHandle';
function StartHookK(MsgID:Word):Bool;stdcall;external 'DesktopCommander_keyboard_dll.dll' name 'StartHook';
function StopHookK:Bool;stdcall;external 'DesktopCommander_keyboard_dll.dll' name 'StopHook';
procedure SetCallHandleK(sender:HWND);stdcall;external 'DesktopCommander_keyboard_dll.dll' name 'SetCallHandle';

procedure TCommandForm.FormCreate(Sender: TObject);
begin

  FormResize(nil);
  Trace:=false;

  SetCallHandleM(Self.Handle);
  if not StartHookM(WM_TestMsg) then
  begin
    ShowMessage('挂钩失败！');
  end;
  SetCallHandleK(Self.Handle);
  if not StartHookK(WM_TestMsg) then
  begin
    ShowMessage('挂钩失败！');
  end;

  CommandForm.Position:=poScreenCenter;

end;

procedure TCommandForm.FormResize(Sender: TObject);
begin
  Memo_cmd.Left:=0;
  Memo_cmd.Top:=0;
  Memo_cmd.Width:=Width;
  Memo_cmd.Height:=Height-30;
  Button_clear.Top:=Memo_cmd.Height + 2;
  Button_alterna.Top:=Memo_cmd.Height + 2;
  Button_option.Top:=Memo_cmd.Height + 2;
  Button_clear.Height:=26;
  Button_alterna.Height:=26;
  Button_option.Height:=26;

  Button_clear.Left:=0;
  Button_alterna.Left:=(Memo_cmd.Width-4)div 3 + 2;
  Button_option.Left:=((Memo_cmd.Width-4)div 3 + 2) * 2;

  Button_clear.Width:=(Memo_cmd.Width-4)div 3;
  Button_alterna.Width:=(Memo_cmd.Width-4)div 3;
  Button_option.Width:=(Memo_cmd.Width-4)div 3;


end;

procedure TCommandForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  StopHookK;
  StopHookM;
end;

procedure TCommandForm.Button_clearClick(Sender: TObject);
begin
  Memo_cmd.Clear;
end;

procedure TCommandForm.Button_optionClick(Sender: TObject);
begin
  Self.Hide;
end;

procedure TCommandForm.Button_alternaClick(Sender: TObject);
begin
  if Trace then (Sender as TButton).Caption:='开始记录'
  else (Sender as TButton).Caption:='停止记录';
  Trace:=not Trace;
end;


procedure TCommandForm.GetMessageUpdate(var Msg:TMessage);
var x,y:integer;
begin
  x := pMouseHookStruct(Msg.LParam)^.pt.X;
  y := pMouseHookStruct(Msg.LParam)^.pt.Y;

  if Trace then Self.Memo_cmd.lines.add('更新消息：n='+IntToStr(Msg.WParam)+' x='+IntToStr(x)+' y='+IntToStr(y));

  {
  lctrl=162,29
  rctrl=163,29
  lshift=160,42
  rshift=161,54
  lalt=164,56
  ralt=165,56
  }

  case Msg.wParam of
    C_MouseMove:;
    C_MouseLD:State.LBut:=true;
    C_MouseLU:State.LBut:=false;
    C_MouseRD:State.RBut:=true;
    C_MouseRU:State.RBut:=false;
    C_MouseMD:State.MBut:=true;
    C_MouseMU:State.MBut:=false;
    C_MouseMR:;
    C_KeyDown:
      begin
        case x of
          162,163:State.Ctrl:=true;
          160,161:State.Shift:=true;
          164,165:State.Alt:=true;
          91,92:State.Win:=true;
          else ;
        end;
      end;
    C_KeyUp:
      begin
        case x of
          162,163:State.Ctrl:=false;
          160,161:State.Shift:=false;
          164,165:State.Alt:=false;
          91,92:State.Win:=false;
          else
            begin
              if State.Win and (x=27) then
                begin
                  Auf.Script.PSW.haltoff:=true;
                  FormCommandLine.Show;
                  SetWindowPos(FormCommandLine.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
                  FormCommandLine.SetFocus;
                end;
            end;
          end;
        end;
    else ;
  end;

  //if State.Alt then Self.Memo_cmd.lines.add('BOOL：Alt=true') else Self.Memo_cmd.lines.add('BOOL：Alt=false');
  //if State.Ctrl then Self.Memo_cmd.lines.add('BOOL：Ctrl=true') else Self.Memo_cmd.lines.add('BOOL：Ctrl=false');
  //if State.Shift then Self.Memo_cmd.lines.add('BOOL：Shift=true') else Self.Memo_cmd.lines.add('BOOL：Shift=false');
  //if State.Win then Self.Memo_cmd.lines.add('BOOL：Win=true') else Self.Memo_cmd.lines.add('BOOL：Win=false');


  //这里要进行环形队列

end;


//{$ifdef XMXMXM}

{$R *.lfm}

end.

