// FIXED bugs: X plane movement at the edges!!!!
unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FastIMG, FastBMP, FastDraw, FastRGB, ExtCtrls,FastFX, StdCtrls, Menus,abox,scores,chskin,inifiles,MMSystem,vdb;




type TPlayMatrix = array of array of byte;
     TBlock = array[0..3] of array[0..3] of byte;
     TGameState = (gsPaused, gsPlaying, gsCreatingBlock);
     TBlockType = integer;
     TTetrisGame = record
       Xpos : integer;
       Ypos : integer;
       GameState : TGameState;
       CenterX: integer;
       CenterY: integer;
       Block : TBlock;
       BlockWidth : integer;
       BlockHeight : integer;
       BlockType : TBlockType;
       PlayMatrix : TPlayMatrix;
       //BlockColor : TFColor;
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
    procedure N11Click(Sender: TObject);
    procedure N21Click(Sender: TObject);
    procedure N31Click(Sender: TObject);
    procedure N41Click(Sender: TObject);
    procedure N51Click(Sender: TObject);
    procedure N61Click(Sender: TObject);
    procedure N71Click(Sender: TObject);
    procedure N81Click(Sender: TObject);
    procedure N91Click(Sender: TObject);
  private
    { Private declarations }
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
    function  ReturnBlockColor(BlockType : TBlockType): TFColor;
    procedure  ChooseBlockBitmap(BlockType : TBlockType; var Bitmap : TFastBmp);
    function CheckPutY(BLK : TBlock; ix, iy : integer) : boolean;
   // function CheckPutX(BLK : TBlock; ix, iy : integer) : boolean;
    function GetNumRotations(BlockType : TBlockType): integer;
    procedure NeutralizeBlock;
    procedure RotateBlock;
    procedure DropDown;
    procedure DrawBlock(dst: TFastRGB; ix, iy : integer; Bitmap : TFastBMP);
    procedure DrawNextBlock;
    //function CheckYR(BLK : TBlock) : boolean;
    //function CheckYL(BLK : TBlock) : boolean;
    procedure InitBlockBitmaps;
    procedure PlayMeSound(WavFileName: String; MODE : Word);
    procedure EndGame;
    procedure OnAppDeactivate(Sender : TObject);
  end;

var
  frmTetris: TfrmTetris;


const APPNAME = 'Tetris by Vedran Rodic';
      INIFILENAME = 'tetris.ini';

const
//     SQUAREWIDTH = 18;
//     SQUAREHEIGHT = 18;
//     FIELDWIDTH = 15;
//     FIELDHEIGHT = 25;

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

     //  I letter block
     IBLOCKNR = 1;
     BOXBLOCKNR = 0;
     L1BLOCKNR = 3;
     L2BLOCKNR = 3;
     CANONBLOCKNR = 3;
     STH1BLOCKNR = 1;
     STH2BLOCKNR = 1;


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
    DoDraw : boolean;
    Score : LONGWORD; // a quickie!
    SFX : boolean = false;
    SQUAREWIDTH :integer =27;
    SQUAREHEIGHT  : integer = 22;
    FIELDWIDTH : integer= 10;
    FIELDHEIGHT : integer= 20;
    NextBlock : TBlockType;
    BLockPreview : boolean = false;
    Delayer : byte; // used to delay after rock has soft landed
                    // enables player to move the rock some time after
    NBBackColor : TFColor;
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
implementation

{$R *.DFM}

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
NB.CreateNew(SQUAREWIDTH * 4, SQUAREHEIGHT * 4, PFASTBMP);
PlayArea.Draw;
Delayer := 0;

//panelPlayArea.Width := (SQUAREWIDTH * FIELDWIDTH) +2;
//Bevel1.Height := (SQUAREHEIGHT * FIELDHEIGHT) +2;
CanTouch := False;
GameClock.Enabled := True; // start!;
dodraw := True;
Score := 0;
// options: should go to options dialog later
//SFX := True;
lblLevel.Caption := IntToStr(GameClock.Interval);
NextBlock := Random(NUMBLOCKS)+2;
pnNB.Visible := BlockPreview;
end;
// centering code
panelPlayArea.Top := ((ClientRect.Bottom-ClientRect.Top) div 2) - (PlayArea.Height div 2);
panelPlayArea.left := ((ClientRect.Right-ClientRect.Left) div 2) - (PlayArea.Width div 2);
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
var CANDOIT : boolean;
    //x,y: integer;
    //LINEFULL : boolean;
