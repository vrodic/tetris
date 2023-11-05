unit Fast256;

interface                           // 3-11-99
                                    // Gordon A.Cowie
uses Windows, FastRGB, FastBMP;

const                    // TFast256 v0.7
{$IFDEF VER90}           //   This is a unit much like FastBMP
  hSection=nil;          //   only an extra property "Colors"
{$ELSE}                  //   which is the color table and
  hSection=0;            //   Pixels[y,x] = Byte  not compatible
{$ENDIF}                 //   with TFastRGB.Pixels  (FastFX)

type
TFColorEntry      = record b,g,r,a:Byte; end;
TFColorEntryArray = array[0..255]of TFColorEntry;
PFColorEntryArray =^TFColorEntryArray;

TBitmapInfo256 = record
  bmiHeader: TBitmapInfoHeader;
  bmiColors: TFColorEntryArray;
end;

TBytes  = array[0..0]of Byte;
PBytes  =^TBytes;
TPBytes = array[0..0]of PBytes;
PPBytes =^TPBytes;

TFast256=class (TFastRGB)
private
  procedure   Initialize;
public
  hDC,
  Handle:     Integer;
  bmInfo:     TBitmapInfo256;
  Colors:     PFColorEntryArray;
  Pixels:     PPBytes;
  // constructors
  constructor Create(cx,cy:Integer);
  constructor CreateGrayscale(hBmp:TFastRGB);
  constructor CreateFromRGB(FB:TFastRGB);
  constructor CreateFromhBmp(hBmp:Integer);
  constructor CreateFromFile(lpFile:string);
  constructor CreateFromRes(hInst:Integer;lpName:string);
  constructor CreateCopy(hBmp:TFast256);
  destructor  Destroy; override;
  // tools
  procedure   CopyColors(Src:TFast256);
  procedure   ShiftColors(Amount:Integer);
  procedure   GrayScale;
  // gdi routines
  procedure   Draw(hDst,x,y:Integer); override;
  procedure   Stretch(hDst,x,y,w,h:Integer); override;
  procedure   DrawRect(hDst,x,y,w,h,sx,sy:Integer); override;
  procedure   TileDraw(hDst,x,y,w,h:Integer); override;
  // software routines
  procedure   CopyRect(Dst:TFastRGB;x,y,w,h,sx,sy:Integer); override;
  procedure   Tile(Dst:TFastRGB); override;
  procedure   Resize(Dst:TFastRGB); override;
  procedure   SmoothResize(Dst:TFastRGB); override;
end;

function FRGBA(r,g,b,a:Byte):TFColorEntry;

implementation

function FRGBA(r,g,b,a:Byte):TFColorEntry;
begin
  Result.b:=b;
  Result.g:=g;
  Result.r:=r;
  Result.a:=a;
end;

constructor TFast256.Create(cx,cy:Integer);
begin
  Width:=cx;
  Height:=cy;

  with bmInfo.bmiHeader do
  begin
    biSize:=SizeOf(TBitmapInfoHeader);
    biWidth:=Width;
    biHeight:=-Height;
    biPlanes:=1;
    biBitCount:=8;
    biCompression:=BI_RGB;
  end;

  Handle:=CreateDIBSection(0,
                   PBitmapInfo(@bmInfo)^,
                   DIB_PAL_COLORS,
                   Bits,
                   hSection,
                   0);
  Initialize;
end;

constructor TFast256.CreateGrayscale(hBmp:TFastRGB);
var
x,y,i: Integer;
p:     PByte;
Tmp:   PFColor;
Div3:  array[0..765]of Byte;
begin
  Create(hBmp.Width,hBmp.Height);
  x:=0; y:=0;
  for i:=0 to 255 do
  begin
    Div3[x+0]:=y;
    Div3[x+1]:=y;
    Div3[x+2]:=y;
    Inc(y);
    Inc(x,3);
  end;

  Tmp:=hBmp.Bits;
  p:=Bits;
  for y:=0 to hBmp.Height-1 do
  begin
    for x:=0 to hBmp.Width-1 do
    begin
      p^:=Div3[Tmp.b+Tmp.g+Tmp.r];
      Inc(Tmp);
      Inc(p);
    end;
    Tmp:=Ptr(Integer(Tmp)+hBmp.Gap);
    p:=Ptr(Integer(p)+Gap);
  end;

  for i:=0 to 255 do
  begin
    bmInfo.bmiColors[i].r:=i;
    bmInfo.bmiColors[i].g:=i;
    bmInfo.bmiColors[i].b:=i;
  end;
end;

