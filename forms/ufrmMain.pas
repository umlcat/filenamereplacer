unit ufrmMain;

interface

uses
  LCLIntf, LCLType, LMessages,
  Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, Buttons, ExtCtrls, ComCtrls,
  {$IFDEF FPC}
  MaskEdit,
  {$ENDIF}
  //ToolEdit,
  CheckLst, EditBtn,
  umlcossys, umlcossearchfiles,
  umlcstrings,
  umlcmsgdlgtypes,
  umlcmsgdlgs,
  umlcmsgdlgsmemos,
  ResStrs, ufrmAbout,
  dummy;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnHelp: TBitBtn;
    sbStatusBar: TStatusBar;
    pnTop: TPanel;
    btnExit: TBitBtn;
    chbConfirmReplacement: TCheckBox;
    btnAbout: TBitBtn;
    btnOptions: TBitBtn;
    pnCtrls: TPanel;
    deedFilePath: TDirectoryEdit;
    btnFileSearch: TBitBtn;
    btnFileReplace: TBitBtn;
    chlbDestination: TCheckListBox;
    lblFilePath: TLabel;
    lblSourceFileName: TLabel;
    lblDestFileName: TLabel;
    btnSelectNone: TBitBtn;
    btnSelectALL: TBitBtn;
    edSourceFileName: TEdit;
    edDestFileName: TEdit;
    procedure btnHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnFileSearchClick(Sender: TObject);
    procedure btnFileReplaceClick(Sender: TObject);
    procedure deedFilePathChange(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnOptionsClick(Sender: TObject);
    procedure btnSelectALLClick(Sender: TObject);
    procedure btnSelectNoneClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    FilePath: string;

    SourceFileName: string;
    DestFileName: string;

    Wildcard: string;

    procedure LoadValues();
    procedure LoadStrings();

    procedure FileSearch();
    procedure FileReplace();
  end;

var
  frmMain: TfrmMain;

implementation

{$IFDEF FPC}
{$R *.LFM}
{$ENDIF}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  LoadValues();
  LoadStrings();
end;

procedure TfrmMain.btnHelpClick(Sender: TObject);
begin
  umlcmsgdlgsmemos.ShowMessage('Hello World');
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmMain.LoadValues();
var AppPath, ConfigFilename: string; F: TextFile;
begin
  AppPath := ParamStr(0);
  //@to-do: folder sep.
  ConfigFilename := ExtractFileDir(AppPath) + DirectorySeparator + 'ExtReplacer.txt';

  if (umlcossys.FileFound(ConfigFilename)) then
  begin
    System.Assign(F, ConfigFilename);
    System.Reset(F);

//    if not System.EoF(F)
//      then System.ReadLn(F, WindowsFolder);

    System.Close(F);
  end else
  begin
//    WindowsFolder := 'C:\WINDOWS\SYSTEM';
  end
end;

procedure TfrmMain.LoadStrings();
begin
  Self.Caption := resTfrMain_Caption;
  Application.Title := resTfrMain_Caption;
  
  chbConfirmReplacement.Caption := reschbConfirmReplaced_Caption;

  btnFileReplace.Caption := resbtnFileReplace_Caption;
  btnFileSearch.Caption  := resbtnFileSearch_Caption;

  btnExit.Caption    := resbtnExit_Caption;
  btnHelp.Caption    := resbtnHelp_Caption;
  btnAbout.Caption   := resbtnAbout_Caption;
  btnOptions.Caption := resbtnOptions_Caption;
  btnSelectALL.Caption  := resbtnSelectALL_Caption;
  btnSelectNone.Caption := resbtnSelectNone_Caption;

  lblSourceFileName.Caption := reslblSourceFileName_Caption;
  lblDestFileName.Caption   := reslblDestFileName_Caption;
  lblFilePath.Caption  := reslblFilePath_Caption;
  deedFilePath.Text := '';
end;

procedure TfrmMain.FileSearch();
var SearchRecord: TSearchFilesRecord;
    FileRecord: TFileRecord; ACount: Integer; Path: string;
    SourceName, SourceFileExt: string;
    CanSave: Boolean;
begin
  with chlbDestination.Items do
  begin
    Clear();

    Path := deedFilePath.Text;

    // obtener subcadena a buscar
    SourceName :=
      umlcstrings.TrimPosfixCopy(edSourceFileName.Text, ExtensionSeparator);

    SourceFileExt := '*' + SourceName + '*' + ExtensionSeparator + '*';

    Path := FilePath + DirectorySeparator + SourceFileExt;
    FileSearchInit(SearchRecord, Path, faArchive);

    ACount := 0;
    while (FileSearchNext(SearchRecord, FileRecord)) do
    begin
      CanSave :=
        (not FileRecord.IsOwnFolder) and
        (not FileRecord.IsParentFolder);
      if (CanSave) then
      begin
        SourceFileExt :=
          FileRecord.FileName + FileRecord.FileExt;
        Add(SourceFileExt);
        Inc(ACount);
      end; 
    end;

    FileSearchDone(SearchRecord);
  end;

  if (ACount = 0) then
  begin
    ShowMessage(resNotFound);
  end;
end;

procedure TfrmMain.FileReplace();
var I: Integer; Msg, Extension, Sourcename, Destname: string;
    FullSourcename, FullDestname: string;
begin
  SourceFileName := edSourceFileName.Text;

  // obtener subcadena a reemplazar
  DestFileName := edDestFileName.Text;

  DestFileName :=
    umlcstrings.TrimPosfixCopy(DestFileName, '*');
  DestFileName :=
    umlcstrings.TrimPrefixCopy(DestFileName, '*');

  with chlbDestination, Items do
  begin
    for I := 0 to Pred(Count) do
    begin
      if (Checked[i]) then
      begin
        Sourcename := Items[i];
        // obtain file-extension without file-name
        Extension  := SysUtils.ExtractFileExt(Sourcename);
        // remove file-extension, obtain file-name
        Sourcename := SysUtils.ChangeFileExt(Sourcename, '');

        // replace the text in the sourcefilename,
        // indicated by "SourceFilename"
        // to "DestFilename"
        Destname   :=
          umlcstrings.ReplaceCopy(Sourcename, SourceFilename, DestFilename);
        // obtain destination name
        // obtener nombre destino

        Sourcename := SysUtils.ChangeFileExt(Sourcename, Extension);
        Destname   := SysUtils.ChangeFileExt(Destname, Extension);
        // add extension, again
        // agregar extension, de nuevo

        // add full path
        FullSourcename := FilePath + DirectorySeparator + Sourcename;
        FullDestname   := FilePath + DirectorySeparator + Destname;

        if (not FileFound(FullDestname)) then
        begin
          Msg := Format(resConfirmReplacement, [Sourcename, Destname]);
          if (MessageDlg(Msg, mtConfirmation, [mbYes, mbNo]) = mbYes) then
          begin
            FileRename(FullSourcename, FullDestname);
            // rename filename in filesystem
            // renombrar nombrearchivo en sistemaarchivos

            if (chbConfirmReplacement.Checked) then
            begin
              ShowMessage(#39 + Sourcename + #39 + resReplaced);
            end;
          end;
        end else ErrorDlg(resFileAlreadyExists);
        // perform filename replacement
        // realizar reemplazo de nombrearchivo
      end;
    end;
  end;
end;

procedure TfrmMain.btnFileSearchClick(Sender: TObject);
begin
  FileSearch();
end;

procedure TfrmMain.btnFileReplaceClick(Sender: TObject);
begin
  FileReplace();
  FileSearch();
end;

procedure TfrmMain.deedFilePathChange(Sender: TObject);
begin
  FilePath := deedFilePath.Text;
end;

procedure TfrmMain.btnAboutClick(Sender: TObject);
begin
  ufrmAbout.Execute();
end;

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  Self.Close();
end;

procedure TfrmMain.btnOptionsClick(Sender: TObject);
begin
//
end;

procedure TfrmMain.btnSelectALLClick(Sender: TObject);
var I: Integer;
begin
  with chlbDestination, Items do
  begin
    for I := 0 to Pred(Count) do
    begin
      Checked[i] := TRUE;
    end;
  end;
end;

procedure TfrmMain.btnSelectNoneClick(Sender: TObject);
var I: Integer;
begin
  with chlbDestination, Items do
  begin
    for I := 0 to Pred(Count) do
    begin
      Checked[i] := FALSE;
    end;
  end;
end;

end.