begin
with TetrisGame do
begin
     lblSCR.Caption := IntToStr(Score);
     lblLines.Caption := IntToStr(LinesRemoved);
     case GameState of
     gsPlaying:
     begin
     CANDOIT := true;
     {if YPOS = FIELDHEIGHT -(BlockHeight) then
     begin
          NeutralizeBlock;
          GameState := gsCreatingBlock;
          CANTOUCH := False;
          RemoveBlocks;
          PlayArea.Draw;
          Exit;
     end;}
     //if CANDOIT then
     //begin
     //for x := XPOS  to XPOS +(BlockWidth-1) do
     //begin
     //     if PlayMatrix[YPOS+CenterY+1, x] = STONED then
     //     begin
     //          CANDOIT := False;
     //          Break;
     //     end;
     //end;
     //end;
     if CANDOIT then CANDOIT := CheckPUTY(Block, XPOS,YPOS+1);

     if CANDOIT then
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
          if SFX then
          begin
               GaussianBlur(PlayArea.Bmp,1); // EFECT
          end;
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
          NextBlock := Random(NUMBLOCKS)+2;
          NumRotations := GetNumRotations (blocktype);
          case BlockType of
               ftIBlock:
               begin
                    CenterX := 2;
                    CenterY := 0;
                    BlockWidth := 4;
                    BlockHeight := 1;
                    Block := IBLOCKR0;
               end;
               ftBoxBlock:
               begin
                    CenterX := 0;
                    CenterY := 0;
                    BlockWidth := 2;
                    BlockHeight := 2;
                    Block := BOXBLOCKR0;
               end;
               ftL1Block:
               begin
                    CenterX := 0;
                    CenterY := 0;
                    BlockWidth := 3;
                    BlockHeight := 2;
                    Block := L1BLOCKR0;
               end;
               ftL2Block:
               begin
                    CenterX := 0;
                    CenterY := 0;
                    BlockWidth := 3;
                    BlockHeight := 2;
                    Block := L2BLOCKR0;
               end;
               ftCanonBlock:
               begin
                    CenterX := 1;
                    CenterY := 0;
                    BlockWidth := 3;
                    BlockHeight := 2;
                    Block := CANONBLOCKR0;
               end;
               ftSTH1Block:
               begin
                    CenterX := 0;
                    CenterY := 0;
                    BlockWidth := 3;
                    BlockHeight := 2;
                    Block := STH1BLOCKR0;
               end;
               ftSTH2Block:
               begin
                    CenterX := 0;
                    CenterY := 0;
                    BlockWidth := 3;
                    BlockHeight := 2;
                    Block := STH2BLOCKR0;
               end;

          end;
          //BlockColor := ReturnBlockColor(BlockType);
          ChooseBlockBitmap(BlockType, BlockBitmap); // not here yet
          GameState := gsPlaying;
          if not CheckPutY(Block,XPOS,YPOS) then
          begin
               EndGame;
               Exit;
          end;
          PutBlock(XPOS,YPOS);
          if BlockPreview then DrawNextBlock;
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
               //if DoDraw then FillRect(PlayArea.Bmp,(ix+x)*SQUAREWIDTH,(iy+y)*SQUAREHEIGHT,SQUAREWIDTH,SQUAREHEIGHT, BlockColor);
               DrawBlock(PlayArea.Bmp,(ix+x)*SQUAREWIDTH,(iy+y)*SQUAREHEIGHT,BlockBitmap); // IMPLEMENT
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



