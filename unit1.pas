unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, JvValidators, JvHtControls, JvNavigationPane,
  Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ActnList, ComCtrls,
  ShellCtrls, CheckLst, Menus, Windows, Process, strutils, Unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    btSauvegarde: TButton;
    Button1: TButton;
    ChargerProfil: TButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    Planif: TButton;
    btParcourir: TButton;
    CheckListBox1: TCheckListBox;
    editParcourir: TEdit;
    labelEmplacement: TLabel;
    Label4: TLabel;
    ListBox1: TListBox;
    header: TPanel;
    body: TPanel;
    bottom: TPanel;
    progressSauvegarde: TProgressBar;
    dialog: TSelectDirectoryDialog;
    ShellTreeView1: TShellTreeView;
    AStringList: TStringList;
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure btSauvegardeClick(Sender: TObject);
    procedure PlanifClick(Sender: TObject);
    procedure btParcourirClick(Sender: TObject);
    procedure CopyDir(Sender: TObject);
    procedure DestDir(Sender: TObject);
  private
  public

  end;

var
  Form1: TForm1;
  ADecouper: string;
  NomDossier: string;
  ts: char;
  fichierSauvegarde: TextFile;
  ligne: string;

implementation

{$R *.lfm}

{ TForm1 }
procedure TForm1.FormCreate(Sender: TObject);
begin
  AssignFile(fichierSauvegarde, 'config.txt');
  reset(fichierSauvegarde);
  while not EOF(fichierSauvegarde) do
    begin
    readLn(fichierSauvegarde, ligne);
    ComboBox1.AddItem(ligne, ComboBox1);
    end;
  closefile(fichierSauvegarde);
end;

procedure TForm1.CopyDir(Sender: TObject);
begin
  ADecouper := ShellTreeView1.GetPathFromNode(ShellTreeView1.Selected);
  NomDossier := ShellTreeView1.GetRootPath;
  Delete(ADecouper, Length(ADecouper), 1);
  ExtractFileName(ADecouper);
  ListBox1.Items.Add(ADecouper);

end;

procedure TForm1.DestDir(Sender: TObject);
begin
  editParcourir.Text := dialog.FileName;
end;

procedure TForm1.btParcourirClick(Sender: TObject);

begin
  dialog.Execute;
end;

procedure TForm1.btSauvegardeClick(Sender: TObject);

var
  i: integer;
  dSrc: string;
  dDest: string;
  prog: string;
  commande: string;
  s: string;
  sl: TStringList;
  posDelim: integer;
  posDroiteDelim: integer;
  totalChar: integer;
  Security: TSecurityAttributes;
  test: QWord;
begin

  //CreatePipe(InputPipeRead, InputPipeWrite, @Security, 0);
  dDest := editParcourir.Text;
  dSrc := '';
  prog := 'cmd.exe';
  progressSauvegarde.Min := 0;
  progressSauvegarde.Max := ListBox1.Items.Count;
  progressSauvegarde.Position := progressSauvegarde.Position + 1;
  for i := 0 to ListBox1.Items.Count - 1 do
  begin
    dSrc := ListBox1.Items.ValueFromIndex[i];

    posDelim := LastDelimiter('\', dSrc);
    totalChar := dSrc.Length;
    posDroiteDelim := totalChar - posDelim;
    s := RightStr(dSrc, posDroiteDelim);
    //Label4.Caption := 'Copie en cours...';
    commande := Concat('/c robocopy "', dSrc, '" "', dDest + s, '" /MIR /W:10 /R:1 /NP /X /log:"log.txt" /v /TEE');
    ShellExecute(0, 'open', PChar(prog), PChar(commande), PChar(extractfilepath(prog)), 1);
    progressSauvegarde.Position := progressSauvegarde.Position + 1;
    Label4.Caption := 'Copie Terminée...';
  end;
  ListBox1.Items.Clear;
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
  ListBox1.Items.Delete(ListBox1.ItemIndex);
end;



procedure TForm1.PlanifClick(Sender: TObject);
begin
  //PopupMenu1.PopUp;
  Form2.Show;
end;

end.
