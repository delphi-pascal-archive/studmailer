program StudMail;

uses
  Forms,
  uMain in 'uMain.pas' {fmMain},
  uLog in 'uLog.pas' {fmLog};

{$R *.res}

begin
  Application.Title:='StudMailer v1.0 - by V.Kadyshev & StudForum.ru';
  Application.Initialize;
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmLog, fmLog);
  Application.Run;
end.
