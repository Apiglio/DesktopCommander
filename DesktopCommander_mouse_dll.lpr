library DesktopCommander_mouse_dll;

{$mode objfpc}{$H+}

uses
  SysUtils, Windows, Messages, Classes;

var
  NextHook : HHook;//调用者的Handle，用来给其发消息
  CallHandle : HWND;//通知调用者的消息，由调用者传进来
  MessageID : Word;
  Share:array[0..31]of byte;
  TrackMouseMove:byte=0;//0-记录所有消息，1-不记录MouseMove

//挂钩子函数
function HookProc(code:Integer;wParam:WPARAM;lParam:LPARAM):LRESULT;stdcall;
begin
  pint64(@Share)^:=code;
  pint64(@Share+8)^:=wParam;
  pint64(@Share+16)^:=lParam;
  if MessageID<>WM_MOUSEMOVE then SendMessage(CallHandle,MessageID,wParam,Integer(@pMouseHookStruct(lParam)^))
  else if TrackMouseMove<>0 then SendMessage(CallHandle,MessageID,wParam,Integer(@pMouseHookStruct(lParam)^));
  Result := CallNextHookEx(NextHook,code,wParam,lParam);
end;

//启动钩子
function StartHook(MsgID:Word):Bool;stdcall;
begin
  Result := False;
  if NextHook <> 0 then
    Exit;
  MessageID := MsgID;
  NextHook := SetWindowsHookEx({WH_MOUSE_LL}14,@HookProc,HInstance,0);
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

procedure SetTrackMouseMove(onoff:byte);stdcall;
begin
  TrackMouseMove:=onoff;
end;

exports
  StartHook name 'StartHook',
  StopHook name 'StopHook',
  SetCallHandle name 'SetCallHandle',
  SetTrackMouseMove name 'SetTrackMouseMove';

begin
end.