// median-cut color quantization implemented by Vit - THANK YOU! ;-)
// no dither/error difusion (yet)
constructor TFast256.CreateFromRGB(FB:TFastRGB);
type
PCube = ^TCube;
TCube = record
  X1,Y1,Z1:Byte;
  X2,Y2,Z2:Byte;
  Next:PCube;
end;

var
A,B,C,
D,E,F:     Integer;
Space:     array[0..31,0..31,0..31]of Byte;  //15bpp
Start,Cub,
Cub2,CF:   PCube;
Cl:        PFColor;
CNum:      Byte;
PB:        PByte;

procedure OptimizeCube(var Cb:PCube);
var
G,H,I: ShortInt;
begin
  A:=32;
  B:=32;
  C:=32;
  D:=-1;
  E:=-1;
  F:=-1;
  for G:=Cb.X1 to Cb.X2 do
  for H:=Cb.Y1 to Cb.Y2 do
  for I:=Cb.Z1 to Cb.Z2 do
  begin
    if Space[G,H,I]>0 then
    begin
      if G<A then A:=G;
      if G>D then D:=G;
      if H<B then B:=H;
      if H>E then E:=H;
      if I<C then C:=I;
      if I>F then F:=I;
    end;
  end;
  Cb.X1:=A;
  Cb.Y1:=B;
  Cb.Z1:=C;
  Cb.X2:=D;
  Cb.Y2:=E;
  Cb.Z2:=F;
end;

begin
  Create(FB.Width,FB.Height);
  ZeroMemory(@Space,SizeOf(Space));

  Cl:=FB.Bits;
  for A:=0 to FB.Height-1 do
  begin
    for B:=0 to FB.Width-1 do
    begin
      Space[Cl.r shr 3,Cl.g shr 3,Cl.b shr 3]:=1;
      Inc(Cl);
    end;
    Cl:=Ptr(Integer(Cl)+FB.Gap);
  end;

  New(Start);
  Start.Next:=nil;
  Start.X1:=0;
  Start.Y1:=0;
  Start.Z1:=0;
  Start.X2:=31;
  Start.Y2:=31;
  Start.Z2:=31;
  OptimizeCube(Start);
  CNum:=0;

  repeat
    A:=1;
    Cub:=Start;
    repeat
      C:=A;
      if Cub.X2-Cub.X1>A then
      begin
        A:=Cub.X2-Cub.X1;
        D:=0;
      end;
      if Cub.Y2-Cub.Y1>A then
      begin
        A:=Cub.Y2-Cub.Y1;
        D:=1;
      end;
      if Cub.Z2-Cub.Z1>A then
      begin
        A:=Cub.Z2-Cub.Z1;
        D:=2;
      end;
      if C<>A then CF:=Cub;
      Cub2:=Cub;
      Cub:=Cub^.Next;
    until Cub=nil;
    if A=1 then Break;

    New(Cub);
    Cub2^.Next:=Cub;
    Inc(CNum);
    Cub^.Next:=nil;
    Cub.X1:=CF.X1;
    Cub.X2:=CF.X2;
    Cub.Y1:=CF.Y1;
    Cub.Y2:=CF.Y2;
    Cub.Z1:=CF.Z1;
    Cub.Z2:=CF.Z2;

    case D of
    0: begin
       CF.X2:=(CF.X1+CF.X2)shr 1;
       Cub.X1:=CF.X2+1;
       end;
    1: begin
       CF.Y2:=(CF.Y1+CF.Y2)shr 1;
       Cub.Y1:=CF.Y2+1;
       end;
    2: begin
       CF.Z2:=(CF.Z1+CF.Z2)shr 1;
       Cub.Z1:=CF.Z2+1;
       end;
    end;

    OptimizeCube(Cub);
    OptimizeCube(CF);
  until CNum=255;

  Cub:=Start;
  D:=0;
  repeat
    for A:=Cub.X1 to Cub.X2 do
    for B:=Cub.Y1 to Cub.Y2 do
    for C:=Cub.Z1 to Cub.Z2 do
      Space[A,B,C]:=D;

    bmInfo.bmiColors[D].r:=((Cub.X1+Cub.X2)shr 1)shl 3;
    bmInfo.bmiColors[D].g:=((Cub.Y1+Cub.Y2)shr 1)shl 3;
    bmInfo.bmiColors[D].b:=((Cub.Z1+Cub.Z2)shr 1)shl 3;

    Inc(D);
    Cub2:=Cub;
    Cub:=Cub^.Next;
    Dispose(Cub2);
  until Cub=nil;

  PB:=Bits;
  Cl:=FB.Bits;
  for A:=0 to FB.Height-1 do
  begin
    for B:=0 to FB.Width-1 do
    begin
      PB^:=Space[Cl^.r shr 3,Cl^.g shr 3,Cl^.b shr 3];
      Inc(PB);
      Inc(Cl);
    end;
    PB:=Ptr(Integer(PB)+Gap);
    Cl:=Ptr(Integer(Cl)+FB.Gap);
  end;
