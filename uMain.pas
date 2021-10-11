unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ImgList, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, StdCtrls, Spin, Buttons, ExtCtrls,
  IdMessage;

type
  TfmMain = class(TForm)
    pcMain: TPageControl;
    tsSend: TTabSheet;
    tsGet: TTabSheet;
    IdTCPClient: TIdTCPClient;
    laServer: TLabel;
    edServer: TEdit;
    laPort: TLabel;
    sedPort: TSpinEdit;
    cbAuthetication: TCheckBox;
    laLogin: TLabel;
    edLogin: TEdit;
    edPassword: TEdit;
    laPassword: TLabel;
    edRetAddress: TEdit;
    laRetAddress: TLabel;
    laTo: TLabel;
    edTo: TEdit;
    laSubj: TLabel;
    edSubj: TEdit;
    laText: TLabel;
    memText: TMemo;
    laAttachments: TLabel;
    lvAttachments: TListView;
    sbtAdd: TSpeedButton;
    sbtDelete: TSpeedButton;
    odMain: TOpenDialog;
    sbtSend: TSpeedButton;
    sbtShowLog: TSpeedButton;
    laDeveloper: TLabel;
    laName: TLabel;
    laMadeInRussia: TLabel;
    imgFlag: TImage;
    laWebSiteAddress: TLabel;
    sbtGet: TSpeedButton;
    laPOPServer: TLabel;
    edPOPServer: TEdit;
    sedPOPPort: TSpinEdit;
    laPOPPort: TLabel;
    laPOPLogin: TLabel;
    edPOPLogin: TEdit;
    edPOPPassword: TEdit;
    laPOPPassword: TLabel;
    laMailAttachments: TLabel;
    lvMailAttachments: TListView;
    laMailText: TLabel;
    memMailText: TMemo;
    lvMails: TListView;
    laMails: TLabel;
    sbtSaveAttach: TSpeedButton;
    IdMessage1: TIdMessage;
    sdMain: TSaveDialog;
    procedure cbAutheticationClick(Sender: TObject);
    procedure sbtAddClick(Sender: TObject);
    procedure sbtDeleteClick(Sender: TObject);
    procedure sbtShowLogClick(Sender: TObject);
    procedure sbtSendClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvAttachmentsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure laWebSiteAddressMouseEnter(Sender: TObject);
    procedure laWebSiteAddressMouseLeave(Sender: TObject);
    procedure laWebSiteAddressClick(Sender: TObject);
    procedure lvMailAttachmentsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure sbtGetClick(Sender: TObject);
    procedure lvMailsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure sbtSaveAttachClick(Sender: TObject);
  private
    procedure AddLineToLog(const sIn: String);
    procedure EnableControls(bEnable: boolean);
    procedure LogAllIncoming;
    procedure LogOutcoming(const s: String);
    function CheckPOPResponse: boolean;
    procedure ParseMail(const s: String);
    procedure EnablePOPControls(bEnable: boolean);
  public
  end;

var
  fmMain: TfmMain;

implementation

uses
  ShellAPI, uLog, DIMime;

{$R *.dfm}

procedure TfmMain.AddLineToLog(const sIn: String);
begin
  fmLog.memMain.Lines.Add(sIn);
end;

procedure TfmMain.EnableControls(bEnable: boolean);
begin
  laServer.Enabled:=bEnable;
  edServer.Enabled:=bEnable;
  if bEnable then
    edServer.Color:=clWindow
  else
    edServer.Color:=clBtnFace;

  laPort.Enabled:=bEnable;
  sedPort.Enabled:=bEnable;
  if bEnable then
    sedPort.Color:=clWindow
  else
    sedPort.Color:=clBtnFace;

  laTo.Enabled:=bEnable;
  edTo.Enabled:=bEnable;
  if bEnable then
    edTo.Color:=clWindow
  else
    edTo.Color:=clBtnFace;

  laRetAddress.Enabled:=bEnable;
  edRetAddress.Enabled:=bEnable;
  if bEnable then
    edRetAddress.Color:=clWindow
  else
    edRetAddress.Color:=clBtnFace;

  cbAuthetication.Enabled:=bEnable;

  if bEnable then
    cbAutheticationClick(Self)
  else
    begin
      laLogin.Enabled:=false;
      edLogin.Enabled:=false;
      edLogin.Color:=clBtnFace;

      laPassword.Enabled:=false;
      edPassword.Enabled:=false;
      edPassword.Color:=clBtnFace;
    end;

  laSubj.Enabled:=bEnable;
  edSubj.Enabled:=bEnable;
  if bEnable then
    edSubj.Color:=clWindow
  else
    edSubj.Color:=clBtnFace;

  laText.Enabled:=bEnable;
  memText.Enabled:=bEnable;

  laAttachments.Enabled:=bEnable;
  lvAttachments.Enabled:=bEnable;

  sbtAdd.Enabled:=bEnable;
  if bEnable then
    sbtDelete.Enabled:=lvAttachments.SelCount > 0
  else
    sbtDelete.Enabled:=false;
  sbtSend.Enabled:=bEnable;
