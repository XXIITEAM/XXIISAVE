unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, JvValidators, JvHtControls, JvNavigationPane,
  Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ActnList, ComCtrls,
  ShellCtrls, CheckLst, Menus, Windows, Process, strutils, Unit2, Unit4;

const
  BUF_SIZE = 2048; // Buffer size for reading the output in chunks

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
    procedure FormShow(Sender: TObject);
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
  AProcess     : TProcess;
  OutputStream : TStream;
  BytesRead    : longint;
  Buffer       : array[1..BUF_SIZE] of byte;

  Form1: TForm1;
  ADecouper: string;
  NomDossier: string;
  ts: char;
  fichierSauvegarde: TextFile;
  ligne: string;
    dSrc: string;
  dDest: string;

  prog: string;
  commande: string;
    i: integer;

  s: string;
  sl: TStringList;
  posDelim: integer;
  posDroiteDelim: integer;
  totalChar: integer;
  Security: TSecurityAttributes;
  test: QWord;

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

procedure TForm1.FormShow(Sender: TObject);
begin
  Form4.Show;
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
begin
  if (editParcourir.Text <> 'Choisissez un emplacement de sauvegarde...') and (editParcourir.Text <> '') then
  begin
    //CreatePipe(InputPipeRead, InputPipeWrite, @Security, 0);
    dDest := editParcourir.Text+'\';
    dSrc := '';
    prog := 'cmd.exe';
    progressSauvegarde.Min := 0;
    progressSauvegarde.Max := ListBox1.Items.Count;
    //progressSauvegarde.Position := progressSauvegarde.Position + 1;
    for i := 0 to ListBox1.Items.Count - 1 do
      begin
        dSrc := ListBox1.Items.ValueFromIndex[i];
        posDelim := LastDelimiter('\', dSrc);
        totalChar := dSrc.Length;
        posDroiteDelim := totalChar - posDelim;
        s := RightStr(dSrc, posDroiteDelim);
        commande := Concat('robocopy "', dSrc, '" "', dDest + s, '" /MIR /W:10 /R:1 /NP /X /log:"log.txt" /v /TEE');
        //ShellExecute(0, 'open', PChar(prog), PChar(commande), PChar(extractfilepath(prog)), 1);


        // Set up the process; as an example a recursive directory search is used
        // because that will usually result in a lot of data.
        AProcess := TProcess.Create(nil);

        // The commands for Windows and *nix are different hence the $IFDEFs
        {$IFDEF Windows}
          // In Windows the dir command cannot be used directly because it's a build-in
          // shell command. Therefore cmd.exe and the extra parameters are needed.
          AProcess.Executable := 'c:\windows\system32\cmd.exe';
          AProcess.Parameters.Add('/c');
          AProcess.Parameters.Add(commande);
        {$ENDIF Windows}

        {$IFDEF Unix}
          //AProcess.Executable := '/bin/ls';
          //AProcess.Parameters.Add('--recursive');
          //AProcess.Parameters.Add('--all');
          //AProcess.Parameters.Add('-l');
        {$ENDIF Unix}

        // Process option poUsePipes has to be used so the output can be captured.
        // Process option poWaitOnExit can not be used because that would block
        // this program, preventing it from reading the output data of the process.
        if i = ListBox1.Items.Count - 1 then
        begin
        AProcess.Options := [poWaitOnExit];
        AProcess.Options := AProcess.Options + [poUsePipes];
        end
        else
        begin
        AProcess.Options := AProcess.Options + [poUsePipes];
        end;
        AProcess.ShowWindow:= swoHIDE;
        // Start the process (run the dir/ls command)
        AProcess.Execute;

        // Create a stream object to store the generated output in. This could
        // also be a file stream to directly save the output to disk.
        OutputStream := TMemoryStream.Create;

        // All generated output from AProcess is read in a loop until no more data is available
        repeat
          // Get the new data from the process to a maximum of the buffer size that was allocated.
          // Note that all read(...) calls will block except for the last one, which returns 0 (zero).
          BytesRead := AProcess.Output.Read(Buffer, BUF_SIZE);

          // Add the bytes that were read to the stream for later usage
          OutputStream.Write(Buffer, BytesRead)

        until BytesRead = 0;  // Stop if no more data is available

        // The process has finished so it can be cleaned up
        AProcess.Free;

        // Now that all data has been read it can be used; for example to save it to a file on disk
        //with TFileStream.Create('output.txt', fmCreate) do
        //begin
        //     OutputStream.Position := 0; // Required to make sure all data is copied from the start
        //     CopyFrom(OutputStream, OutputStream.Size);
        //     Free
        //end;
        //// Or the data can be shown on screen
        with TStringList.Create do
        begin
          OutputStream.Position := 0; // Required to make sure all data is copied from the start
          LoadFromStream(OutputStream);
          //writeln(Text);
          //writeln('--- Number of lines = ', Count, '----');
           Unit4.Form4.MemoLog.Lines.Add(Text + Chr(13));
          Free
        end;

        // Clean up
        OutputStream.Free;
        progressSauvegarde.Position := i +1;
      end;
      ListBox1.Items.Clear;

      Label4.Caption := 'Copie Terminée...';
    end;
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
