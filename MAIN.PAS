// FIXED bugs: X plane movement at the edges!!!!
unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FastIMG, FastBMP, FastDraw, FastRGB, ExtCtrls,FastFX, StdCtrls, Menus,abox,
  scores,chskin,inifiles;




type TPlayMatrix = array of array of byte;
     TBlock = array[0..3] of array[0..3] of byte;
     TGameState = (gsPaused, gsPlaying, gsCreatingBlock);
     TBlockType = integer;
     TTetrisGame = record
       Xpos : integer;
       Ypos : integer;
       GameState : TGameState;
       Block : TBlock;
       BlockType : TBlockType;
       PlayMatrix : TPlayMatrix;
       BlockBitmap : TFastBMP;
       rotateindex : Integer;
       NumRotations : integer;
       CurrLevel : integer;
       LinesRemoved : integer;
   end;

type
  TfrmTetris = class(TForm)
    GameClock: TTimer;
    panelScore: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    panelPlayArea: TPanel;
    PlayArea: TFastIMG;
    MainMenu: TMainMenu;
    mnuGame: TMenuItem;
    mnuExit: TMenuItem;
    mnuNewGame: TMenuItem;
    mnuOptions: TMenuItem;
    mnuSFX: TMenuItem;
    N1: TMenuItem;
    mnuPause: TMenuItem;
    mnuHelp: TMenuItem;
    mnuAbout: TMenuItem;
    mnuScores: TMenuItem;
    pnNB: TPanel;
    NB: TFastIMG;
    mnuNB: TMenuItem;
    Label3: TLabel;
    mnuCS: TMenuItem;
    BackIMG: TImage;
    Label4: TLabel;
    Skill1: TMenuItem;
    mnuStartingLevels: TMenuItem;
    mnuStartingRows: TMenuItem;
    N01: TMenuItem;
    N11: TMenuItem;
    N21: TMenuItem;
    N31: TMenuItem;
    N41: TMenuItem;
    N51: TMenuItem;
    N61: TMenuItem;
    N71: TMenuItem;
    N81: TMenuItem;
    N91: TMenuItem;
    panelscr1: TPanel;
    lblSCR: TLabel;
    panelscr2: TPanel;
    lbllevel: TLabel;
    panelscr3: TPanel;
    lbllines: TLabel;
    procedure GameClockTimer(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mnuNewGameClick(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure mnuSFXClick(Sender: TObject);
    procedure mnuPauseClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure mnuScoresClick(Sender: TObject);
    procedure mnuNBClick(Sender: TObject);
    procedure mnuCSClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N01Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure CenterPlayArea();
  private
    { Private declarations }
    procedure RandomOutro;
  public
    { Public declarations }
    procedure NewGame;
    procedure HMatrixShift(iy: integer);
    procedure AdvanceGame;
    procedure RemoveBlocks;
    procedure RemoveLine(iy: integer);
    procedure PutBlock(ix,iy: integer);
    procedure RemoveBlock(ix,iy: integer);
    procedure DrawMatrix;
    procedure  ChooseBlockBitmap(BlockType : TBlockType; var Bitmap : TFastBmp);
    function CheckPutY(BLK : TBlock; ix, iy : integer) : boolean;
    function GetNumRotations(BlockType : TBlockType): integer;
    function initBlock(BlockType: TBlockType): TBlock;
    function GetNextRotation(BlockType :TBlockType; Rotateindex: integer): TBlock;
    procedure NeutralizeBlock;
    procedure RotateBlock;
    procedure DropDown;
    procedure DrawBlock(dst: TFastRGB; ix, iy : integer; Bitmap : TFastBMP);
    procedure DrawNextBlock;

    procedure InitBlockBitmaps;
    procedure EndGame;
    procedure OnAppDeactivate(Sender : TObject);
  end;

var
  frmTetris: TfrmTetris;


const APPNAME = 'Tetris by Vedran Rodic';
      INIFILENAME = 'tetris.ini';

const

     // BLOCK DEFINITIONS
     //   field fill types

     ftBLANK = 0;
     ftMOVING = 1;

     ftIBLOCK = 2;
     ftBOXBLOCK = 3;
     ftL1BLOCK = 4;
     ftL2BLOCK = 5;
     ftCANONBLOCK = 6;
     ftSTH1BLOCK = 7;
     ftSTH2BLOCK = 8;


     //  explains itself
     NUMBLOCKS = 7;

//  block types and their rotated counterparts
var
     IBLOCKR0 : TBlock =
       ((1,1,1,1),
        (0,0,0,0),
        (0,0,0,0),
        (0,0,0,0));
     IBLOCKR1 : TBlock =
       ((0,0,1,0),
        (0,0,1,0),
        (0,0,1,0),
        (0,0,1,0));


     // BOX block

     BOXBLOCKR0 : TBlock =
       ((1,1,0,0),
        (1,1,0,0),
        (0,0,0,0),
        (0,0,0,0));

     // L1 block

     L1BLOCKR0 : TBlock =
       ((1,1,1,0),
        (0,0,1,0),
        (0,0,0,0),
        (0,0,0,0));

     L1BLOCKR1 : TBlock =
       ((1,1,0,0),
        (1,0,0,0),
        (1,0,0,0),
        (0,0,0,0));

     L1BLOCKR2 : TBlock =
       ((1,0,0,0),
        (1,1,1,0),
        (0,0,0,0),
        (0,0,0,0));

     L1BLOCKR3 : TBlock =
       ((0,0,1,0),
        (0,0,1,0),
        (0,1,1,0),
        (0,0,0,0));


     // L2 block

     L2BLOCKR0 : TBlock =
       ((1,1,1,0),
        (1,0,0,0),
        (0,0,0,0),
        (0,0,0,0));

     L2BLOCKR1 : TBlock =
       ((1,0,0,0),
        (1,0,0,0),
        (1,1,0,0),
        (0,0,0,0));

     L2BLOCKR2 : TBlock =
       ((0,0,1,0),
        (1,1,1,0),
        (0,0,0,0),
        (0,0,0,0));
     L2BLOCKR3 : TBlock =
       ((0,1,1,0),
        (0,0,1,0),
        (0,0,1,0),
        (0,0,0,0));


     // CANON block

     CANONBLOCKR0 : TBlock =
       ((1,1,1,0),
        (0,1,0,0),
        (0,0,0,0),
        (0,0,0,0));

     CANONBLOCKR1 : TBlock =
       ((0,1,0,0),
        (0,1,1,0),
        (0,1,0,0),
        (0,0,0,0));

     CANONBLOCKR2 : TBlock =
       ((0,1,0,0),
        (1,1,1,0),
        (0,0,0,0),
        (0,0,0,0));

     CANONBLOCKR3 : TBlock =
       ((0,1,0,0),
        (1,1,0,0),
        (0,1,0,0),
        (0,0,0,0));


     // something1 block
     STH1BLOCKR0 : TBlock =
       ((1,1,0,0),
        (0,1,1,0),
        (0,0,0,0),
        (0,0,0,0));

     STH1BLOCKR1 : TBlock =
       ((0,1,0,0),
        (1,1,0,0),
        (1,0,0,0),
        (0,0,0,0));

     // something2 block
     STH2BLOCKR0 : TBlock =
       ((0,1,1,0),
        (1,1,0,0),
        (0,0,0,0),
        (0,0,0,0));

     STH2BLOCKR1 : TBlock =
       ((1,0,0,0),
        (1,1,0,0),
        (0,1,0,0),
        (0,0,0,0));


var TetrisGame : TTetrisGame;
    CANTOUCH : Boolean;
    Score : LONGWORD; // a quickie!
    SQUAREWIDTH :integer =27;
    SQUAREHEIGHT  : integer = 22;
    FIELDWIDTH : integer= 10;
    FIELDHEIGHT : integer= 20;
    NextBlock : TBlockType;
    Delayer : byte; // used to delay after block has soft landed
                    // enables player to move the rock some time after
procedure DrawToFBMP(Bmp, dst:TFastRGB;ix, iy : integer);
// bitmap data constants and vars
const
     SKINDIR = 'DATA';
var
    ibmp : TFastBMP;
    boxbmp: TFastBMP;
    l1bmp: TFastBMP;
    l2bmp:TFastBMP;
    canonbmp : TFastBmp;
    sth1bmp : TFastBMP;
    sth2bmp : TFastBMP;
    currskin : string;


    //background bitmap
    backbmp : TFastBMP;
    DELAYNUM : word = 1;
    STARTYNUM: integer =0;
    STARTINGROWS: integer;

procedure Delay(time : longword);
function GetNextBlock(): TBlockType;
implementation

{$R *.DFM}

function GetNextBlock(): TBlockType;
begin
Result := Random(NUMBLOCKS)+2;
end;

procedure TfrmTetris.NewGame;
var x, y : integer;
    rnd : integer;
    RNDOK : boolean;
begin
Randomize;
with TetrisGame do
begin
Caption := APPNAME;
SetLength(PlayMatrix, FIELDHEIGHT,FIELDWIDTH);
for y := 0 to FIELDHEIGHT -1 do
begin
     for x := 0 to FIELDWIDTH -1 do
     begin
          PlayMatrix[y,x] := ftBLANK;
     end;
end;
LinesRemoved := 0;
CurrLevel := 1;
GameState := gsCreatingBlock;
PlayArea.CreateNew(SQUAREWIDTH * FIELDWIDTH, SQUAREHEIGHT * FIELDHEIGHT, PFASTBMP);
NB.CreateNew(SQUAREWIDTH * 4, SQUAREHEIGHT * 5, PFASTBMP);
PlayArea.Draw;
Delayer := 0;

CanTouch := False;
GameClock.Enabled := True; // start!;

Score := 0;

lblLevel.Caption := IntToStr(GameClock.Interval);
NextBlock := GetNextBlock;
pnNB.Visible := mnuNB.Checked;
end;

centerPlayArea;

if STARTINGROWS <> 0 then
begin
RNDOK := False;
for y := FIELDHEIGHT -1 downto (FIELDHEIGHT )-STARTINGROWS do
begin
     for x := 0 to FIELDWIDTH -1 do
     begin
          rnd :=Random(NUMBLOCKS+2);
          if rnd > NUMBLOCKS then rnd := RANDOM(NUMBLOCKS div 2);
          if rnd = ftMoving then rnd := ftBlank;
          if rnd = ftBlank then RNDOK := True;
          TetrisGame.PlayMatrix[y,x] := rnd;
     end;
     // this I do to make sure that no line is totaly full
     if not RNDOK then
     begin
        TetrisGame.PlayMatrix[y,FIELDWIDTH-1] := ftBlank;
     end;
     RNDOK := False;
end;
DrawMatrix;
end;

end;

procedure TfrmTetris.GameClockTimer(Sender: TObject);
begin
AdvanceGame;
end;

procedure TfrmTetris.btnNewClick(Sender: TObject);
begin
NewGame;
end;

procedure TfrmTetris.AdvanceGame;
begin
with TetrisGame do
begin
     lblSCR.Caption := IntToStr(Score);
     lblLines.Caption := IntToStr(LinesRemoved);
     case GameState of
     gsPlaying:
     begin

     if CheckPUTY(Block, XPOS,YPOS+1) then
     begin
           RemoveBlock(XPOS,YPOS);
           INC(YPOS);
           PutBlock(XPOS,YPOS);
     end
     else
     begin
     if Delayer = DELAYNUM then
     begin
          Inc(SCORE,YPOS);
          NeutralizeBlock;
          GameState := gsCreatingBlock;
          CANTOUCH := False;
          RemoveBlocks;
          DrawMatrix;
          Delayer := 0;
     end
     else inc(Delayer);
     end;
     IF YPOS = STARTYNUM then
     begin
          EndGame;
          //exit;
     end;
     end;
     gsCreatingBlock:
     begin
          CanTouch := True;
          XPOS := (FIELDWIDTH div 2) - 2;
          YPOS := STARTYNUM;
          RotateIndex := 0;
          BlockType := NextBlock;
          NextBlock := GetNextBlock;
          NumRotations := GetNumRotations (blocktype);
          Block := initBlock(BlockType);

          ChooseBlockBitmap(BlockType, BlockBitmap);
          GameState := gsPlaying;
          if not CheckPutY(Block,XPOS,YPOS) then
          begin
               EndGame;
               Exit;
          end;
          PutBlock(XPOS,YPOS);
          if mnuNB.Checked then DrawNextBlock;
     end;
     end;
     PlayArea.Draw;
     //Caption := IntToStr(XPOS); // DEBUG
end;
end;



procedure TfrmTetris.HMatrixShift(iy: integer);
var TMP : TPlayMatrix;
    x,y : integer;
begin
SetLength(TMP, FIELDHEIGHT,FIELDWIDTH);
for x:= 0 to FIELDWIDTH -1 do
    TMP[0,x] := ftBLANK;
for y := iy to FIELDHEIGHT -1 do
begin
     for x := 0 to FIELDWIDTH -1 do
     begin
          TMP[y,x] := TetrisGame.PlayMatrix[y,x]
     end;
end;
for y := 0 to iy-1 do
begin
     for x := 0 to FIELDWIDTH -1 do
     begin
          TMP[y+1,x] := TetrisGame.PlayMatrix[y,x]
     end;
end;
TetrisGame.PlayMatrix := TMP;
end;

procedure TfrmTetris.PutBlock(ix,iy: integer);
var x,y : integer;
begin
with TetrisGame do
begin
     for y := 0 to 3 do
      for x := 0 to 3 do
      begin
           if Block[y,x] = ftMoving then
           begin
               PlayMatrix [iy+y,ix+x] := ftMoving;
               DrawBlock(PlayArea.Bmp,ix+x,iy+y,BlockBitmap);
           end;
      end;

end;
end;

procedure TfrmTetris.RemoveBlock(ix,iy: integer);
var x,y : integer;
begin
with TetrisGame do
begin
     for y := 0 to 3 do
      for x := 0 to 3 do
      begin
           if Block[y,x] = ftMOVING then
           begin
                PlayMatrix [iy+y,ix+x] := ftBLANK;
                FillRect(PlayArea.Bmp,(ix+x)*SQUAREWIDTH,(iy+y)*SQUAREHEIGHT,SQUAREWIDTH,SQUAREHEIGHT, FRGB(0,0,0));
           end;
      end;
end;
end;

procedure TfrmTetris.ChooseBlockBitmap(BlockType : TBlockType;Var Bitmap :TFastBMP);
begin
     case BlockType of
          ftIBLOCK: Bitmap := ibmp;
          ftBOXBLOCK: Bitmap := boxbmp;
          ftCANONBLOCK: Bitmap := canonbmp;
          ftL2BLOCK: Bitmap := l2bmp;
          ftL1BLOCK: Bitmap := l1bmp;
          ftSTH1BLOCK : Bitmap := sth1bmp;
          ftSTH2BLOCK : Bitmap := sth2bmp;
     end;
end;

procedure TfrmTetris.RemoveBlocks;
var LINEFULL : boolean;
    x,y : integer;
begin
          for y := FIELDHEIGHT -1 downto 0 do
          begin
            LINEFULL := True;
            for x := 0 to FIELDWIDTH -1 do
            begin
              if TetrisGame.PlayMatrix[y,x] = ftBLANK then
              begin
                LINEFULL := false;
                break;
              end;
            end;
            
            if LINEFULL then
            begin
              Inc(Score,100);
              RemoveLine(y);
              RemoveBlocks;
            end;
          end;
end;

procedure TfrmTetris.RemoveLine(iy: integer);
var i : integer;
begin
inc(TetrisGame.LinesRemoved);
for i := 0 to FIELDWIDTH -1 do
begin
     TetrisGame.PlayMatrix[iy,i] := ftBLANK;
end;
HMatrixShift(iy);

if mnuSFX.checked then
begin
     DrawMatrix;
     PlayArea.Draw;
     Delay(100);
end;
end;

procedure TfrmTetris.DrawMatrix;
var x, y : integer;
var tmpbmp : TFastBMP;
begin
     for y := 0 to FIELDHEIGHT -1 do
     begin
          for x := 0 to FIELDWIDTH -1 do
          begin
               if TetrisGame.PlayMatrix[y,x] = ftBLANK then
                  FillRect(PlayArea.Bmp, x*SQUAREWIDTH, y* SQUAREHEIGHT,SQUAREWIDTH, SQUAREHEIGHT, FRGB(0,0,0))
               else if TetrisGame.PlayMatrix[y,x] = ftMOVING then
               begin
                 DrawBlock(PlayArea.Bmp,x,y,TetrisGame.BlockBitmap);
               end
               else
               begin
                    ChooseBlockBitmap(TetrisGame.PlayMatrix[y,x],tmpbmp);
                    DrawBlock(PlayArea.BMP,x,y,tmpbmp);
               end;

          end;
     end;
end;

function TfrmTetris.CheckPutY(BLK : TBlock; ix, iy : integer) : boolean;
var x,y : integer;
begin
     Result := True;
with TetrisGame do
begin
     for y := 0 to 3 do
     begin
      for x := 0 to 3 do
      begin
           if BLK[y,x] = ftMoving then
           begin
                 if (iy+y) > FIELDHEIGHT -1 then
                 begin
                      Result := False;
                      exit;
                 end;
                 {if (iy+y) < 0 then
                 begin
                      Result := False;
                      exit;
                 end;}
                 if (ix+x) > FIELDWIDTH -1 then
                 begin
                      Result := False;
                      exit;
                 end;
                 if (ix+x) < 0 then
                 begin
                      Result := False;
                      exit;
                 end;
                 if (PlayMatrix [iy+y,ix+x] > ftMoving) then
                 begin
                      Result := False;
                      exit;
                 end
                 else
                 begin
                      Result := True;
                 end;
           end;
      end;
     end;

end;
end;

function TfrmTetris.GetNumRotations(BlockType : TBlockType): integer;
begin
     case BlockType of
          ftIBLOCK: Result := 1;
          ftBOXBLOCK: Result := 0;
          ftCANONBLOCK: Result := 3;
          ftL2BLOCK: Result := 3;
          ftL1BLOCK: Result := 3;
          ftSTH1BLOCK : Result := 1;
          ftSTH2BLOCK : Result := 1;
     end;
end;

function TfrmTetris.initBlock(BlockType: TBlockType): TBlock;
begin
  case BlockType of
      ftIBlock:     Result := IBLOCKR0;
      ftBoxBlock:   Result := BOXBLOCKR0;
      ftL1Block:    Result := L1BLOCKR0;
      ftL2Block:    Result := L2BLOCKR0;
      ftCanonBlock: Result := CANONBLOCKR0;
      ftSTH1Block:  Result := STH1BLOCKR0;
      ftSTH2Block:  Result := STH2BLOCKR0;
  end;
end;



procedure TfrmTetris.FormCreate(Sender: TObject);
var IniFile : TIniFile;
    i : Integer;
begin
Application.OnDeactivate :=OnAppDeactivate;
BackIMG.Width := ClientRect.Right - ClientRect.Left;
BackIMG.Height := ClientRect.Bottom - ClientRect.Top;
iniFile := TIniFile.Create(extractFilePath(Application.EXEName) + INIFILENAME);
currskin := inifile.ReadString('Data','DataDirName','classic');
mnuNB.Checked := inifile.ReadBool('Options','PreviewBlock',false);
mnuSFX.Checked := inifile.ReadBool('Options','SFX',true);
STARTINGROWS := inifile.ReadInteger('Options','StartingRows',0);
GameClock.Interval := inifile.ReadInteger('Options','TimeDelay',140);
inifile.Free;

for i := 0 to mnuStartingRows.Count - 1 do
begin
  if mnuStartingRows[i].Tag = STARTINGROWS then
  begin
    mnuStartingRows[i].Checked := true;
    break;
  end;
end;

TetrisGame.CurrLevel := 1;
InitBlockBitmaps;
NewGame;

Caption := APPNAME;
end;

procedure TfrmTetris.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//Caption := IntTostr(key); // DEBUG
if mnuPause.Checked then Exit;
if not CANTOUCH then Exit; // VR2023 not sure if needed
with TetrisGame do
begin
     case key of
      39: // RIGHT
      begin
      IF CheckPutY(Block, XPOS+1,YPOS) then
      begin
           RemoveBlock(XPOS,YPOS);
           INC(XPOS);
           PutBlock(XPOS,YPOS);
           PlayArea.Draw;
      end;
      end;
      37: // LEFT
      begin
      IF CheckPutY(Block, XPOS-1,YPOS) then
      begin
           RemoveBlock(XPOS,YPOS);
           DEC(XPOS);
           PutBlock(XPOS,YPOS);
           PlayArea.Draw;
      end;
      end;
      //113: NewGame;
      38,12: // UP
      begin
           RemoveBlock(XPOS,YPOS);
           RotateBlock;
           PutBlock(XPOS,YPOS);
           PlayArea.Draw;
      end;
      116:// F5
      begin
           GameClock.Interval := GameClock.interval -10;
           lblLevel.Caption := IntToStr(GameClock.Interval);
      end;
      117:// F6
      begin
           GameClock.Interval := GameClock.interval +10;
           lblLevel.Caption := IntToStr(GameClock.Interval);           
      end;
      32: // SPACE
      begin
      IF CheckPutY(Block, XPOS,YPOS+1) then
      begin
           RemoveBlock(XPOS,YPOS);
           INC(YPOS);
           PutBlock(XPOS,YPOS);
           PlayArea.Draw;
      end;
      end;
      40: // DOWN
      begin
           DropDown;
      end;
     end;
end;

end;

procedure TfrmTetris.NeutralizeBlock;
var x,y : integer;
begin
with TetrisGame do
begin
     for y := 0 to 3 do
      for x := 0 to 3 do
      begin
           if Block[y,x] = ftMoving then
           begin
               PlayMatrix [ypos+y,xpos+x] := Blocktype;
           end;
      end;

end;
end;

function TfrmTetris.GetNextRotation(BlockType :TBlockType; Rotateindex: integer): TBlock;
begin
case BlockType of
          ftBOXBLOCK: Result := BOXBLOCKR0;
          ftIBLOCK:
          begin
               case Rotateindex of
               0: Result := IBLOCKR0;
               1: Result := IBLOCKR1;
               end;
          end;
          ftCANONBLOCK:
          begin
               case Rotateindex of
               0: Result := CANONBLOCKR0;
               1: Result := CANONBLOCKR1;
               2: Result := CANONBLOCKR2;
               3: Result := CANONBLOCKR3;

               end;
          end;
          ftL2BLOCK:
          begin
               case Rotateindex of
               0: Result := L2BLOCKR0;
               1: Result := L2BLOCKR1;
               2: Result := L2BLOCKR2;
               3: Result := L2BLOCKR3;
               end;
          end;
          ftL1BLOCK:
          begin
               case Rotateindex of
               0: Result := L1BLOCKR0;
               1: Result := L1BLOCKR1;
               2: Result := L1BLOCKR2;
               3: Result := L1BLOCKR3;
               end;
          end;
          ftSTH1BLOCK :
          begin
               case Rotateindex of
               0: Result := STH1BLOCKR0;
               1: Result := STH1BLOCKR1;

               end;
          end;

          ftSTH2BLOCK :
          begin
               case Rotateindex of
               0: Result := STH2BLOCKR0;
               1: Result := STH2BLOCKR1;

               end;
          end;
     end;
end;

procedure TfrmTetris.RotateBlock;
var TMP : TBlock;
    ri : integer;
begin
with TetrisGame do
begin
   ri := rotateindex;
   if NumRotations > RotateIndex then
       inc(rotateindex)
    else RotateIndex := 0;
    
   TMP := GetNextRotation(BlockType, RotateIndex);
   
   if not CheckPutY(TMP,XPOS,YPOS) then
   begin
        if (BlockType = ftL2Block) and (XPOS = FIELDWIDTH -2) and (RotateIndex = 2) then
        begin
           RemoveBlock(XPOS,YPOS);
           if CheckPutY(TMP,XPOS-1,YPOS) then
           begin
              dec(xpos);
              //PutBlock(XPOS,YPOS);
           end
           else
           begin
            PutBlock(XPOS,YPOS);
            rotateindex := ri;
            exit;
           end;
        end
        else
        begin
             rotateindex := ri;
             exit;
        end;
   end;

   Block := GetNextRotation(BlockType, RotateIndex);
end;
end;

procedure TfrmTetris.DropDown;
var CANDOIT : boolean;
    SCRTMP : integer;
begin

with TetrisGame do
begin
SCRTMP := YPOS*5;
CANDOIT := true;
while CANDOIT do
begin
     CANDOIT := CheckPUTY(Block, XPOS,YPOS+1);
     if CANDOIT then
     begin
           RemoveBlock(XPOS,YPOS);
           INC(YPOS);
           PutBlock(XPOS,YPOS);
     end
     else
     begin
          NeutralizeBlock;
          GameState := gsCreatingBlock;
          CANTOUCH := False;
          RemoveBlocks;
          DrawMatrix;
     end;
     IF YPOS = STARTYNUM then
     begin
          EndGame;
     end;
end;
Inc(score,SCRTMP+YPOS);
end;


PlayArea.Draw;
lblSCR.Caption := IntToStr(Score);
end;

procedure TfrmTetris.mnuNewGameClick(Sender: TObject);
begin
mnuPause.Checked := False;
NewGame;
end;

procedure TfrmTetris.mnuExitClick(Sender: TObject);
begin
Close;
end;

procedure TfrmTetris.mnuSFXClick(Sender: TObject);
begin
mnuSFX.Checked := not mnuSFX.Checked;
end;

procedure TfrmTetris.mnuPauseClick(Sender: TObject);
begin
GameClock.Enabled := not GameClock.Enabled;
mnuPause.Checked := not GameClock.Enabled;
if mnuPause.Checked then Caption := APPNAME + ' (Paused)' else
   Caption := APPNAME;
end;


procedure TfrmTetris.DrawBlock(dst: TFastRGB; ix, iy : integer; Bitmap : TFastBMP);

begin
 DrawTOFbmp(Bitmap,dst,ix*SQUAREWIDTH,iy*SQUAREHEIGHT);
end;

procedure TfrmTetris.mnuAboutClick(Sender: TObject);
begin
if GameClock.Enabled then mnuPauseClick(self);
ABox.ShowAboutBox;
end;

procedure DrawToFBMP(Bmp, dst:TFastRGB;ix, iy : integer);
var x,y: Integer;
begin
  for y:=0 to SQUAREHEIGHT-1 do
  begin
    for x:=0 to SQUAREWIDTH-1 do
    begin
      Dst.Pixels[iy+y,ix+x]:=Bmp.Pixels[y,x];
    end;
  end;
end;



procedure TfrmTetris.mnuScoresClick(Sender: TObject);
begin
if GameClock.Enabled then mnuPauseClick(self);
ShowScores(0);
end;

procedure TfrmTetris.DrawNextBlock;
var x,y : integer;
    Blocky : TBlock;
    tmpbmp : TFastBMP;
begin
FillRect(NB.Bmp,0,0,SQUAREWIDTH *4, SQUAREHEIGHT *4, FRGB(0,0,0));
Blocky := initBlock(NextBlock);

ChooseBLockBitmap(nextblock,tmpbmp);
for y := 0 to 3 do
  for x := 0 to 3 do
    if Blocky[y,x] = ftMoving then
      DrawBlock(NB.Bmp,x,y,tmpbmp);
NB.Draw;
end;

procedure TfrmTetris.mnuNBClick(Sender: TObject);
begin
mnuNB.Checked := not mnuNB.Checked;
pnNB.Visible := mnuNB.Checked;
end;

procedure TfrmTetris.InitBlockBitmaps;
var path : string;
begin
    path := extractFilePath(Application.EXEName) + SKINDIR + '\' + currskin + '\';
    ibmp := TFastBMP.CreateFromFile(path+'i.bmp');
    boxbmp:= TFastBMP.CreateFromFile(path+'box.bmp');
    l1bmp:= TFastBMP.CreateFromFile(path+'l1.bmp');
    l2bmp:=TFastBMP.CreateFromFile(path+'l2.bmp');
    canonbmp := TFastBMP.CreateFromFile(path+'canon.bmp');
    sth1bmp := TFastBMP.CreateFromFile(path+'sth1.bmp');
    sth2bmp := TFastBMP.CreateFromFile(path+'sth2.bmp');

    Backbmp:= TFastBMP.CreateFromFile(path+'wall' + IntToStr(TetrisGame.CurrLevel)+'.bmp');
    backbmp.TileDraw(BackIMG.Canvas.Handle,0,0, ClientRect.Right - ClientRect.Left,ClientRect.Bottom - ClientRect.Top);
    BackIMG.Refresh;
end;

procedure TfrmTetris.mnuCSClick(Sender: TObject);
begin
if GameClock.Enabled then mnuPauseClick(self);
ShowCS(currskin);
InitBlockBitmaps;
end;

procedure TfrmTetris.FormClose(Sender: TObject; var Action: TCloseAction);
var inifile : TIniFile;
begin
inifile := Tinifile.Create(extractFilePath(Application.EXEName)+INIFILENAME);
inifile.WriteString('Data','DataDirName',currskin);
inifile.WriteBool('Options','PreviewBlock',mnuNB.Checked);
inifile.WriteBool('Options','SFX',mnuSFX.Checked);
inifile.WriteInteger('Options','TimeDelay',GameClock.Interval);
inifile.WriteInteger('Options','StartingRows',STARTINGROWS);
inifile.Free;
end;

procedure Delay(time : longword);
var tmp : longword;
begin
     tmp := GetTickcount;
     while  GetTickCount <= tmp +time do
     begin
          //Application.ProcessMessages;
     end;
end;

procedure TfrmTetris.EndGame;
begin
  GameClock.Enabled := False;
  if mnuSFX.checked then
    RandomOutro;

  ShowScores(Score);
  NewGame;
end;

procedure TfrmTetris.RandomOutro;
var i: integer;
var outro: integer;
begin
outro := Random(6);
//outro := 4;
//Caption := IntToStr(outro);
  for i:= 0 to 60 do
             begin
               delay(10);
               case outro of
                0: GaussianBlur(PlayArea.Bmp,2);
                1: HShift(PlayArea.Bmp,1);
                2: AddMonoNoise(PlayArea.Bmp,150);
                3: Mosaic(PlayArea.Bmp,i,i);
                4: Twist(PlayArea.Bmp,PlayArea.Bmp,300+i); // TODO work on orig copy
                5: Lightness(PlayArea.Bmp,-25);
               end;
               PlayArea.Draw;
             end;
end;

procedure TfrmTetris.OnAppDeactivate(Sender : TObject);
begin
if GameClock.Enabled then mnuPauseClick(self);
end;

procedure TfrmTetris.N01Click(Sender: TObject);
begin
STARTINGROWS := TMenuItem(Sender).Tag;
TMenuItem(Sender).Checked := True;
end;


procedure TfrmTetris.FormResize(Sender: TObject);
begin
centerPlayArea;
end;

procedure TfrmTetris.CenterPlayArea();
begin
panelPlayArea.Top := ((ClientRect.Bottom-ClientRect.Top) div 2) - (PlayArea.Height div 2);
panelPlayArea.left := ((ClientRect.Right-ClientRect.Left) div 2) - (PlayArea.Width div 2);
end;

end.
