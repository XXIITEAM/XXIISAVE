unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil,
  JvValidators, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ActnList,
  ComCtrls, ShellCtrls, CheckLst, Windows, Process, strutils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button3: TButton;
    CheckListBox1: TCheckListBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ListBox1: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Process1: TProcess;
    ProgressBar1: TProgressBar;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    ShellTreeView1: TShellTreeView;
    AStringList: TStringList;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CopyDir(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure DestDir(Sender: TObject);
  private
  public

  end;

var
  Form1: TForm1;
  ADecouper: String;
  NomDossier: String;
  ts: char;
implementation

{$R *.lfm}

{ TForm1 }


procedure TForm1.CopyDir(Sender: TObject);
begin
    ADecouper := ShellTreeView1.GetPathFromNode(ShellTreeView1.Selected);
    NomDossier:= ShellTreeView1.GetRootPath;
    Delete(ADecouper, Length(ADecouper), 1);
    ExtractFileName(ADecouper);
    ListBox1.Items.Add(ADecouper);

end;

procedure TForm1.DestDir(Sender: TObject);
begin
   Edit1.Text:= SelectDirectoryDialog1.FileName;
end;

procedure TForm1.Button3Click(Sender: TObject);

begin
   SelectDirectoryDialog1.Execute;
end;

procedure TForm1.Button1Click(Sender: TObject);

var
i : Integer;
dSrc : String;
dDest: String;
prog: String;
commande: String;
s: string;
sl: TStringList;
posDelim: Integer;
posDroiteDelim: Integer;
totalChar: Integer;
Security : TSecurityAttributes;
test: QWord;
begin
    Process1.Create(nil);
    Process1.Executable:= 'robocopy';

   //CreatePipe(InputPipeRead, InputPipeWrite, @Security, 0);
    dDest := Edit1.Text;
    dSrc:= '';
    prog:= 'cmd.exe';

    for i := 0 to ListBox1.Items.Count - 1  do
      begin
      dSrc := ListBox1.Items.ValueFromIndex[i];

      posDelim := LastDelimiter('\',dSrc);
      totalChar:= dSrc.Length;
      posDroiteDelim := totalChar - posDelim + 1;
      s := RightStr(dSrc, posDroiteDelim);
      //Label4.Caption := 'Copie en cours...';
      commande:= Concat('/c robocopy ', dSrc, ' ', dDest+s, '\', ' /MIR /W:10 /R:1 /NP /V /X /TEE');
      ShellExecute(0,'open',PChar(prog),PChar(commande),PChar(extractfilepath(prog)), 0);

      Label4.Caption := 'Copie Terminée...';
      end;
end;

procedure TForm1.FormDblClick(Sender: TObject);
begin
     ListBox1.Items.Delete(ListBox1.ItemIndex);
end;

end.