end;

// if hBmp.bpp>8 then CreateFromRGB is used
constructor TFast256.CreateFromhBmp(hBmp:Integer);
var
Tmp:   TFastBMP;
Bmp:   TDibSection;
memDC: Integer;
begin
  GetObject(hBmp,SizeOf(Bmp),@Bmp);

  if Bmp.dsbm.bmBitsPixel>8 then
  begin
    Tmp:=TFastBMP.CreateFromhBmp(hBmp);
    CreateFromRGB(Tmp);
    Tmp.Free;
    Exit;
  end;

  Width:=Bmp.dsBm.bmWidth;
  Height:=Bmp.dsBm.bmHeight;

  with bmInfo.bmiHeader do
  begin
    biSize:=SizeOf(TBitmapInfoHeader);
    biWidth:=Width;
    biHeight:=-Height;
    biPlanes:=1;
    biBitCount:=8;
    biCompression:=BI_RGB;
  end;
  Handle:=CreateDIBSection(0,
                   PBitmapInfo(@bmInfo)^,
                   DIB_PAL_COLORS,
                   Bits,
                   hSection,
                   0);
  memDC:=CreateCompatibleDC(0);
  SelectObject(memDC,hBmp);
  GetDIBits(memDC,hBmp,0,Height,Bits,PBitmapInfo(@bmInfo)^,DIB_RGB_COLORS);
  DeleteDC(memDC);
  Initialize;
end;

constructor TFast256.CreateFromFile(lpFile:string);
var
hBmp: Integer;
begin
  hBmp:=LoadImage(0,PChar(lpFile),IMAGE_BITMAP,0,0,LR_LOADFROMFILE or LR_CREATEDIBSECTION);
  CreateFromhBmp(hBmp);
  DeleteObject(hBmp);
end;

constructor TFast256.CreateFromRes(hInst:Integer;lpName:string);
var
hBmp: Integer;
begin
  hBmp:=LoadImage(hInst,PChar(lpName),IMAGE_BITMAP,0,0,LR_CREATEDIBSECTION);
  CreateFromhBmp(hBmp);
  DeleteObject(hBmp);
end;

constructor TFast256.CreateCopy(hBmp:TFast256);
begin
  bmInfo:=hBmp.bmInfo;
  Width:=hBmp.Width;
  Height:=hBmp.Height;
  Size:=hBmp.Size;
  Handle:=CreateDIBSection(0,
                 PBitmapInfo(@bmInfo)^,
                 DIB_PAL_COLORS,
                 Bits,
                 hSection,
                 0);
  CopyMemory(Bits,hBmp.Bits,Size);
  CopyColors(hBmp);
  Initialize;
end;

destructor TFast256.Destroy;
begin
  DeleteDC(hDC);
  DeleteObject(Handle);
  FreeMem(Pixels);
  inherited;
end;

procedure TFast256.Initialize;
var
i: Integer;
x: Longint;
begin
  hDC:=CreateCompatibleDC(0);
  SelectObject(hDC,Handle);

  GetMem(Pixels,Height*SizeOf(PBytes));
  RowInc:=((Width*8+31)shr 5)shl 2;
  Gap:=RowInc-Width;
  Size:=RowInc*Height;
  x:=Integer(Bits);
  for i:=0 to Height-1 do
  begin
    Pixels[i]:=Pointer(x);
    Inc(x,RowInc);
  end;
  Tag:=PFast256;
  Colors:=@bmInfo.bmiColors;
end;

procedure TFast256.Draw(hDst,x,y:Integer);
begin
  StretchDIBits(hDst,x,y,Width,Height,
    0,0,Width,Height,
    Bits,
    PBitmapInfo(@bmInfo)^,
    DIB_RGB_COLORS,
    SRCCOPY);
end;

procedure TFast256.Stretch(hDst,x,y,w,h:Integer);
begin
  SetStretchBltMode(hDst,STRETCH_DELETESCANS);
  StretchDIBits(hDst,x,y,w,h,
    0,0,Width,Height,
    Bits,
    PBitmapInfo(@bmInfo)^,
    DIB_RGB_COLORS,
    SRCCOPY);
end;

