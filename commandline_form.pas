unit commandline_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Windows, Apiglio_Useful, Dos, LazUtf8;

type

  { TFormCommandLine }

  TFormCommandLine = class(TForm)
    Memo_cmd: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormResize(Sender: TObject);
    procedure Memo_cmdChange(Sender: TObject);
    procedure Memo_cmdKeyPress(Sender: TObject; var Key: char);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormCommandLine: TFormCommandLine;

  //e_file_not_found:TError;

  RunPath:array[0..512]of record
    key:string;
    path:string;
    default_parameter:string;
  end;
  RunPathCount:integer;


  procedure WriteMemo(Sender:TObject;str:string);
  procedure WriteLnMemo(Sender:TObject;str:string);


implementation

uses desktop_commander_unit;

{$R *.lfm}

procedure ReadRunPath;
var tmp:text;
    stmp:string;
    pi:integer;
begin
  assignfile(tmp,'RunPath.ini');
  pi:=0;
  try
    reset(tmp);
    repeat
      readln(tmp,stmp);
      Auf.ReadArgs(stmp);
      if Auf.nargs[0].arg<>'' then
        begin
          RunPath[pi].key:=Auf.nargs[0].arg;
          RunPath[pi].path:=Auf.nargs[1].arg;
          RunPath[pi].default_parameter:=Auf.nargs[2].arg;
        end;
      inc(pi);
    until eof(tmp);
    RunPathCount:=pi;
    closefile(tmp);
  except
    Auf.Script.writeln('未找到RunPath.ini');
  end;
end;


procedure base_hideform;
begin
  FormCommandLine.Memo_cmd.Clear;
  SetWindowPos(FormCommandLine.Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
  FormCommandLine.Hide;
  Application.ProcessMessages;
end;

procedure base_halt(Sender:TObject);
begin
  halt;
end;

procedure show_debuger(Sender:TObject);
begin
  CommandForm.Show;
  CommandForm.SetFocus;
end;

procedure shortcut(Sender:TObject);
var path,param:string;
    pi:integer;
begin
  //if Auf.nargs[0].pre<>'$' then break;
  pi:=0;
  while pi<RunPathCount do
    begin
      if RunPath[pi].key=Auf.nargs[0].arg then break;
      inc(pi);
    end;
  try
    if Auf.nargs[1].arg='' then param:=RunPath[pi].default_parameter
    else param:=utf8towincp(Auf.nargs[1].arg);
    winexec(Usf.ExPChar(RunPath[pi].path+param),SW_SHOWNORMAL);
    //base_hideform;
    postmessage(FormCommandLine.Memo_cmd.Handle,WM_KeyDown,27,$1b0001);
  except
    Auf.Script.writeln('打开失败');
  end;
end;


procedure WriteMemo(Sender:TObject;str:string);
var tmp:string;
begin
  tmp:=FormCommandLine.Memo_cmd.Lines.Strings[FormCommandLine.Memo_cmd.Lines.Count-1];
  FormCommandLine.Memo_cmd.Lines.Strings[FormCommandLine.Memo_cmd.Lines.Count-1]:=tmp+str;
end;
procedure WriteLnMemo(Sender:TObject;str:string);
var tmp:string;
begin
  FormCommandLine.Memo_cmd.lines.Add(str);
end;
procedure RenewMemo(Sender:TObject);
begin
  Application.ProcessMessages;
end;

{
procedure Init_Error;
begin
  e_file_not_found:=Exception.Create('未找到文件');
end;
}

{ TFormCommandLine }

procedure TFormCommandLine.FormCreate(Sender: TObject);
var pi:integer;
begin
  Show;
  Left:=0;
  Top:=0;
  Height:=90;
  Width:=640;
  FormResize(nil);
  Hide;
  Auf.Script.IO_fptr.echo:=@WritelnMemo;
  Auf.Script.IO_fptr.error:=@WritelnMemo;
  //Auf.Script.IO_fptr.pause:=@WriteMemo;
  Auf.Script.IO_fptr.print:=@WriteMemo;
  Auf.Script.Func_process.post:=@RenewMemo;
  Auf.Script.Func_process.mid:=@RenewMemo;
  Auf.Script.Func_process.pre:=@RenewMemo;

  ReadRunPath;
  for pi:=0 to RunPathCount-1 do
    begin
      Auf.Script.add_func(RunPath[pi].key,@shortcut,'','打开'+RunPath[pi].path);
    end;
  Auf.Script.add_func('debuger',@show_debuger,'','显示调试窗口');
  Auf.Script.add_func('exit',@base_halt,'','关闭并卸载全局钩子');

end;

procedure TFormCommandLine.FormDeactivate(Sender: TObject);
begin
  Self.Hide;
end;

procedure TFormCommandLine.FormKeyPress(Sender: TObject; var Key: char);
begin

end;

procedure TFormCommandLine.FormResize(Sender: TObject);
begin
  Memo_cmd.Width:=Width;
  Memo_cmd.Left:=0;
  Memo_cmd.Height:=Height;
  Memo_cmd.Top:=Top;
end;

procedure TFormCommandLine.Memo_cmdChange(Sender: TObject);
var h:word;
begin
  h:=Memo_cmd.Lines.Count*36;
  if h<36 then h:=36;
  if h>36*7 then h:=36*7;
  Height:=h+54;
end;

procedure TFormCommandLine.Memo_cmdKeyPress(Sender: TObject; var Key: char);
begin
  case Key of
    #27:
      begin
        {
        Memo_cmd.Clear;
        SetWindowPos(Self.Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
        Hide;
        }
        base_hideform;
      end;
    #13:
      begin
        if State.Ctrl then else
          begin
            WriteLnMemo(nil,'end');
            Application.ProcessMessages;
            WriteLnMemo(nil,'>>>');
            Application.ProcessMessages;
            Auf.Script.command(Memo_cmd.Lines);
          end;
      end;
    else ;
  end;
end;



end.