function TfrmTetris.ReturnBlockColor(BlockType : TBlockType) : TFColor;
begin
     case BlockType of
          ftIBLOCK: Result := FRGB(255,0,0);
          ftBOXBLOCK: Result := FRGB(0,191,191);
          ftCANONBLOCK: Result := FRGB(128,128,128);
          ftL2BLOCK: Result := FRGB(255,255,0);
          ftL1BLOCK: Result := FRGB(191,0,191);
          ftSTH1BLOCK : Result := FRGB(0,255,0);
          ftSTH2BLOCK : Result := FRGB(0,0,255);
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
//FillRect(PlayArea.Bmp,0,iy*SQUAREHEIGHT, (FIELDWIDTH*SQUAREWIDTH)-1,SQUAREHEIGHT,FRGB(0,0,0));
//GameClock.Enabled := False;
//PlayArea.Draw;              // debug shit
//ShowMessage('Fuck');
//GameClock.Enabled := True;
//HSplitShift(PlayArea.Bmp,SQUAREHEIGHT,iy*SQUAREHEIGHT);
if SFX then
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
                  //FillRect(PlayArea.Bmp, x*SQUAREWIDTH, y* SQUAREHEIGHT,SQUAREWIDTH, SQUAREHEIGHT, TetrisGame.BlockColor)
                  DrawBlock(PlayArea.Bmp,(x)*SQUAREWIDTH,(y)*SQUAREHEIGHT,TetrisGame.BlockBitmap)
               else
               begin
                    ChooseBlockBitmap(TetrisGame.PlayMatrix[y,x],tmpbmp);
                    DrawBlock(PlayArea.BMP,(x)*SQUAREWIDTH,(y)*SQUAREHEIGHT,tmpbmp);
                    //FillRect(PlayArea.Bmp, x*SQUAREWIDTH, y* SQUAREHEIGHT,SQUAREWIDTH, SQUAREHEIGHT, ReturnBlockColor(TetrisGame.PlayMatrix[y,x]));
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
                 if (PlayMatrix [iy+y,ix+x] > ftMoving) {and NOT (BLK[y+1,x] = STONED)}  then
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

{function TfrmTetris.CheckYR(BLK : TBlock) : boolean;
var x,y : integer;
begin
     Result := True;
with TetrisGame do
begin
     for x := 3 downto 0 do
     begin
      for y := 0 to 3 do
      begin
           if BLK[y,x] = ftMoving then
           begin
                Result := False;
                exit;
           end;
      end;
     end;
end;
end;

function TfrmTetris.CheckYL(BLK : TBlock) : boolean;
var x,y : integer;
begin
     Result := True;
with TetrisGame do
begin
     for x := 0 downto 3 do
     begin
      for y := 0 to 3 do
      begin
           if BLK[y,x] = ftMoving then
           begin
                Result := False;
                exit;
           end;
      end;
     end;
end;
end;}

{$IFDEF BLAH}
function TfrmTetris.CheckPutX(BLK : TBlock; ix, iy : integer) : boolean;
var x,y : integer;
begin
     Result := True;
with TetrisGame do
begin
     for x := 0 to 3 do
     begin
      for y := 0 to 3 do
      begin
           if BLK[y,x] = ftMoving then
           begin
                 if (PlayMatrix [iy+y,ix+x] > ftMoving) {and NOT (BLK[y+1,x] = STONED)}  then
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
{$ENDIF}

function TfrmTetris.GetNumRotations(BlockType : TBlockType): integer;
begin
     case BlockType of
          ftIBLOCK: Result := IBLOCKNR;
          ftBOXBLOCK: Result := BOXBLOCKNR;
          ftCANONBLOCK: Result := CANONBLOCKNR;
          ftL2BLOCK: Result := L2BLOCKNR;
          ftL1BLOCK: Result := L1BLOCKNR;
          ftSTH1BLOCK : Result := STH1BLOCKNR;
          ftSTH2BLOCK : Result := STH2BLOCKNR;
     end;
end;



