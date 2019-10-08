unit chskin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmChooseSkin = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    lbSkins: TListBox;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure lbSkinsDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmChooseSkin: TfrmChooseSkin;
  oldstr : string;

procedure ShowCS(var skindir : string);

implementation
uses main;

{$R *.DFM}
procedure ShowCS(var skindir : string);
begin
  oldstr := skindir;
  with TfrmChooseSkin.Create(Application) do
  try
    //edskin.Text := skindir;
    if ShowModal = mrOK then
    begin
         skindir := lbSkins.Items[lbSkins.ItemIndex];
    end;
  finally
    Free;
  end;
end;

procedure TfrmChooseSkin.FormCreate(Sender: TObject);
var
    Finished : integer;
    Found: TSearchRec;
    dir : string;
    i : integer;
begin
  dir := extractFilePath(Application.EXEName) + SKINDIR + '\';
  Finished := FindFirst(dir  + '*.*', faDirectory, Found);
  while (Finished = 0)  do
  begin
  	//Check if the name is valid.
  	if (Found.Name[1] <> '.') then
        begin
             //Check if file is a directory
            lbSkins.Items.Add(Found.Name)  //Add to the directories list.
        end;
        Finished := FindNext(Found);
  end;
  lbskins.ItemIndex := 0;
  for i := 0 to lbskins.Items.Count -1 do
  begin
       if lbskins.items[i] = oldstr then
       begin
         lbskins.ItemIndex := i;
         break;
       end;
  end;
end;

procedure TfrmChooseSkin.lbSkinsDblClick(Sender: TObject);
begin
     ModalResult := mrOK;
end;

end.