end;

procedure TfmMain.cbAutheticationClick(Sender: TObject);
var
  bEnable: boolean;
begin
  bEnable:=cbAuthetication.Checked;

  laLogin.Enabled:=bEnable;
  edLogin.Enabled:=bEnable;
  if bEnable then
    edLogin.Color:=clWindow
  else
    edLogin.Color:=clBtnFace;

  laPassword.Enabled:=bEnable;
  edPassword.Enabled:=bEnable;
  if bEnable then
    edPassword.Color:=clWindow
  else
    edPassword.Color:=clBtnFace;
end;

procedure TfmMain.sbtAddClick(Sender: TObject);
var
  i: Integer;
begin
  if odMain.Execute then
    for i:=0 to odMain.Files.Count-1 do
      with lvAttachments.Items.Add do
        begin
          Caption:=ExtractFileName(odMain.Files[i]);
          SubItems.Add(odMain.Files[i]);
        end;
end;

procedure TfmMain.sbtDeleteClick(Sender: TObject);
begin
  lvAttachments.DeleteSelected;
end;

procedure TfmMain.sbtShowLogClick(Sender: TObject);
begin
  if fmLog.Visible then
    fmLog.SetFocus
  else
    fmLog.Visible:=true;
end;

function ReadFileIntoString(const sFilePath: String): String;
var
  FileSize: Integer;
  DataFile: Integer;
begin
  DataFile:=FileOpen(sFilePath, fmOpenRead);
  if DataFile = -1 then
    Exit;
  FileSize:=FileSeek(DataFile, 0, 2);
  FileSeek(DataFile, 0, 0);
  try
    SetLength(Result, FileSize);
    FileRead(DataFile, Pointer(Result)^, FileSize);
  finally
    FileClose(DataFile);
  end;
end;

procedure TfmMain.LogAllIncoming;
var
  i: Integer;
begin
  for i:=0 to IdTCPClient.LastCmdResult.Text.Count-1 do
    AddLineToLog('< '+IdTCPClient.LastCmdResult.Text[i]);
end;

procedure TfmMain.LogOutcoming(const s: String);
var
  SL: TStringList;
  i: Integer;
begin
  SL:=TStringList.Create;
  try
    SL.Text:=s;
    for i:=0 to SL.Count-1 do
      AddLineToLog('> '+SL[i]);
  finally
    SL.Free;
  end;
end;

procedure TfmMain.sbtSendClick(Sender: TObject);
var
  ts: String;
  i: Integer;

  sBoundary: String;