procedure TFast256.DrawRect(hDst,x,y,w,h,sx,sy:Integer);
begin
  StretchDIBits(hDst,x,y,w,h,
    sx,sy,w,h,
    Bits,
    PBitmapInfo(@bmInfo)^,
    DIB_RGB_COLORS,
    SRCCOPY);
end;

procedure TFast256.TileDraw(hDst,x,y,w,h:Integer);
var
wd,hd,
hBmp,
memDC: Integer;
begin
  memDC:=CreateCompatibleDC(hDst);
  hBmp:=CreateCompatibleBitmap(hDst,w,h);
  SelectObject(memDC,hBmp);
  Draw(memDC,0,0);
  wd:=Width;
  hd:=Height;
  while wd<w do
  begin
    BitBlt(memDC,wd,0,wd*2,h,memDC,0,0,SRCCOPY);
    Inc(wd,wd);
  end;
  while hd<h do
  begin
    BitBlt(memDC,0,hd,w,hd*2,memDC,0,0,SRCCOPY);
    Inc(hd,hd);
  end;
  BitBlt(hDst,x,y,w,h,memDC,0,0,SRCCOPY);
  DeleteDC(memDC);
  DeleteObject(hBmp);
end;

procedure TFast256.CopyColors(Src:TFast256);
begin
  CopyMemory(@bmInfo.bmiColors,@Src.bmInfo.bmiColors,256*4);
end;

procedure TFast256.ShiftColors(Amount:Integer);
var
Buf: Pointer;
begin
  if Amount<0 then Amount:=256-(Abs(Amount) mod 256);
  if Amount>256 then Amount:=Amount mod 256;
  if Amount=0 then Exit;
  GetMem(Buf,Amount*4);
  CopyMemory(Buf,Ptr(Integer(@bmInfo.bmiColors)+((256-Amount)*4)),Amount*4);
  MoveMemory(Ptr(Integer(@bmInfo.bmiColors)+(Amount*4)),@bmInfo.bmiColors,(256-Amount)*4);
  CopyMemory(@bmInfo.bmiColors,Buf,Amount*4);
  FreeMem(Buf);
end;

procedure TFast256.GrayScale;
var
Div3:  array[0..765]of Byte;
Gray:  array[0..255]of Byte;
i,x,y: Integer;
Tmp:   PByte;
begin
  x:=0; y:=0;
  for i:=0 to 255 do
  begin
    Div3[x+0]:=y;
    Div3[x+1]:=y;
    Div3[x+2]:=y;
    Inc(y);
    Inc(x,3);
  end;
  for i:=0 to 255 do
  Gray[i]:=Div3[bmInfo.bmiColors[i].b+
                bmInfo.bmiColors[i].g+
                bmInfo.bmiColors[i].r];
  Tmp:=Bits;
  for y:=0 to Height-1 do
  begin
    for x:=0 to Width-1 do
    begin
      Tmp^:=Gray[Tmp^];
      Inc(Tmp);
    end;
    Tmp:=Ptr(Integer(Tmp)+Gap);
  end;
  for i:=0 to 255 do
  begin
    bmInfo.bmiColors[i].b:=i;
    bmInfo.bmiColors[i].g:=i;
    bmInfo.bmiColors[i].r:=i;
  end;
end;

procedure TFast256.CopyRect(Dst:TFastRGB;x,y,w,h,sx,sy:Integer);
var
n1,n2: Pointer;
i:     Integer;
begin
  if x<0 then
  begin
    sx:=sx+(-x);
    w:=w+x;
    x:=0;
  end;
  if y<0 then
  begin
    sy:=sy+(-y);
    h:=h+y;
    y:=0;
  end;
  if sx<0 then
  begin
    x:=x+(-sx);
    w:=w+sx;
    sx:=0;
  end;
  if sy<0 then
  begin
    y:=y+(-sy);
    h:=h+sy;
    sy:=0;
  end;
  if(sx>Width-1)or(sy>Height-1)then Exit;

  if sx+w>Width     then w:=w-((sx+w)-(Width));
  if sy+h>Height    then h:=h-((sy+h)-(Height));
  if x+w>Dst.Width  then w:=w-((x+w)-(Dst.Width));
  if y+h>Dst.Height then h:=h-((y+h)-(Dst.Height));

  n1:=@TFast256(Dst).Pixels[y,x];
  n2:=@Pixels[sy,sx];
  for i:=0 to h-1 do
  begin
    CopyMemory(n1,n2,w);
    n1:=Ptr(Integer(n1)+Dst.RowInc);
    n2:=Ptr(Integer(n2)+RowInc);
  end;
end;