procedure TfrmTetris.FormCreate(Sender: TObject);
var IniFile : TIniFile;
begin
NBBackColor := FRGB(GetRValue(ColorToRGB(pnNB.Color)),GetGValue(ColorToRGB(pnNB.Color)),GetBValue(ColorToRGB(pnNB.Color)));
Application.OnDeactivate :=OnAppDeactivate;
BackIMG.Width := ClientRect.Right - ClientRect.Left;
BackIMG.Height := ClientRect.Bottom - ClientRect.Top;
iniFile := TIniFile.Create(extractFilePath(Application.EXEName) + INIFILENAME);
currskin := inifile.ReadString('Data','DataDirName','classic');
blockPreview := inifile.ReadBool('Options','PreviewBlock',false);
STARTINGROWS := inifile.ReadInteger('Options','StartingRows',0);
GameClock.Interval := inifile.ReadInteger('Options','TimeDelay',140);
inifile.Free;
case STARTINGROWS of 0: N01.Checked := True;
                     1: N11.Checked := True;
                     2: N21.Checked := True;
                     3: N31.Checked := True;
                     4: N41.Checked := True;
                     5: N51.Checked := True;
                     6: N61.Checked := True;
                     7: N71.Checked := True;
                     8: N81.Checked := True;
                     9: N91.Checked := True;
end;
mnuNB.Checked := BlockPreview;
//currskin := 'vedran';
TetrisGame.CurrLevel := 1;
InitBlockBitmaps;
NewGame;
// centering code moved to Newgame
mnuSFX.Checked := SFX;
Caption := APPNAME;
end;

procedure TfrmTetris.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var //x,y : integer;
    CANDOIT : boolean;
    //TMP : TBlock;
    //TMP2 : integer;
begin
//Caption := IntTostr(key); // DEBUG
if not CANTOUCH then Exit;
with TetrisGame do
begin
     case key of
      39:
      begin
      //CANDOIT := TRUE;
      {while CheckYR(Block) do
      begin
       inc(mi);
      end;
      If (XPOS  >= (FIELDWIDTH -(BlockWidth+mi)))  then
      begin
           CANDOIT := False;
           exit;
      end;}
      //for y := YPOS  to YPOS + BlockHeight do
      //IF PlayMatrix[y, XPOS + ((BlockWidth+1)-CenterX)] > ftMoving then CANDOIT := False;
      CanDoit := CheckPutY(Block, XPOS+1,YPOS);
      IF CANDOIT then
      begin
           RemoveBlock(XPOS,YPOS);
           INC(XPOS);
           PutBlock(XPOS,YPOS);
           PlayArea.Draw;
      end;
      end;
      37:
      begin
      //CANDOIT := TRUE;
      {If XPOS + CenterY  = 0 then
      begin
           CANDOIT := False;
           exit;
      end;}
      CanDoit := CheckPutY(Block, XPOS-1,YPOS);
      IF CANDOIT then
      begin
           RemoveBlock(XPOS,YPOS);
           DEC(XPOS);
           PutBlock(XPOS,YPOS);
           PlayArea.Draw;
      end;
      end;
      //113: NewGame;
      38,12:
      begin
           RemoveBlock(XPOS,YPOS);
           RotateBlock;
           PutBlock(XPOS,YPOS);
           PlayArea.Draw;
          { RemoveBlock(XPOS,YPOS);
           for y := 0 to 3 do
            for x := 0 to 3 do
            begin
                TMP[y,x] := Block[x,y];
            end;
           if CheckPutY(TMP,XPOS,YPOS) and CheckPutX(TMP,XPOS,YPOS) then
           begin
                Block := TMP;
                TMP2 := CenterY;
                CenterY := CenterX;
                CenterX := TMP2;
                PutBlock(XPOS,YPOS);
           end; }
      end;
      116:
      begin
           GameClock.Interval := GameClock.interval -10;
           lblLevel.Caption := IntToStr(GameClock.Interval);
      end;
      117:
      begin
           GameClock.Interval := GameClock.interval +10;
           lblLevel.Caption := IntToStr(GameClock.Interval);           
      end;
      40:
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


procedure TfrmTetris.RotateBlock;
var TMP2 : integer;
    TMP : TBlock;
    ri : integer;
