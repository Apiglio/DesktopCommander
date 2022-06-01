library DesktopCommander_dll;

{$mode objfpc}{$H+}

uses
  SysUtils, Windows, Messages, Classes;

var
  NextHook : HHook;
  //调用者的Handle，用来给其发消息
  CallHandle : HWND;
  //通知调用者的消息，由调用者传进来
  MessageID : Word;
  Share:array[0..31]of byte;

//挂钩子函数 ,这里只处理鼠标移动，其他的鼠标动作，道理一样
function HookProc(code:Integer;wParam:WPARAM;lParam:LPARAM):LRESULT;stdcall;
begin
  //Result := 0;
  pint64(@Share)^:=code;
  pint64(@Share+8)^:=wParam;
  pint64(@Share+16)^:=lParam;
  //SendMessage(CallHandle,MessageID,code,int64(@Share));
  SendMessage(CallHandle,MessageID,wParam,Integer(@pMouseHookStruct(lParam)^));

  Result := CallNextHookEx(NextHook,code,wParam,lParam);
end;

//启动钩子
function StartHook(MsgID:Word):Bool;stdcall;
begin
  Result := False;
  if NextHook <> 0 then
    Exit;
  MessageID := MsgID;
  //挂钩,SetWindowsHookEx的参数dwThreadId=0，表示挂全局的
  //不知道为什么，我系统是2003，用WH_MOUSE只能在本进程中实现钩子，WH_MOUSE_LL可以实现全局
  //在Delphi7中，是没有WH_MOUSE_LL定义的，你可以自己定义，值是14
  NextHook := SetWindowsHookEx({WH_MOUSE_LL}14{WH_KEYBOARD}{WH_GETMESSAGE},@HookProc,HInstance,0);
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

exports
  StartHook name 'StartHook',
  StopHook name 'StopHook',
  SetCallHandle name 'SetCallHandle';
  //Share name 'Share';

begin
end.