procedure TFast256.Tile(Dst:TFastRGB);
var
w,h,cy,cx: Integer;
begin
  if(Dst.Width=0)or(Dst.Height=0)then Exit;
  CopyRect(Dst,0,0,Width,Height,0,0);
  w:=Width;
  h:=Height;
  cx:=Dst.Width;
  cy:=Dst.Height;
  while w<cx do
  begin
    Dst.CopyRect(Dst,w,0,w*2,h,0,0);
    Inc(w,w);
  end;
  while h<cy do
  begin
    Dst.CopyRect(Dst,0,h,w,h*2,0,0);
    Inc(h,h);
  end;
end;

procedure TFast256.Resize(Dst:TFastRGB);
var
xCount,
yCount,
x,y,xP,yP,
xD,yD,
yiScale,
xiScale:  Integer;
xScale,
yScale:   Single;
Read,
Line:     PBytes;
Tmp:      Byte;
pc:       PByte;
begin
  if(Dst.Width=0)or(Dst.Height=0)then Exit;
  if(Dst.Width=Width)and(Dst.Height=Height)then
  begin
    CopyMemory(Dst.Bits,Bits,Size);
    Exit;
  end;

  xScale:=Dst.Width/Width;
  yScale:=Dst.Height/Height;
  if(xScale<1)or(yScale<1)then
  begin  // shrinking
    xiScale:=(Width shl 16) div Dst.Width;
    yiScale:=(Height shl 16) div Dst.Height;
    yP:=0;
    for y:=0 to Dst.Height-1 do
    begin
      xP:=0;
      read:=Pixels[yP shr 16];
      pc:=@TFast256(Dst).Pixels[y,0];
      for x:=0 to Dst.Width-1 do
      begin
        pc^:=Read[xP shr 16];
        Inc(pc);
        Inc(xP,xiScale);
      end;
      Inc(yP,yiScale);
    end;
  end
  else   // zooming
  begin
    yiScale:=Round(yScale+0.5);
    xiScale:=Round(xScale+0.5);
    GetMem(Line,Dst.Width);
    for y:=0 to Height-1 do
    begin
      yP:=Trunc(yScale*y);
      Read:=Pixels[y];
      for x:=0 to Width-1 do
      begin
        xP:=Trunc(xScale*x);
        Tmp:=Read[x];
        for xCount:=0 to xiScale-1 do
        begin
          xD:=xCount+xP;
          if xD>=Dst.Width then Break;
          Line[xD]:=Tmp;
        end;
      end;
      for yCount:=0 to yiScale-1 do
      begin
        yD:=yCount+yP;
        if yD>=Dst.Height then Break;
        CopyMemory(TFast256(Dst).Pixels[yD],Line,Dst.Width);
      end;
    end;
    FreeMem(Line);
  end;
end;

// this will only look good if the color table is evenly spaced
procedure TFast256.SmoothResize(Dst:TFastRGB);
var
x,y,xP,yP,
yP2,xP2,
t,z,z2,iz2,
w1,w2,w3,w4:  Integer;
Read,Read2:   PBytes;
pc,Col1,Col2: PByte;
begin
  if(Dst.Width<1)or(Dst.Height<1)then Exit;
  if Width=1 then
  begin
    Resize(Dst);
    Exit;
  end;
  if(Dst.Width=Width)and(Dst.Height=Height)then
  begin
    CopyMemory(Dst.Bits,Bits,Size);
    Exit;
  end;
  xP2:=((Width-1)shl 15)div Dst.Width;
  yP2:=((Height-1)shl 15)div Dst.Height;
  yP:=0;
  for y:=0 to Dst.Height-1 do
  begin
    xP:=0;
    Read:=Pixels[yP shr 15];
    if yP shr 16<Height-1 then
      Read2:=Pixels[yP shr 15+1]
    else
      Read2:=Pixels[yP shr 15];
    pc:=@TFast256(Dst).Pixels[y,0];
    z2:=yP and $7FFF;
    iz2:=$8000-z2;
    for x:=0 to Dst.Width-1 do
    begin
      t:=xP shr 15;
      Col1:=@Read[t];
      Col2:=@Read2[t];
      z:=xP and $7FFF;
      w2:=(z*iz2)shr 15;
      w1:=iz2-w2;
      w4:=(z*z2)shr 15;
      w3:=z2-w4;
      pc^:=
        (Col1^*w1+PByte(Integer(Col1)+1)^*w2+
         Col2^*w3+PByte(Integer(Col2)+1)^*w4)shr 15;
      Inc(pc);
      Inc(xP,xP2);
    end;
    Inc(yP,yP2);
  end;
end;

end.