begin
with TetrisGame do
begin
   //if XPOS < BLOCKWIDTH then exit;
   //if YPOS + BLOCKWIDTH >= FIELDHEIGHT then exit;
   //if XPOS + BLOCKHEIGHT >= FIELDWIDTH then EXIT;
   ri := rotateindex;
   if NumRotations > RotateIndex then
       inc(rotateindex)
    else RotateIndex := 0;
    
     case BlockType of
          ftIBLOCK:
          begin
               case Rotateindex of
               0: TMP := IBLOCKR0;
               1: TMP := IBLOCKR1;
               end;
          end;
          ftCANONBLOCK:
          begin
               case Rotateindex of
               0: TMP := CANONBLOCKR0;
               1: TMP := CANONBLOCKR1;
               2: TMP := CANONBLOCKR2;
               3: TMP := CANONBLOCKR3;

               end;
          end;
          ftL2BLOCK:
          begin
               case Rotateindex of
               0: TMP := L2BLOCKR0;
               1: TMP := L2BLOCKR1;
               2: TMP := L2BLOCKR2;
               3: TMP := L2BLOCKR3;
               end;
          end;
          ftL1BLOCK:
          begin
               case Rotateindex of
               0: TMP := L1BLOCKR0;
               1: TMP := L1BLOCKR1;
               2: TMP := L1BLOCKR2;
               3: TMP := L1BLOCKR3;
               end;
          end;
          ftSTH1BLOCK :
          begin
               case Rotateindex of
               0: TMP := STH1BLOCKR0;
               1: TMP := STH1BLOCKR1;

               end;
          end;

          ftSTH2BLOCK :
          begin
               case Rotateindex of
               0: TMP := STH2BLOCKR0;
               1: TMP := STH2BLOCKR1;

               end;
          end;
     end;
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
        //else if
        else
        begin
             rotateindex := ri;
             exit;
        end;
   end;

   TMP2 := CenterX;
   CenterX := CenterY;
   CenterY := TMP2;

   TMP2 := BlockHeight;
   BlockHeight := BlockWidth;
   BlockWidth := TMP2;


     case BlockType of
          ftIBLOCK:
          begin
               case Rotateindex of
               0: BLock := IBLOCKR0;
               1: BLock := IBLOCKR1;
               end;
          end;
          ftCANONBLOCK:
          begin
               case Rotateindex of
               0: BLock := CANONBLOCKR0;
               1: BLock := CANONBLOCKR1;
               2: BLock := CANONBLOCKR2;
               3: BLock := CANONBLOCKR3;

               end;
          end;
          ftL2BLOCK:
          begin
               case Rotateindex of
               0: BLock := L2BLOCKR0;
               1: BLock := L2BLOCKR1;
               2: BLock := L2BLOCKR2;
               3: BLock := L2BLOCKR3;
               end;
          end;
          ftL1BLOCK:
          begin
               case Rotateindex of
               0: BLock := L1BLOCKR0;
               1: BLock := L1BLOCKR1;
               2: BLock := L1BLOCKR2;
               3: BLock := L1BLOCKR3;
               end;
          end;
          ftSTH1BLOCK :
          begin
               case Rotateindex of
               0: BLock := STH1BLOCKR0;
               1: BLock := STH1BLOCKR1;

               end;
          end;

          ftSTH2BLOCK :
          begin
               case Rotateindex of
               0: BLock := STH2BLOCKR0;
               1: BLock := STH2BLOCKR1;

               end;
          end;
     end;

end;
end;

procedure TfrmTetris.DropDown;
var CANDOIT : boolean;
    SCRTMP : integer;
