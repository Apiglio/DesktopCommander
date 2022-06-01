library DesktopCommander_keyboard_dll;

{$mode objfpc}{$H+}

uses
  SysUtils, Windows, Messages, Classes;

var
  NextHook:HHook;//调用者的Handle，用来给其发消息
  CallHandle:HWND;//通知调用者的消息，由调用者传进来
  MessageID:Word;
  BlockMsg:Boolean = False;

//挂钩子函数
function HookProc(code:Integer;wParam:WPARAM;lParam:LPARAM):LRESULT;stdcall;
var tmpBool:boolean;
begin
  tmpBool:=BlockMsg;
  SendMessage(CallHandle,MessageID,wParam,lParam);
  if tmpBool then begin
    Result:=1;
    //beep(2000,2);
  end else begin
    Result:=CallNextHookEx(NextHook,code,wParam,lParam);
    //beep(800,2);
  end;
end;

//启动钩子
function StartHook(MsgID:Word):Bool;stdcall;
begin
  Result := False;
  if NextHook <> 0 then Exit;
  MessageID := MsgID;
  NextHook := SetWindowsHookEx({WH_KEYBOARD_LL}13,@HookProc,HInstance,0);
  Result := NextHook <> 0;
end;

//脱钩
function StopHook:Bool;stdcall;
begin
  if NextHook <> 0 then
  begin
    UnHookWindowsHookEx(NextHook);
    NextHook := 0;
  end;
  Result := NextHook = 0;
end;

//传递调用者句柄
procedure SetCallHandle(sender:HWND);stdcall;
begin
  CallHandle := sender;
  NextHook := 0;
end;

procedure BlockMsgOn;
begin
  BlockMsg:=True;
end;

procedure BlockMsgOff;
begin
  BlockMsg:=False;
end;


exports
  StartHook name 'StartHook',
  StopHook name 'StopHook',
  SetCallHandle name 'SetCallHandle',
  BlockMsgOn name 'BlockMsgOn',
  BlockMsgOff name 'BlockMsgOff';

begin
end.

