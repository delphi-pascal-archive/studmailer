unit uLog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfmLog = class(TForm)
    memMain: TMemo;
    btClear: TButton;
    btHide: TButton;
    btSave: TButton;
    sdMain: TSaveDialog;
    procedure btClearClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure btHideClick(Sender: TObject);
  private
  public
  end;

var
  fmLog: TfmLog;

implementation

{$R *.dfm}

procedure TfmLog.btClearClick(Sender: TObject);
begin
  memMain.Clear;
  sdMain.FileName:='';
end;

procedure TfmLog.btSaveClick(Sender: TObject);
begin
  if sdMain.Execute then
    try
      memMain.Lines.SaveToFile(sdMain.FileName);
    except
      // error message here
    end;
end;

procedure TfmLog.btHideClick(Sender: TObject);
begin
  Close;
end;

end.