begin
//dodraw := false;
with TetrisGame do
begin
SCRTMP := YPOS*5;
CANDOIT := true;
while CANDOIT do
begin

     {if YPOS = FIELDHEIGHT -(BlockHeight) then
     begin
          NeutralizeBlock;
          GameState := gsCreatingBlock;
          CANTOUCH := False;
          RemoveBlocks;
          PlayArea.Draw;
          dodraw := true;
          Exit;
     end;}
     //if CANDOIT then
     //begin
     //for x := XPOS  to XPOS +(BlockWidth-1) do
     //begin
     //     if PlayMatrix[YPOS+CenterY+1, x] = STONED then
     //     begin
     //          CANDOIT := False;
     //          Break;
     //     end;
     //end;
     //end;
     if CANDOIT then CANDOIT := CheckPUTY(Block, XPOS,YPOS+1);
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
          //exit;
     end;

     if sfx then PlayArea.Draw; // OPTIONAL: does a nice little effect.. I'm keeping it
end;
Inc(score,SCRTMP+YPOS);
end;
dodraw := true;
if SFX then
begin
     GaussianBlur(PlayArea.Bmp,1); // EFECT
     //Emboss(PlayArea.Bmp);
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
SFX := not SFX;
mnuSFX.Checked := SFX;
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
 // color parameter should actually be bitmap
 DrawTOFbmp(Bitmap,dst,ix,iy);
end;
procedure TfrmTetris.mnuAboutClick(Sender: TObject);
begin
if GameClock.Enabled then mnuPauseClick(self);
ABox.ShowAboutBox;
//mnuPauseClick(self);
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
FillRect(NB.Bmp,0,0,SQUAREWIDTH *4, SQUAREHEIGHT *4, NBBackColor);
          case NextBlock of
               ftIBlock:
               begin
                    Blocky := IBLOCKR0;
               end;
               ftBoxBlock:
               begin
                    Blocky := BOXBLOCKR0;
               end;
               ftL1Block:
               begin
                    Blocky := L1BLOCKR0;
               end;
               ftL2Block:
               begin
                    Blocky := L2BLOCKR0;
               end;
               ftCanonBlock:
               begin
                    Blocky := CANONBLOCKR0;
               end;
               ftSTH1Block:
               begin
                    Blocky := STH1BLOCKR0;
               end;
               ftSTH2Block:
               begin
                    Blocky := STH2BLOCKR0;
               end;
     end;
     for y := 0 to 3 do
      for x := 0 to 3 do
      begin
           if Blocky[y,x] = ftMoving then
           begin
               //FillRect(NB.Bmp,(x)*SQUAREWIDTH,(y)*SQUAREHEIGHT,SQUAREWIDTH,SQUAREHEIGHT, ReturnBlockColor(NextBlock));
               ChooseBLockBitmap(nextblock,tmpbmp);
               DrawBlock(NB.Bmp,x*SQUAREWIDTH,y*SQUAREHEIGHT,tmpbmp); // IMPLEMENT
           end;
      end;
      NB.Draw;
end;
procedure TfrmTetris.mnuNBClick(Sender: TObject);
begin
BlockPreview := not BlockPReview;
pnNB.Visible := BlockPreview;
mnuNB.Checked := BlockPreview;
end;

procedure TfrmTetris.InitBlockBitmaps;
var path : string;
    f : textfile;
    VDB : TVDB;
    i : integer;
    trimint : shortint;
