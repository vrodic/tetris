unit scores;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type TScore = record
     Score: longword;
     Name : string;
     Comment: string;
end;


type
  TfrmScores = class(TForm)
    btnClose: TButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    stScore: TStaticText;
    stName: TStaticText;
    stComment: TStaticText;
    edName: TEdit;
    edComment: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edNameKeyPress(Sender: TObject; var Key: Char);
    procedure edCommentKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure CommentWriteLN(str : string);
    procedure NameWriteLN(str : string);
    procedure ScoreWriteLN(str : string);
    procedure PrintList;
  end;

const LISTHEIGHT = 18;
type
    TScoresList = array[0..LISTHEIGHT -1] of TScore;
var
  frmScores: TfrmScores;
  ScoresList : TScoresList;
  scr : longword;
  pos : integer;
procedure ShowScores(MyScore : longword);
implementation

uses main;

procedure ShowScores(MyScore : longword);
begin
  scr := MyScore;
  with TfrmScores.Create(Application) do
  try
    ShowModal;
  finally
    Free;
  end;
end;


{$R *.DFM}
const FSTR = 'scores.tbl';

procedure TfrmScores.FormCreate(Sender: TObject);
var f: TFileStream;
    i,j : integer;
    scrtmp : longword;
    tstr1 : array[0..255] of char;
    tstr2 : array[0..255] of char;
    tmp : TScoresList;
    tmpscore : TScore;
begin
if not FileExists(ExtractFilePath(Application.EXEName)+FSTR) then
begin
     for i := 0 to LISTHEIGHT-1 do
     begin
          ScoresList[i].Score := 5000 - (i * 100);
          ScoresList[i].Name :=  'Vedran Rodic';
          ScoresList[i].Comment := 'Play Tetris!';
     end;
end
else
begin
     f := TFileStream.Create(fstr, fmOpenRead);
     for i := 0 to LISTHEIGHT -1 do
     begin

          f.Read(scrtmp, sizeof(longword));
          f.Read(tstr1, 255);
          f.Read(tstr2, 255);
          ScoresList[i].Score := scrtmp;
          ScoresList[i].Name :=  tstr1;
          ScoresList[i].Comment := tstr2;
     end;
     f.free;
end;
for i := 0 to LISTHEIGHT -1 do
begin
     if scr > ScoresList[i].Score then
     begin
         tmpscore := Scoreslist[i];
         edname.Top :=  (i * edname.height)+32;
         edcomment.Top :=  (i * edcomment.height)+32;
         edName.Show;
         edname.Text := tmpscore.Name;
         edname.SelectAll;
         activecontrol := edname;
         pos := i;
         tmp[i].Score := scr;
         tmp[i+1] := tmpscore;
         for j := 0 to i-1 do
         begin
           tmp[j] := ScoresList[j];
         end;
         for j := i+1 to LISTHEIGHT-2 do
         begin
           tmp[j+1] := ScoresList[j];
         end;

         ScoresList:= tmp;
         break;
     end;
end;
//pos := -1;
PrintList;
if not edname.Visible then ActiveControl := btnClose;
end;

procedure TfrmScores.PrintList;
var i : integer;
begin
stScore.Caption := '';
stName.Caption := '';
stComment.Caption := '';
for i := 0 to LISTHEIGHT -1 do
begin
     ScoreWriteLn(inttostr(ScoresList[i].Score));
     NameWriteLn(ScoresList[i].Name);
     CommentWriteLn(ScoresList[i].Comment);
end;
end;


procedure TfrmScores.ScoreWriteLN(str : string);
begin
     stScore.Caption := stScore.Caption + str + #13;
end;

procedure TfrmScores.NameWriteLN(str : string);
begin
     stName.Caption := stName.Caption + str + #13;
end;
procedure TfrmScores.CommentWriteLN(str : string);
begin
     stComment.Caption := stComment.Caption + str + #13;
end;

procedure TfrmScores.FormClose(Sender: TObject; var Action: TCloseAction);
var i : integer;
    f : TFileStream;
    scrtmp : longword;
    tstr1 : array [0..255] of Char;
    tstr2 : array [0..255] of Char;

begin
     f := TFileStream.Create(fstr, fmCreate);
     for i := 0 to LISTHEIGHT -1 do
     begin
          scrtmp := ScoresList[i].Score;
          StrPCopy(tstr1, ScoresList[i].Name);
          StrPCopy(tstr2, ScoresList[i].Comment);

          f.Write(scrtmp, sizeof(longword));
          f.Write(tstr1, 255);
          f.Write(tstr2, 255);
     end;
     f.Free;
end;

procedure TfrmScores.edNameKeyPress(Sender: TObject; var Key: Char);
begin
if key = #13 then
begin
     ScoresList[pos].Name := edName.Text;
     edName.Hide;
     edComment.Show;
     activecontrol := edcomment;
     PrintList;
end;
end;

procedure TfrmScores.edCommentKeyPress(Sender: TObject; var Key: Char);
begin
if key = #13 then
begin
     ScoresList[pos].Comment := edComment.Text;
     edComment.Hide;
     PrintList;
     ActiveControl := btnClose;
end;
end;

{procedure qsort(var a : TScoresList);
    procedure sort(l,r: longint);
      var
         i,j,x,y: longint;
      begin
         i:=l;
         j:=r;
         x:=a[(l+r).Score div 2];
         repeat
           while a[i]<x do
            inc(i);
           while x<a[j] do
            dec(j);
           if not(i>j) then
             begin
                y:=a[i];
                a[i].Score:=a[j].Score;
                a[j].Score:=y;
                inc(i);
                j:=j-1;
             end;
         until i>j;
         if l<j then
           sort(l,j);
         if i<r then
           sort(i,r);
      end;

    begin
       sort(1,max);
    end;}


end.
