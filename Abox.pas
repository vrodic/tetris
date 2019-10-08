unit abox;

interface

uses Windows,StdCtrls,Forms,Controls,ExtCtrls,
Classes,SysUtils;

type
  TAboutBox = class(TForm)
    ProgramIcon: TImage;
    ProgramName: TLabel;
    VersionCAP: TLabel;
    Copyright: TLabel;
    Comments: TLabel;
    OkBtn: TButton;
    RightsCAP: TLabel;
    okvir: TBevel;
    panel: TPanel;
    VrzCAP: TLabel;
    InfoCAP: TLabel;
    EMAILED: TEdit;
    EMAILCAP: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

procedure ShowAboutBox;

implementation

{$R *.DFM}

uses main;

procedure ShowAboutBox;
begin
  with TAboutBox.Create(Application) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

function GetFileBuildNo : integer;
var
  FVersionInfo: PChar;
  FVersionInfoSize: DWORD;

  QueryLen: UINT;
  Dummy: DWORD;
  FixedInfoData: PVSFixedFileInfo;
  TempFilename: array[0..255] of char;

begin
  StrPCopy(TempFileName, Application.ExeName);
  FVersionInfoSize := GetFileVersionInfoSize(TempFileName, Dummy);
  if FVersionInfoSize = 0 then
  begin
    Result := 0;
    exit;
  end else begin
    GetMem(FVersionInfo, FVersionInfoSize);
    GetFileVersionInfo(TempFileName, Dummy, FVersionInfoSize, FVersionInfo);

    VerQueryValue(FVersionInfo, '\', pointer(FixedInfoData), QueryLen);
    Result := LoWord(FixedInfoData^.dwFileVersionLS);
  end;
end;

procedure TAboutBox.FormCreate(Sender: TObject);
begin
 Caption := Format('About %s', [APPNAME]);
 ProgramIcon.Picture.Assign(Application.Icon);
 ProgramName.Caption := APPNAME;
 VersionCAP.Caption := 'Build ' + inttostr(GetFileBuildNo);
end;

procedure TAboutBox.FormShow(Sender: TObject);
begin
ActiveControl := OkBtn;
end;


end.