begin
    path := extractFilePath(Application.EXEName) + SKINDIR + '\' + currskin + '\';
    ibmp := TFastBMP.CreateFromFile(path+'i.bmp');
    boxbmp:= TFastBMP.CreateFromFile(path+'box.bmp');
    l1bmp:= TFastBMP.CreateFromFile(path+'l1.bmp');
    l2bmp:=TFastBMP.CreateFromFile(path+'l2.bmp');
    canonbmp := TFastBMP.CreateFromFile(path+'canon.bmp');
    sth1bmp := TFastBMP.CreateFromFile(path+'sth1.bmp');
    sth2bmp := TFastBMP.CreateFromFile(path+'sth2.bmp');
    ibmp.Tag := PFastBMP;
    boxbmp.Tag := PFastBMP;
    l1bmp.Tag := PFastBMP;
    l2bmp.Tag := PFastBMP;
    canonbmp.Tag := PFastBMP;
    sth1bmp.Tag := PFastBMP;
    sth2bmp.Tag := PFastBMP;
    Backbmp:= TFastBMP.CreateFromFile(path+'wall' + IntToStr(TetrisGame.CurrLevel)+'.bmp');
    backbmp.TileDraw(BackIMG.Canvas.Handle,0,0, ClientRect.Right - ClientRect.Left,ClientRect.Bottom - ClientRect.Top);
    BackIMG.Refresh;
    VDB := TVDB.Create;
    if not VDB.OpenFile(path+'block.def') then
    begin
         VDB.Free;
         Exit;
    end;
    trimint := -2;
    for i := 0-trimint to 3-trimint do
    begin
         IBLOCKR0[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         IBLOCKR0[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         IBLOCKR0[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         IBLOCKR0[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    for i := 0-trimint to 3-trimint do
    begin
         IBLOCKR1[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         IBLOCKR1[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         IBLOCKR1[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         IBLOCKR1[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    for i := 0-trimint to 3-trimint do
    begin
         BOXBLOCKR0[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         BOXBLOCKR0[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         BOXBLOCKR0[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         BOXBLOCKR0[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    for i := 0-trimint to 3-trimint do
    begin
         L1BLOCKR0[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         L1BLOCKR0[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         L1BLOCKR0[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         L1BLOCKR0[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    for i := 0-trimint to 3-trimint do
    begin
         L1BLOCKR1[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         L1BLOCKR1[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         L1BLOCKR1[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         L1BLOCKR1[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    for i := 0-trimint to 3-trimint do
    begin
         L1BLOCKR2[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         L1BLOCKR2[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         L1BLOCKR2[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         L1BLOCKR2[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    for i := 0-trimint to 3-trimint do
    begin
         L1BLOCKR3[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         L1BLOCKR3[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         L1BLOCKR3[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         L1BLOCKR3[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);

    for i := 0-trimint to 3-trimint do
    begin
         L2BLOCKR0[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         L2BLOCKR0[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         L2BLOCKR0[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         L2BLOCKR0[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    for i := 0-trimint to 3-trimint do
    begin
         L2BLOCKR1[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         L2BLOCKR1[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         L2BLOCKR1[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         L2BLOCKR1[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    for i := 0-trimint to 3-trimint do
    begin
         L2BLOCKR2[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         L2BLOCKR2[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         L2BLOCKR2[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         L2BLOCKR2[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    for i := 0-trimint to 3-trimint do
    begin
         L2BLOCKR3[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         L2BLOCKR3[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         L2BLOCKR3[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         L2BLOCKR3[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    for i := 0-trimint to 3-trimint do
    begin
         CANONBLOCKR0[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         CANONBLOCKR0[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         CANONBLOCKR0[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         CANONBLOCKR0[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    for i := 0-trimint to 3-trimint do
    begin
         CANONBLOCKR1[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         CANONBLOCKR1[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         CANONBLOCKR1[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         CANONBLOCKR1[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    for i := 0-trimint to 3-trimint do
    begin
         CANONBLOCKR2[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         CANONBLOCKR2[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         CANONBLOCKR2[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         CANONBLOCKR2[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    for i := 0-trimint to 3-trimint do
    begin
         CANONBLOCKR3[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         CANONBLOCKR3[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         CANONBLOCKR3[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         CANONBLOCKR3[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    for i := 0-trimint to 3-trimint do
    begin
         STH1BLOCKR0[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         STH1BLOCKR0[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         STH1BLOCKR0[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         STH1BLOCKR0[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    for i := 0-trimint to 3-trimint do
    begin
         STH1BLOCKR1[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         STH1BLOCKR1[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         STH1BLOCKR1[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         STH1BLOCKR1[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    for i := 0-trimint to 3-trimint do
    begin
         STH2BLOCKR0[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         STH2BLOCKR0[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         STH2BLOCKR0[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         STH2BLOCKR0[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    for i := 0-trimint to 3-trimint do
    begin
         STH2BLOCKR1[i+trimint,0] := StrToInt(VDB.GetData(i,1));
         STH2BLOCKR1[i+trimint,1] := StrToInt(VDB.GetData(i,2));
         STH2BLOCKR1[i+trimint,2] := StrToInt(VDB.GetData(i,3));
         STH2BLOCKR1[i+trimint,3] := StrToInt(VDB.GetData(i,4));
    end;
    dec(trimint,5);
    // other config options
    DELAYNUM := StrToInt(VDB.GetData(-trimint,1));
    dec(trimint,2);
    STARTYNUM := StrToInt(VDB.GetData(-trimint,1));
    dec(trimint,2);
    SQUAREWIDTH := StrToInt(VDB.GetData(-trimint,1));
    dec(trimint,2);
    SQUAREHEIGHT := StrToInt(VDB.GetData(-trimint,1));
    dec(trimint,2);
    FIELDWIDTH := StrToInt(VDB.GetData(-trimint,1));
    dec(trimint,2);
    FIELDHEIGHT := StrToInt(VDB.GetData(-trimint,1));

    vdb.free;
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
inifile.WriteBool('Options','PreviewBlock',blockPreview);
inifile.WriteInteger('Options','TimeDelay',GameClock.Interval);
inifile.WriteInteger('Options','StartingRows',STARTINGROWS);
inifile.Free;
end;

procedure TfrmTetris.PlayMeSound(WavFileName: String; MODE : Word);
var  s: Array[0..79] of char;
begin
sndPlaySound(nil,0);
StrPCopy(s, WavFileName);
sndPlaySound(s, MODE);
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
var i : integer;
begin
          GameClock.Enabled := False;
          if SFX then
             for i:= 0 to 60 do
             begin
               //delay(50);
               //Invert(PlayArea.Bmp);
               GaussianBlur(PlayArea.Bmp,2);
               //HShift(PlayArea.Bmp,1);
               //AddMonoNoise(PlayArea.Bmp,50);
               //Mosaic(PlayArea.Bmp,i,i);
               //Twist(PlayArea.Bmp,PlayArea.Bmp,300+i);
               //Lightness(PlayArea.Bmp,-5);
               //FishEye(PlayArea.Bmp,PlayArea.Bmp,i+1);
               PlayArea.Draw;
             end;
          {
          GrayScale(PlayArea.BMp);
          PlayArea.Draw;}
          //MessageBox(0,'Game Over','Luzer',0);
          ShowScores(Score);
          NewGame;
end;

procedure TfrmTetris.OnAppDeactivate(Sender : TObject);
begin
if GameClock.Enabled then mnuPauseClick(self);
end;

procedure TfrmTetris.N01Click(Sender: TObject);
begin
STARTINGROWS := 0;
TMenuItem(Sender).Checked := True;
end;

procedure TfrmTetris.N11Click(Sender: TObject);
begin
STARTINGROWS := 1;
TMenuItem(Sender).Checked := True;
end;

procedure TfrmTetris.N21Click(Sender: TObject);
begin
STARTINGROWS := 2;
TMenuItem(Sender).Checked := True;
end;

procedure TfrmTetris.N31Click(Sender: TObject);
begin
STARTINGROWS := 3;
TMenuItem(Sender).Checked := True;
end;

procedure TfrmTetris.N41Click(Sender: TObject);
begin
STARTINGROWS := 4;
TMenuItem(Sender).Checked := True;
end;

procedure TfrmTetris.N51Click(Sender: TObject);
begin
STARTINGROWS := 5;
TMenuItem(Sender).Checked := True;
end;

procedure TfrmTetris.N61Click(Sender: TObject);
begin
STARTINGROWS := 6;
TMenuItem(Sender).Checked := True;
end;

procedure TfrmTetris.N71Click(Sender: TObject);
begin
STARTINGROWS := 7;
TMenuItem(Sender).Checked := True;

end;

procedure TfrmTetris.N81Click(Sender: TObject);
begin
STARTINGROWS := 8;
TMenuItem(Sender).Checked := True;

end;

procedure TfrmTetris.N91Click(Sender: TObject);
begin
STARTINGROWS := 9;
TMenuItem(Sender).Checked := True;

end;

end.
