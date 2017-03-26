unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ShellCtrls, ComCtrls, ExtDlgs, CheckLst;

type

  { TForm2 }

  TForm2 = class(TForm)
    body: TPanel;
    bottom: TPanel;
    btPlanifOk: TButton;
    btPlanifAnnuler: TButton;
    Jour: TComboBox;
    header: TPanel;
    Jour1: TComboBox;
    Jour2: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Minutes: TComboBox;
    procedure btPlanifAnnulerClick(Sender: TObject);
    procedure btPlanifOkClick(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }
procedure TForm2.btPlanifOkClick(Sender: TObject);
begin
    //CMD PLANIF
end;


procedure TForm2.btPlanifAnnulerClick(Sender: TObject);
begin
     Form2.Close;
end;


end.

