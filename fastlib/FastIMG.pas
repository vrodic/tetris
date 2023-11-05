unit FastIMG;

interface

uses
  Windows, Messages, Classes, Controls, FastRGB, FastBMP, SysUtils, Fast256,Graphics;

type
TDrawStyle=(dsDraw,dsStretch,dsTile,dsCenter,
            dsTile_VCL,dsStretch_VCL,dsSmoothResize);

TFastIMG=class (TCustomControl)
  private
    Style:      TDrawStyle;
    Size:       Boolean;
    bmType:     bmTag;
    fzFile:     string;
    procedure   SetAutoSize(Auto:Boolean);
    procedure   SetDrawStyle(fStyle:TDrawStyle);
    procedure   SetDataType(wht:bmTag);
    procedure   SetFileName(sfile:string);
  public
    Bmp:        TFastRGB;
    procedure   LoadFromFile(lpFile:string;wht:bmTag);
    procedure   CreateNew(cx,cy:Integer;wht:bmTag);
    procedure   Repaint(var Msg:TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure   Draw;
    constructor Create(AOwner:TComponent); override;
    destructor  Destroy; override;
  published
    property    FileName:string read fzFile write SetFileName;
    property    DataType:bmTag read bmType write SetDataType default PFastBMP;
    property    DrawStyle:TDrawStyle read Style write SetDrawStyle default dsDraw;
    property    AutoSize:Boolean read Size write SetAutoSize;
    property    Align;
    property    Color;
    property    DragCursor;
    property    DragMode;
    property    Enabled;
    property    Font;
    property    ParentColor;
    property    ParentFont;
    property    ParentShowHint;
    property    PopupMenu;
    property    ShowHint;
    property    Visible;
    property    OnClick;
    property    OnDblClick;
    property    OnDragDrop;
    property    OnDragOver;
    property    OnEndDrag;
    property    OnMouseDown;
    property    OnMouseMove;
    property    OnMouseUp;
    property    OnStartDrag;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TFastIMG]);
end;

constructor TFastIMG.Create(AOwner: TComponent);
begin
  inherited;
  SetBounds(Left,Top,100,100);
end;

destructor TFastIMG.Destroy;
begin
  Bmp.Free;
  inherited;
end;

procedure TFastIMG.LoadFromFile(lpFile:string;wht:bmTag);
begin
  if FileExists(lpFile)then
  begin
    Bmp.Free;
    case wht of
      PFastBMP: Bmp:=TFastBMP.CreateFromFile(lpFile);
      PFast256: Bmp:=TFast256.CreateFromFile(lpFile);
      //PFastDDB: Bmp:=TFastDDB.Create(cx,cy);
    end;
    if(Size)and(Align=alNone)then
    SetBounds(Left,Top,Bmp.Width,Bmp.Height);
    bmType:=wht;
  end;
end;

procedure TFastIMG.CreateNew(cx,cy:Integer;wht:bmTag);
begin
  Bmp.Free;
  case wht of
    PFastBMP: Bmp:=TFastBMP.Create(cx,cy);
    PFast256: Bmp:=TFast256.Create(cx,cy);
    //PFastDDB: Bmp:=TFastDDB.Create(cx,cy);
  end;
  if(Size)and(Align=alNone)then
  SetBounds(Left,Top,Bmp.Width,Bmp.Height);
  bmType:=wht;
end;

procedure TFastIMG.SetAutoSize(Auto:Boolean);
begin
  Size:=Auto;
  if(Size)and(Bmp<>nil)and(Align=alNone)then
  SetBounds(Left,Top,Bmp.Width,Bmp.Height);
  Refresh;
end;

procedure TFastIMG.SetDrawStyle(fStyle:TDrawStyle);
begin
  Style:=fStyle;
  if(Style=dsDraw)and(Size=True)and(Bmp<>nil)and(Align=alNone)then
  SetBounds(Left,Top,Bmp.Width,Bmp.Height);
  Refresh;
end;

procedure TFastIMG.SetDataType(wht:bmTag);
var
Tmp: TFastRGB;
begin
  if wht=PFastDDB then Exit;
  if Bmp<>nil then
  begin
    if Bmp.Tag=wht then Exit;
    if(Bmp.Tag=PFastBMP)and(wht=PFast256)then
    begin
      if fzFile<>'' then
      begin
        Bmp.Free;
        Bmp:=TFast256.CreateFromFile(fzFile);
      end else
      begin
        Tmp:=TFast256.CreateFromRGB(Bmp);
        Bmp.Free;
        Bmp:=TFast256.CreateCopy(TFast256(Tmp));
        Tmp.Free;
      end;
    end else
    begin
      if fzFile<>'' then
      begin
        Bmp.Free;
        Bmp:=TFastBMP.CreateFromFile(fzFile);
      end else
      begin
        Tmp:=TFast256.CreateCopy(TFast256(Bmp));
        Bmp.Free;
        Bmp:=TFastBMP.Create(Tmp.Width,Tmp.Height);
        Tmp.Draw(TFastBMP(Bmp).hDC,0,0);
        Tmp.Free;
      end;
    end;
    Refresh;
  end;
  bmType:=wht;
end;

procedure TFastIMG.SetFileName(sfile:string);
begin
  if sfile='' then Bmp:=nil else LoadFromFile(sfile,bmType);
  fzFile:=sfile;
  Refresh;
end;