begin
  EnableControls(false);
  try
    sbtShowLog.Click;
    
    IdTCPClient.Host:=edServer.Text;
    IdTCPClient.Port:=sedPort.Value;
    IdTCPClient.Connect;
    IdTCPClient.GetResponse([220]);
    LogAllIncoming;

    LogOutcoming('HELO StudForum.ru');
    IdTCPClient.SendCmd('HELO StudForum.ru', 250);
    LogAllIncoming;

    if cbAuthetication.Checked then
      begin
        LogOutcoming('AUTH LOGIN');
        IdTCPClient.SendCmd('AUTH LOGIN', 334);
        LogAllIncoming;

        ts:=MimeEncodeString(edLogin.Text);
        LogOutcoming(ts);
        IdTCPClient.SendCmd(ts, 334);
        LogAllIncoming;

        ts:=MimeEncodeString(edPassword.Text);
        LogOutcoming(ts);
        IdTCPClient.SendCmd(ts, 235);
        LogAllIncoming;
      end;

    LogOutcoming('MAIL FROM:<'+edRetAddress.Text+'>');
    IdTCPClient.SendCmd('MAIL FROM:<'+edRetAddress.Text+'>', 250);
    LogAllIncoming;

    LogOutcoming('RCPT TO:<'+edTo.Text+'>');
    IdTCPClient.SendCmd('RCPT TO:<'+edTo.Text+'>', [250, 251]);
    LogAllIncoming;

    LogOutcoming('DATA');
    IdTCPClient.SendCmd('DATA', 354);
    LogAllIncoming;

    LogOutcoming('X-Mailer: StudMailer');
    IdTCPClient.WriteLn('X-Mailer: StudMailer');

    LogOutcoming('From: '+edRetAddress.Text);
    IdTCPClient.WriteLn('From: '+edRetAddress.Text);

    LogOutcoming('To: '+edTo.Text);
    IdTCPClient.WriteLn('To: '+edTo.Text);

    if lvAttachments.Items.Count > 0 then
      begin
        sBoundary:='StudMailer_by_StudForum.RU';
        LogOutcoming('MIME-Version: 1.0'#13#10'Content-Type: multipart/mixed; boundary="'+sBoundary+'"');
        IdTCPClient.WriteLn('MIME-Version: 1.0'#13#10'Content-Type: multipart/mixed; boundary="'+sBoundary+'"');
      end
    else
      begin
        LogOutcoming('MIME-Version: 1.0'#13#10'Content-Type: text/plain; charset=windows-1251');
        IdTCPClient.WriteLn('MIME-Version: 1.0'#13#10'Content-Type: text/plain; charset=windows-1251');
      end;


    LogOutcoming('Subject: '+edSubj.Text+#13#10#13#10);
    IdTCPClient.WriteLn('Subject: '+edSubj.Text+#13#10);

    if lvAttachments.Items.Count > 0 then
      begin
        LogOutcoming('--'+sBoundary+#13#10#13#10);
        IdTCPClient.WriteLn('--'+sBoundary+#13#10);
      end;
    
    LogOutcoming(memText.Lines.Text);
    IdTCPClient.WriteLn(memText.Lines.Text);

    for i:=0 to lvAttachments.Items.Count-1 do
      begin
        LogOutcoming('--'+sBoundary);
        IdTCPClient.WriteLn('--'+sBoundary);


        LogOutcoming('Content-Type: application/octet-stream; name="'+lvAttachments.Items[i].Caption+'"'#13#10+
'Content-Disposition: attachment; filename="'+lvAttachments.Items[i].Caption+'"'#13#10+
'Content-Transfer-Encoding: base64'#13#10#13#10);
        IdTCPClient.WriteLn('Content-Type: application/octet-stream; name="'+lvAttachments.Items[i].Caption+'"'#13#10+
'Content-Disposition: attachment; filename="'+lvAttachments.Items[i].Caption+'"'#13#10+
'Content-Transfer-Encoding: base64'#13#10);

        ts:=MimeEncodeString(ReadFileIntoString(lvAttachments.Items[i].SubItems[0]));
        LogOutcoming(ts);
        IdTCPClient.WriteLn(ts);
      end;                  

    LogOutcoming('.');
    IdTCPClient.SendCmd('.', 250);
    LogAllIncoming;

    LogOutcoming('QUIT');
    IdTCPClient.WriteLn('QUIT');
  finally
    IdTCPClient.Disconnect;
    EnableControls(true);
  end;
end;         

procedure AddDisabledBMP(SB: array of TObject);
var
  BM, SBM: TBitmap;
  w, x, y, NewColor, i: Integer;
  PixelColor: TColor;
begin
  BM:=TBitmap.Create;
  SBM:=TBitmap.Create;

  try
    for i:=0 to High(SB) do
      begin
        if (SB[i] is TSpeedButton) then
          BM.Assign((SB[i] as TSpeedButton).Glyph)
        else
          if (SB[i] is TBitBtn) then
            BM.Assign((SB[i] as TBitBtn).Glyph)
          else
            Exit;

        if not Assigned(BM) or (BM.Width <> BM.Height) then Exit;

        w:=BM.Width;
        SBM.Width:=w*2;
        SBM.Height:=w;
        SBM.Canvas.Draw(0, 0, BM);

          for x:=0 to w - 1 do
            for y:=0 to w - 1 do begin
              PixelColor:=ColorToRGB(BM.Canvas.Pixels[x, y]);
              NewColor:=Round((((PixelColor shr 16) + ((PixelColor shr 8) and $00FF) +
                         (PixelColor and $0000FF)) div 3)) div 2 + 96;
              BM.Canvas.Pixels[x, y]:=RGB(NewColor, NewColor, NewColor);
            end;

        SBM.Canvas.Draw(w, 0, BM);

        if (SB[i] is TSpeedButton) then
          with (SB[i] as TSpeedButton) do
            begin
              Glyph.Assign(SBM);
              NumGlyphs:=2;
            end
        else
          with (SB[i] as TBitBtn) do
            begin
              Glyph.Assign(SBM);
              NumGlyphs:=2;
            end;

        BM:=TBitmap.Create;
        SBM:=TBitmap.Create;
      end;
  finally
    BM.Free;
    SBM.Free;
  end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  AddDisabledBMP([sbtAdd, sbtDelete, sbtSend, sbtSaveAttach, sbtGet])
end;

procedure TfmMain.lvAttachmentsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  sbtDelete.Enabled:=lvAttachments.SelCount > 0;
end;

procedure TfmMain.laWebSiteAddressMouseEnter(Sender: TObject);
begin
  (Sender as TLabel).Font.Color:=clRed;
end;

procedure TfmMain.laWebSiteAddressMouseLeave(Sender: TObject);
begin
  (Sender as TLabel).Font.Color:=clBlue;
end;

procedure TfmMain.laWebSiteAddressClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, PChar('open'), PChar('http://www.studforum.ru'), nil, nil, SW_NORMAL);
end;

procedure TfmMain.lvMailAttachmentsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  sbtSaveAttach.Enabled:=lvMailAttachments.SelCount > 0;
end;

function TfmMain.CheckPOPResponse: boolean;
begin
  IdTCPClient.GetInternalResponse;
  if AnsiSameText(IdTCPClient.LastCmdResult.TextCode, '+OK') then
    Result:=true
  else
    Result:=false;
end;

procedure TfmMain.ParseMail(const s: String);
var
  i: Integer;
  Stream: TMemoryStream;
begin
  memMailText.Clear;
  lvMailAttachments.Clear;

  Stream:=TMemoryStream.Create;
  try
    Stream.Write(s[1], Length(s));
    Stream.Seek(0, soFromBeginning);
    IdMessage1.LoadFromStream(Stream);

    if IdMessage1.MessageParts.Count = 0 then
      memMailText.Lines.AddStrings(IdMessage1.Body)
    else
      for i:=0 to IdMessage1.MessageParts.Count-1 do
        if IdMessage1.MessageParts[i] is TIdAttachment then
          with lvMailAttachments.Items.Add do
            Caption:=(IdMessage1.MessageParts[i] as TIdAttachment).FileName
        else
          if IdMessage1.MessageParts[i] is TIdText then
            memMailText.Lines.AddStrings((IdMessage1.MessageParts[i] as TIdText).Body);
  finally
    Stream.Free;
  end;
end;

procedure TfmMain.EnablePOPControls(bEnable: boolean);
begin
  laPOPServer.Enabled:=bEnable;
  edPOPServer.Enabled:=bEnable;
  if bEnable then
    edPOPServer.Color:=clWindow
  else
    edPOPServer.Color:=clBtnFace;

  laPOPPort.Enabled:=bEnable;
  sedPOPPort.Enabled:=bEnable;
  if bEnable then
    sedPOPPort.Color:=clWindow
  else
    sedPOPPort.Color:=clBtnFace;

  laPOPLogin.Enabled:=bEnable;
  edPOPLogin.Enabled:=bEnable;
  if bEnable then
    edPOPLogin.Color:=clWindow
  else
    edPOPLogin.Color:=clBtnFace;

  laPOPPassword.Enabled:=bEnable;
  edPOPPassword.Enabled:=bEnable;
  if bEnable then
    edPOPPassword.Color:=clWindow
  else
    edPOPPassword.Color:=clBtnFace;

  sbtGet.Enabled:=bEnable;
end;

procedure TfmMain.sbtGetClick(Sender: TObject);
var
  iMesCount, i: Integer;
  ts, sFrom, sTo, sSubj: String;
  slTemp: TStringList;
begin
  EnablePOPControls(false);
  try
    lvMails.Clear;
    memMailText.Clear;
    lvMailAttachments.Clear;

    sbtShowLog.Click;

    IdTCPClient.Host:=edPOPServer.Text;
    IdTCPClient.Port:=sedPOPPort.Value;
    IdTCPClient.Connect;
    if not CheckPOPResponse then
      Exit;
    LogAllIncoming;

    LogOutcoming('USER '+edPOPLogin.Text);
    IdTCPClient.WriteLn('USER '+edPOPLogin.Text);
    if not CheckPOPResponse then
      Exit;
    LogAllIncoming;

    LogOutcoming('PASS '+edPOPPassword.Text);
    IdTCPClient.WriteLn('PASS '+edPOPPassword.Text);
    if not CheckPOPResponse then
      Exit;
    LogAllIncoming;

    LogOutcoming('STAT');
    IdTCPClient.WriteLn('STAT');
    if not CheckPOPResponse then
      Exit;
    LogAllIncoming;

    iMesCount:=0;
    ts:=IdTCPClient.LastCmdResult.Text[0];
    Delete(ts, 1, 4);
    if Length(ts) > 0 then
      iMesCount:=StrToInt(Copy(ts, 1, Pos(' ', ts)-1));

    slTemp:=TStringList.Create;
    try
      for i:=1 to iMesCount do
        begin
          LogOutcoming('RETR '+IntToStr(i));
          IdTCPClient.WriteLn('RETR '+IntToStr(i));
          if not CheckPOPResponse then
            Exit;
          LogAllIncoming;

          slTemp.Clear;
          ts:='';
          sFrom:='';
          sTo:='';
          sSubj:='';

          while ts <> '.' do
            begin
              ts:=IdTCPClient.ReadLn;
              if Copy(UpperCase(ts), 1, 5)='FROM:' then
                 sFrom:=Trim(Copy(ts, 6, MaxInt));
              if Copy(UpperCase(ts), 1, 3)='TO:' then
                 sTo:=Trim(Copy(ts, 4, MaxInt));
              if Copy(UpperCase(ts), 1, 8)='SUBJECT:' then
                 sSubj:=Trim(Copy(ts, 9, MaxInt));
              slTemp.Add(ts);
            end;

          with lvMails.Items.Add do
            begin
              Caption:=sFrom;
              SubItems.Add(sTo);
              SubItems.Add(sSubj);
              SubItems.Add(slTemp.Text);
            end;
        end;
    finally
      slTemp.Free;
    end;

  finally
    IdTCPClient.Disconnect;
    EnablePOPControls(true);
  end;
end;

procedure TfmMain.lvMailsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if lvMails.Selected <> nil then
    ParseMail(lvMails.Selected.SubItems[2]);
end;

procedure TfmMain.sbtSaveAttachClick(Sender: TObject);
var
  i, Cnt, Idx: Integer;
begin
  Idx:=lvMailAttachments.Selected.Index;
  Cnt:=0;
  i:=0;

  while (i < IdMessage1.MessageParts.Count) do
    begin
      if IdMessage1.MessageParts[i] is TIdAttachment then
        if Cnt = Idx then
          begin
            sdMain.FileName:=(IdMessage1.MessageParts[i] as TIdAttachment).FileName;
            sdMain.InitialDir:=ExtractFilePath(Application.ExeName);

            if sdMain.Execute then
              (IdMessage1.MessageParts[i] as TIdAttachment).SaveToFile(sdMain.FileName);

            Exit;
          end
        else
          Inc(Cnt);

      Inc(i);
    end;
end;

end.