procedure TFastIMG.Repaint(var Msg:TWMEraseBkgnd);
var
cw,ch,
rBmp,
rWin: Integer;
Tmp:  TFastRGB;
Rct:  TRect;
begin
  Windows.GetClientRect(Handle,Rct);
  if Bmp<>nil then
  case Style of
    dsDraw:
    begin
      Bmp.Draw(Msg.DC,0,0);
      rWin:=CreateRectRgn(0,0,Rct.Right,Rct.Bottom);
      rBmp:=CreateRectRgn(0,0,Bmp.Width,Bmp.Height);
      CombineRgn(rWin,rWin,rBmp,RGN_DIFF);
      FillRgn(Msg.DC,rWin,Brush.Handle);
      DeleteObject(rWin);
      DeleteObject(rBmp);
    end;
    dsStretch: Bmp.Stretch(Msg.DC,0,0,Rct.Right,Rct.Bottom);
    dsTile:    Bmp.TileDraw(Msg.DC,0,0,Rct.Right,Rct.Bottom);
    dsCenter:
    begin
      cw:=(Rct.Right-Bmp.Width)div 2;
      ch:=(Rct.Bottom-Bmp.Height)div 2;
      Bmp.Draw(Msg.DC,cw,ch);
      rWin:=CreateRectRgn(0,0,Rct.Right,Rct.Bottom);
      rBmp:=CreateRectRgn(cw,ch,Bmp.Width+cw,Bmp.Height+ch);
      CombineRgn(rWin,rWin,rBmp,RGN_DIFF);
      FillRgn(Msg.DC,rWin,Brush.Handle);
      DeleteObject(rWin);
      DeleteObject(rBmp);
    end;
    dsTile_VCL:
    begin
      case Bmp.Tag of
        PFastBMP: Tmp:=TFastBMP.Create(Rct.Right,Rct.Bottom);
        PFast256: begin
                  Tmp:=TFast256.Create(Rct.Right,Rct.Bottom);
                  TFast256(Tmp).CopyColors(TFast256(Bmp));
                  end;
        //PFastDDB: Tmp:=TFastDDB.Create(Rct.Right,Rct.Bottom);
      end;
      Bmp.Tile(Tmp);
      Tmp.Draw(Msg.DC,0,0);
      Tmp.Free;
    end;
    dsStretch_VCL:
    begin
      case Bmp.Tag of
        PFastBMP: Tmp:=TFastBMP.Create(Rct.Right,Rct.Bottom);
        PFast256: begin
                  Tmp:=TFast256.Create(Rct.Right,Rct.Bottom);
                  TFast256(Tmp).CopyColors(TFast256(Bmp));
                  end;
        //PFastDDB: Tmp:=TFastDDB.Create(Rct.Right,Rct.Bottom);
      end;
      Bmp.Resize(Tmp);
      Tmp.Draw(Msg.DC,0,0);
      Tmp.Free;
    end;
    dsSmoothResize:
    begin
      case Bmp.Tag of
        PFastBMP: Tmp:=TFastBMP.Create(Rct.Right,Rct.Bottom);
        PFast256: begin
                  Tmp:=TFast256.Create(Rct.Right,Rct.Bottom);
                  TFast256(Tmp).CopyColors(TFast256(Bmp));
                  end;
        //PFastDDB: Tmp:=TFastDDB.Create(Rct.Right,Rct.Bottom);
      end;
      Bmp.SmoothResize(Tmp);
      Tmp.Draw(Msg.DC,0,0);
      Tmp.Free;
    end;
  end else if csDesigning in ComponentState then
  begin
    Canvas.Pen.Style:=psDash;
    Canvas.Brush.Color:=Color;
    Canvas.Rectangle(0,0,Rct.Right,Rct.Bottom);
  end else FillRect(Msg.DC,Rct,Brush.Handle);
  Msg.Result:=1;
end;

procedure TFastIMG.Draw;
var
DC,cw,ch: Integer;
Tmp:      TFastRGB;
begin
  DC:=GetDC(Handle);
  if Bmp<>nil then
  case Style of
    dsDraw:    Bmp.Draw(DC,0,0);
    dsStretch: Bmp.Stretch(DC,0,0,Width,Height);
    dsTile:    Bmp.TileDraw(DC,0,0,Width,Height);
    dsCenter:
    begin
      cw:=(Width-Bmp.Width)div 2;
      ch:=(Height-Bmp.Height)div 2;
      Bmp.Draw(DC,cw,ch);
    end;
    dsTile_VCL:
    begin
      case Bmp.Tag of
        PFastBMP: Tmp:=TFastBMP.Create(Width,Height);
        PFast256: begin
                  Tmp:=TFast256.Create(Width,Height);
                  TFast256(Tmp).CopyColors(TFast256(Bmp));
                  end;
        //PFastDDB: Tmp:=TFastDDB.Create(Width,Height);
      end;
      Bmp.Tile(Tmp);
      Tmp.Draw(DC,0,0);
      Tmp.Free;
    end;
    dsStretch_VCL:
    begin
      case Bmp.Tag of
        PFastBMP: Tmp:=TFastBMP.Create(Width,Height);
        PFast256: begin
                  Tmp:=TFast256.Create(Width,Height);
                  TFast256(Tmp).CopyColors(TFast256(Bmp));
                  end;
        //PFastDDB: Tmp:=TFastDDB.Create(Width,Height);
      end;
      Bmp.Resize(Tmp);
      Tmp.Draw(DC,0,0);
      Tmp.Free;
    end;
    dsSmoothResize:
    begin
      case Bmp.Tag of
        PFastBMP: Tmp:=TFastBMP.Create(Width,Height);
        PFast256: begin
                  Tmp:=TFast256.Create(Width,Height);
                  TFast256(Tmp).CopyColors(TFast256(Bmp));
                  end;
        //PFastDDB: Tmp:=TFastDDB.Create(Width,Height);
      end;
      Bmp.SmoothResize(Tmp);
      Tmp.Draw(DC,0,0);
      Tmp.Free;
    end;
  end;
  ReleaseDC(Handle,DC);
end;

end.
