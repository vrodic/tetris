unit FastFX;    //  FastFX  (2/13/99)
                //    Gordon Alex Cowie <gfody@jps.net>
interface       //    www.jps.net/gfody
                //
uses FastRGB,   //    please contribute to the collection of
     Windows;   //    effects and filters. optimizations are
                //    always welcome!

//  Contributors:
//
//  Vit Kovalcik <vkovalcik@iname.com>
//   -Optimized everything
//   -InterpolateRect
//   -Emboss
//   -Mosaic
//   -Check out UniDib for 4,8,16,24,32 bit dibs!
//   -www.fi.muni.cz/~xkovalc
//
//  Armindo Da Silva <armindo.da-silva@wanadoo.fr>
//   -Spray, SmoothRotate
//
//  Andreas Goransson <andreas.goransson@epk.ericsson.se>
//   -Added some optimizations here an there
//   -Invert
//
//  Earl F. Glynn <earlglynn@att.net>
//   -Computer lab: www.infomaster.net/external/efg/
//
//  Harm <harmans@uswest.net>
//   -SmoothRotateWrap
//   -Fisheye
//   -Twist
//
//  Vedran Rodic <vrodic@udig.hr>
//   -Sharpen Filter
//

procedure RGB(Bmp:TFastRGB;ra,ga,ba:Integer);
procedure Contrast(Bmp:TFastRGB;Amount:Integer);
procedure Saturation(Bmp:TFastRGB;Amount:Integer); //optimized?
procedure Lightness(Bmp:TFastRGB;Amount:Integer);
procedure Grayscale(Bmp:TFastRGB);
procedure Invert(Bmp:TFastRGB);
procedure AlphaBlend(Bm1,Bm2,Bm3:TFastRGB;Alpha:Integer);
procedure Flip(Bmp:TFastRGB);
procedure Flop(Bmp:TFastRGB);
procedure AddColorNoise(Bmp:TFastRGB;Amount:Integer);
procedure AddMonoNoise(Bmp:TFastRGB;Amount:Integer);
procedure SplitBlur(Bmp:TFastRGB;Amount:Integer);
procedure GaussianBlur(Bmp:TFastRGB;Amount:Integer);
procedure Sharpen(Bmp:TFastRGB;Amount:Integer);
procedure SharpenMore(Bmp:TFastRGB;Amount:Integer);
procedure HShift(Bmp:TFastRGB;Amount:Integer);
procedure VShift(Bmp:TFastRGB;Amount:Integer);
procedure Spray(Bmp,Dst:TFastRGB;Amount:Integer);
procedure Emboss(Bmp:TFastRGB);
procedure Wave(Bmp,Dst:TFastRGB;XDIV,YDIV,RatioVal:Extended);
procedure WaveWrap(Bmp,Dst:TFastRGB;XDIV,YDIV,RatioVal:Extended);
procedure InterpolateRect(Bmp:TFastRGB;x1,y1,x2,y2:Integer;c00,c10,c01,c11:TFColor);
procedure Mosaic(Bmp:TFastRGB;xAmount,yAmount:Integer);
procedure RotateSize(var w,h:Integer;Angle:Extended);
procedure Rotate(Bmp,Dst:TFastRGB;cx,cy:Integer;Angle:Double);
procedure SmoothRotate(Bmp,Dst:TFastRGB;cx,cy:Integer;Angle:Extended);
// the rotatewrap functions are faster, but clip corners - good for animations
procedure RotateWrap(Bmp,Dst:TFastRGB;cx,cy:Integer;Angle:Double);
procedure SmoothRotateWrap(Bmp,Dst:TFastRGB;cx,cy:Integer;Degree:Extended);
procedure FishEye(Bmp,Dst:TFastRGB;Amount:Extended);
// amount should be like 300
procedure Twist(Bmp,Dst:TFastRGB;Amount:Integer);

implementation

procedure RGB(Bmp:TFastRGB;ra,ga,ba:Integer);
var
Table: array[0..255]of TFColor;
x,y,i: Integer;
Tmp:   PFColor;
begin
  for i:=0 to 255 do
  begin
    Table[i].b:=IntToByte(i+ba);
    Table[i].g:=IntToByte(i+ga);
    Table[i].r:=IntToByte(i+ra);
  end;
  Tmp:=Bmp.Bits;
  for y:=0 to Bmp.Height-1 do
  begin
    for x:=0 to Bmp.Width-1 do
    begin
      Tmp.b:=Table[Tmp.b].b;
      Tmp.g:=Table[Tmp.g].g;
      Tmp.r:=Table[Tmp.r].r;
      Inc(Tmp);
    end;
    Tmp:=Ptr(Integer(Tmp)+Bmp.Gap);
  end;
end;

procedure Contrast(Bmp:TFastRGB;Amount:Integer);
var
x,y:   Integer;
Table: array[0..255] of Byte;
Tmp:   PFColor;
begin
  for x:=0 to 126 do
  begin
    y:=(Abs(128-x)*Amount)div 256;
    y:=x-y;
    Table[x]:=IntToByte(y);
  end;
  for x:=127 to 255 do
  begin
    y:=(Abs(128-x)*Amount)div 256;
    y:=x+y;
    Table[x]:=IntToByte(y);
  end;
  Tmp:=Bmp.Bits;
  for y:=1 to Bmp.Height do
  begin
    for x:=1 to Bmp.Width do
    begin
      Tmp.b:=Table[Tmp.b];
      Tmp.g:=Table[Tmp.g];
      Tmp.r:=Table[Tmp.r];
      Inc(Tmp);
    end;
    Tmp:=Ptr(Integer(Tmp)+Bmp.Gap);
  end;
end;

procedure Saturation(Bmp:TFastRGB;Amount:Integer);
var
Grays:  array[0..767]of Integer;
Alpha:  array[0..255]of Word;
Gray,
x,y:    Integer;
pc:     PFColor;
begin
  for x:=0 to 255 do
    Alpha[x]:=(x*Amount)shr 8;
  x:=0;
  for y:=0 to 255 do
  begin
    Gray:=y-Alpha[y];
    Grays[x+0]:=Gray;
    Grays[x+1]:=Gray;
    Grays[x+2]:=Gray;
    Inc(x,3);
  end;
  pc:=Bmp.Bits;
  for y:=0 to Bmp.Height-1 do
  begin
    for x:=0 to Bmp.Width-1 do
    begin
      Gray:=Grays[pc.r+pc.g+pc.b];
      pc.b:=IntToByte(Gray+Alpha[pc.b]);
      pc.g:=IntToByte(Gray+Alpha[pc.g]);
      pc.r:=IntToByte(Gray+Alpha[pc.r]);
      Inc(pc);
    end;
    pc:=Ptr(Integer(pc)+Bmp.Gap);
  end;
end;

procedure Lightness(Bmp:TFastRGB;Amount:Integer);
var
x,y:   Integer;
Table: array[0..255]of Byte;
Tmp:   PFColor;
begin
  if Amount>0 then
  for x:=0 to 255 do
    Table[x]:=IntToByte(x+((Amount*(x xor 255))shr 8))
  else
  for x:=0 to 255 do
    Table[x]:=IntToByte(x-((Abs(Amount)*x)shr 8));
  Tmp:=Bmp.Bits;
  for y:=1 to Bmp.Height do
  begin
    for x:=1 to Bmp.Width do
    begin
      Tmp.b:=Table[Tmp.b];
      Tmp.g:=Table[Tmp.g];
      Tmp.r:=Table[Tmp.r];
      Inc(Tmp);
    end;
    Tmp:=Ptr(Integer(Tmp)+Bmp.Gap);
  end;
end;

procedure Grayscale(Bmp:TFastRGB);
var
Grays: array[0..756]of Byte;
i,x,y: Integer;
g:     Byte;
Tmp:   PFColor;
begin
  x:=0; y:=0;
  for i:=0 to 255 do
  begin
    Grays[x+0]:=y;
    Grays[x+1]:=y;
    Grays[x+2]:=y;
    Inc(y);
    Inc(x,3);
  end;
  Tmp:=Bmp.Bits;
  for y:=0 to Bmp.Height-1 do
  begin
    for x:=0 to Bmp.Width-1 do
    begin
      g:=Grays[Tmp.b+Tmp.g+Tmp.r];
      Tmp.b:=g;
      Tmp.g:=g;
      Tmp.r:=g;
      Inc(Tmp);
    end;
    Tmp:=Ptr(Integer(Tmp)+Bmp.Gap);
  end;
end;

procedure Invert(Bmp:TFastRGB);
var
x,y: Integer;
Tmp: PFColor;
begin
  Tmp:=Bmp.Bits;
  for y:=0 to Bmp.Height-1 do
  begin
    for x:=0 to Bmp.Width-1 do
    begin
      Tmp.b:=Tmp.b xor 255;
      Tmp.g:=Tmp.g xor 255;
      Tmp.r:=Tmp.r xor 255;
      Inc(Tmp);
    end;
    Tmp:=Ptr(Integer(Tmp)+Bmp.Gap);
  end;
end;

procedure AlphaBlend(Bm1,Bm2,Bm3:TFastRGB;Alpha:Integer);
var
x,y,i:    Integer;
c1,c2,c3: PFColor;
Table:    array[-255..255]of Integer;
begin
  for i:=-255 to 255 do
  Table[i]:=(Alpha*i)shr 8;
  c1:=Bm1.Bits;
  c2:=Bm2.Bits;
  c3:=Bm3.Bits;
  for y:=0 to Bm1.Height-1 do
  begin
    for x:=0 to Bm1.Width-1 do
    begin
      c1.b:=Table[c2.b-c3.b]+c3.b;
      c1.g:=Table[c2.g-c3.g]+c3.g;
      c1.r:=Table[c2.r-c3.r]+c3.r;
      Inc(c1);
      Inc(c2);
      Inc(c3);
    end;
    c1:=Ptr(Integer(c1)+Bm1.Gap);
    c2:=Ptr(Integer(c2)+Bm2.Gap);
    c3:=Ptr(Integer(c3)+Bm3.Gap);
  end;
end;

procedure Flip(Bmp:TFastRGB);
var
{p,}w,
x,y:  Integer;
Tmp:  TFColor;
Line: PLine;
begin
  w:=Bmp.Width-1;
  Line:=Bmp.Bits;
  for y:=0 to Bmp.Height-1 do
  begin
    for x:=0 to w div 2 do
    begin
      Tmp:=Line[x];
      Line[x]:=Line[w-x];
      Line[w-x]:=Tmp;
    end;
    Line:=Ptr(Integer(Line)+Bmp.RowInc);
  end;
end;

procedure Flop(Bmp:TFastRGB);
var
y,h:   Integer;
p1,p2,
Line:  PLine;
begin
  GetMem(Line,Bmp.Width*3);
  h:=Bmp.Height-1;
  p1:=Bmp.Bits;
  p2:=Bmp.Pixels[Bmp.Height-1];
  for y:=0 to h div 2 do
  begin
    CopyMemory(Line,p1,Bmp.Width*3);
    CopyMemory(p1,p2,Bmp.Width*3);
    CopyMemory(p2,Line,Bmp.Width*3);
    p1:=Ptr(Integer(p1)+Bmp.RowInc);
    p2:=Ptr(Integer(p2)-Bmp.RowInc);
  end;
  FreeMem(Line);
end;

procedure AddColorNoise(Bmp:TFastRGB;Amount:Integer);
var
x,y,
r,g,b: Integer;
Tmp:   TFColor;
pc:    PFColor;
begin
  pc:=Bmp.Bits;
  for y:=0 to Bmp.Height-1 do
  begin
    for x:=0 to Bmp.Width-1 do
    begin
      Tmp:=pc^;
      b:=Tmp.b+(Random(Amount)-(Amount shr 1));
      g:=Tmp.g+(Random(Amount)-(Amount shr 1));
      r:=Tmp.r+(Random(Amount)-(Amount shr 1));
      Tmp.b:=IntToByte(b);
      Tmp.g:=IntToByte(g);
      Tmp.r:=IntToByte(r);
      pc^:=Tmp;
      Inc(pc);
    end;
    pc:=Ptr(Integer(pc)+Bmp.Gap);
  end;
end;

procedure AddMonoNoise(Bmp:TFastRGB;Amount:Integer);
var
x,y,a,
r,g,b: Integer;
Tmp:   TFColor;
pc:    PFColor;
begin
  pc:=Bmp.Bits;
  for y:=0 to Bmp.Height-1 do
  begin
    for x:=0 to Bmp.Width-1 do
    begin
      Tmp:=pc^;
      a:=Random(Amount)-(Amount shr 1);
      b:=Tmp.b+a;
      g:=Tmp.g+a;
      r:=Tmp.r+a;
      Tmp.b:=IntToByte(b);
      Tmp.g:=IntToByte(g);
      Tmp.r:=IntToByte(r);
      pc^:=Tmp;
      Inc(pc);
    end;
    pc:=Ptr(Integer(pc)+Bmp.Gap);
  end;
end;

procedure SplitBlur(Bmp:TFastRGB;Amount:Integer);
var
Lin1,
Lin2:   PLine;
pc:     PFColor;
cx,x,y: Integer;
Buf:    array[0..3]of TFColor;
begin
  pc:=Bmp.Bits;
  for y:=0 to Bmp.Height-1 do
  begin
    Lin1:=Bmp.Pixels[TrimInt(y+Amount,0,Bmp.Height-1)];
    Lin2:=Bmp.Pixels[TrimInt(y-Amount,0,Bmp.Height-1)];
    for x:=0 to Bmp.Width-1 do
    begin
      cx:=TrimInt(x+Amount,0,Bmp.Width-1);
      Buf[0]:=Lin1[cx];
      Buf[1]:=Lin2[cx];
      cx:=TrimInt(x-Amount,0,Bmp.Width-1);
      Buf[2]:=Lin1[cx];
      Buf[3]:=Lin2[cx];
      pc.b:=(Buf[0].b+Buf[1].b+Buf[2].b+Buf[3].b)shr 2;
      pc.g:=(Buf[0].g+Buf[1].g+Buf[2].g+Buf[3].g)shr 2;
      pc.r:=(Buf[0].r+Buf[1].r+Buf[2].r+Buf[3].r)shr 2;
      Inc(pc);
    end;
    pc:=Ptr(Integer(pc)+Bmp.Gap);
  end;
end;

procedure GaussianBlur(Bmp:TFastRGB;Amount:Integer);
var
i: Integer;
begin
  for i:=Amount downto 1 do
  SplitBlur(Bmp,i);
end;

procedure Sharpen(Bmp:TFastRGB;Amount:Integer);
var
Lin0,
Lin1,
Lin2:   PLine;
pc:     PFColor;
cx,x,y: Integer;
Buf:    array[0..8]of TFColor;
begin
  pc:=Bmp.Bits;
  for y:=0 to Bmp.Height-1 do
  begin
    Lin0:=Bmp.Pixels[TrimInt(y-Amount,0,Bmp.Height-1)];
    Lin1:=Bmp.Pixels[y];
    Lin2:=Bmp.Pixels[TrimInt(y+Amount,0,Bmp.Height-1)];
    for x:=0 to Bmp.Width-1 do
    begin
      cx:=TrimInt(x-Amount,0,Bmp.Width-1);
      Buf[0]:=Lin0[cx];
      Buf[1]:=Lin1[cx];
      Buf[2]:=Lin2[cx];
      Buf[3]:=Lin0[x];
      Buf[4]:=Lin1[x];
      Buf[5]:=Lin2[x];
      cx:=TrimInt(x+Amount,0,Bmp.Width-1);
      Buf[6]:=Lin0[cx];
      Buf[7]:=Lin1[cx];
      Buf[8]:=Lin2[cx];
      pc.b:=IntToByte(
              (256*Buf[4].b-(Buf[0].b+Buf[1].b+Buf[2].b+Buf[3].b+
               Buf[5].b+Buf[6].b+Buf[7].b+Buf[8].b)*16)div 128);
      pc.g:=IntToByte(
              (256*Buf[4].g-(Buf[0].g+Buf[1].g+Buf[2].g+Buf[3].g+
               Buf[5].g+Buf[6].g+Buf[7].g+Buf[8].g)*16)div 128);
      pc.r:=IntToByte(
              (256*Buf[4].r-(Buf[0].r+Buf[1].r+Buf[2].r+Buf[3].r+
               Buf[5].r+Buf[6].r+Buf[7].r+Buf[8].r)*16)div 128);
      Inc(pc);
    end;
    pc:=Ptr(Integer(pc)+Bmp.Gap);
  end;
end;

procedure SharpenMore(Bmp:TFastRGB;Amount:Integer);
var
i: Integer;
begin
  for i:=Amount downto 1 do
  Sharpen(Bmp,i);
end;

procedure VShift(Bmp:TFastRGB;Amount:Integer);
var
p,Line: PLine;
y:      Integer;
begin
  if Amount<0 then Amount:=Bmp.Width-(Abs(Amount) mod Bmp.Width);
  if Amount>Bmp.Width then Amount:=Amount mod Bmp.Width;
  if Amount=0 then Exit;
  GetMem(Line,Amount*3);
  p:=Bmp.Bits;
  for y:=0 to Bmp.Height-1 do
  begin
    CopyMemory(Line,Ptr(Integer(p)+((Bmp.Width-Amount)*3)),Amount*3);
    MoveMemory(Ptr(Integer(p)+(Amount*3)),p,(Bmp.Width-Amount)*3);
    CopyMemory(p,Line,Amount*3);
    p:=Ptr(Integer(p)+Bmp.RowInc);
  end;
  FreeMem(Line);
end;

procedure HShift(Bmp:TFastRGB;Amount:Integer);
var
Buff: Pointer;
p,y:  Integer;
begin
  if Amount<0 then Amount:=Bmp.Height-(Abs(Amount) mod Bmp.Height);
  if Amount>Bmp.Height then Amount:=Amount mod Bmp.Height;
  if Amount=0 then Exit;
  p:=Integer(Bmp.Bits)+(Bmp.Height*(Bmp.Gap))+((Bmp.Height*Bmp.Width)*3);
  p:=p-Integer(Bmp.Pixels[Amount]);
  y:=Integer(Bmp.Pixels[Amount])-Integer(Bmp.Bits);
  GetMem(Buff,y);
  CopyMemory(Buff,Bmp.Pixels[Bmp.Height-Amount],y);
  MoveMemory(Bmp.Pixels[Amount],Bmp.Bits,p);
  CopyMemory(Bmp.Bits,Buff,y);
  FreeMem(Buff);
end;

procedure Spray(Bmp,Dst:TFastRGB;Amount:Integer);
var
r,x,y: Integer;
begin
  for y:=0 to Bmp.Height-1 do
  for x:=0 to Bmp.Width-1 do
  begin
    r:=Random(Amount);
    Dst.Pixels[y,x]:=
    Bmp.Pixels[
      TrimInt(y+(r-Random(r*2)),0,Bmp.Height-1),
      TrimInt(x+(r-Random(r*2)),0,Bmp.Width-1)];
  end;
end;

procedure Emboss(Bmp:TFastRGB);
var
x,y:   Integer;
p1,p2: PFColor;
Line:  PLine;
begin
  p1:=Bmp.Bits;
  p2:=Ptr(Integer(p1)+Bmp.RowInc+3);
  GetMem(Line,Bmp.Width*3);
  CopyMemory(Line,Bmp.Pixels[Bmp.Height-1],Bmp.Width*3);
  for y:=0 to Bmp.Height-1 do
  begin
    for x:=0 to Bmp.Width-1 do
    begin
      p1.b:=(p1.b+(p2.b xor $FF))shr 1;
      p1.g:=(p1.g+(p2.g xor $FF))shr 1;
      p1.r:=(p1.r+(p2.r xor $FF))shr 1;
      Inc(p1);
      if(y<Bmp.Height-2)and(x<Bmp.Width-2)then Inc(p2);
    end;
    p1:=Ptr(Integer(p1)+Bmp.Gap);
    if y<Bmp.Height-2 then p2:=Ptr(Integer(p2)+Bmp.Gap+6)
    else p2:=Ptr(Integer(Line)+3);
  end;
  FreeMem(Line);
end;

procedure Wave(Bmp,Dst:TFastRGB;XDIV,YDIV,RatioVal:Extended);
type
TArray=array[0..0]of Integer;
PArray=^TArray;
var
i,j,{x,y,
Val,}XSrc,
YSrc:    Integer;
st:      PArray;
Pix:     PFColor;
Line:    PLine;
begin
  if(YDiv=0)or(XDiv=0)then
  begin
    CopyMemory(Dst.Bits,Bmp.Bits,Dst.Size);
    Exit;
  end;
  GetMem(st,4*Dst.Height);
  for j:=0 to Dst.Height-1 do
    st[j]:=Round(RatioVal*Sin(j/YDiv));
  for i:=0 to Dst.Width-1 do
  begin
    YSrc:=Round(RatioVal*Sin(i/XDiv));
    Pix:=Ptr(Integer(Dst.Bits)+i*3);
    if(YSrc>=0)and(YSrc<Bmp.Height)then Line:=Bmp.Pixels[YSrc];
    for j:=0 to Dst.Height-1 do
    begin
      if(YSrc>=Bmp.Height)then Break;
      XSrc:=i+st[j];
      if(XSrc>-1)and(XSrc<Bmp.Width)and(YSrc>-1)then
        Pix^:=Line^[XSrc]
      else
        if YSrc=-1 then
        begin
          Pix:=Ptr(Integer(Pix)+Dst.RowInc);
          Line:=Bmp.Bits;
          YSrc:=0;
          Continue;
        end;
      Pix:=Ptr(Integer(Pix)+Dst.RowInc);
      Line:=Ptr(Integer(Line)+Bmp.RowInc);
      Inc(YSrc);
    end;
  end;
  FreeMem(st);
end;

procedure WaveWrap(Bmp,Dst:TFastRGB;XDIV,YDIV,RatioVal:Extended);
type
TArray=array[0..0] of Integer;
PArray=^TArray;
var
i,j,{x,y,
Val,}XSrc,
YSrc:    Integer;
st:      PArray;
Pix:     PFColor;
Line:    PLine;
Max:     Integer;
PInt:    PInteger;
begin
  if(YDiv=0)or(XDiv=0)then
  begin
    CopyMemory(Dst.Bits,Bmp.Bits,Dst.Size);
    Exit;
  end;
  GetMem(st,4*Dst.Height);
  for j:=0 to Dst.Height-1 do
    st[j]:=Round(RatioVal*Sin(j/YDiv));
  Max:=Integer(Bmp.Pixels[Bmp.Height-1])+Bmp.RowInc;
  for i:=0 to Dst.Width-1 do
  begin
    YSrc:=Round(RatioVal*sin(i/XDiv));
    if YSrc<0 then
      YSrc:=Bmp.Height-1-(-YSrc mod Bmp.Height)
    else
      if YSrc>=Bmp.Height then
        YSrc:=YSrc mod(Bmp.Height-1);
    Pix:=Ptr(Integer(Dst.Bits)+i*3);
    Line:=Bmp.Pixels[YSrc];
    PInt:=PInteger(st);
    for j:=Dst.Height-1 downto 0 do
    begin
      XSrc:=i+PInt^;
      Inc(PInt);
      if XSrc<0 then
        XSrc:=Bmp.Width-1-(-XSrc mod Bmp.Width)
      else
        if XSrc>=Bmp.Width then
          XSrc:=XSrc mod Bmp.Width;
      Pix^:=Line[XSrc];
      Pix:=Ptr(Integer(Pix)+Dst.RowInc);
      Line:=Ptr(Integer(Line)+Bmp.RowInc);
      if Integer(Line)>=Max then Line:=Bmp.Bits;
    end;
  end;
  FreeMem(st);
end;

procedure InterpolateRect(Bmp:TFastRGB;x1,y1,x2,y2:Integer;c00,c10,c01,c11:TFColor);
// Draws rectangle, which will have different color in each corner and
// will blend from one color to another
// ( c[0,0]    c[1,0]
//   c[0,1]    c[1,1] )
var
  xCount,yCount,
  t,t2,z,iz,
  rp,rp2,gp,
  gp2,bp,bp2,
  xx,dx:     Integer;
  pb:        PByte;
begin
  If x2<x1 then
  begin
    t:=x2;
    x2:=x1;
    x1:=t;
  end;
  if y2<y1 then
  begin
    t:=y2;
    y2:=y1;
    y1:=t;
  end;
  if(x1<0)or(y1<0)or(x2>Bmp.Width-1)or(y2>Bmp.Height-1)then Exit;
  z:=0;
  iz:=$100000;
  if x2<>x1 then t:=$100000 div (x2-x1);
  if y2<>y1 then t2:=$100000 div (y2-y1);
  dx:=x2-x1;
  for yCount:=y1 to y2 do
  begin
    xx:=((c00.r*iz+c01.r*z) shr 20);
    rp:=xx shl 20;
    rp2:=(((c10.r*iz+c11.r*z) shr 20)-xx)*t;
    xx:=((c00.g*iz+c01.g*z) shr 20);
    gp:=xx shl 20;
    gp2:=(((c10.g*iz+c11.g*z) shr 20)-xx)*t;
    xx:=((c00.b*iz+c01.b*z) shr 20);
    bp:=xx shl 20;
    bp2:=(((c10.b*iz+c11.b*z) shr 20)-xx)*t;
    pb:=@Bmp.Pixels[yCount,x1];
    for xCount:=0 to dx do
    begin
      pb^:=bp shr 20;
      Inc (bp,bp2);
      PByte(Integer(pb)+1)^:=gp shr 20;
      Inc (gp,gp2);
      PByte(Integer(pb)+2)^:=rp shr 20;
      Inc (rp,rp2);
      Inc (pb,3);
    end;
    Inc (z,t2);
    Dec (iz,t2);
  end;
end;

procedure Mosaic(Bmp:TFastRGB;xAmount,yAmount:Integer);
var
Delta,
tx,ty,
cx,cy,
ix,iy,
x,y:   Integer;
Col:   TFColor;
Pix:   PFColor;
Line:  PLine;
begin
  if(xAmount<1)or(yAmount<1)then Exit;
  ix:=(xAmount shr 1)+(xAmount and 1);
  iy:=(yAmount shr 1)+(yAmount and 1);
  y:=0;
  while y<Bmp.Height do
  begin
    x:=0;
    cy:=y+iy;
    if cy>=Bmp.Height then
      Line:=Bmp.Pixels[Bmp.Height-1]
    else
      Line:=Bmp.Pixels[cy];
    if y+yAmount-1>=Bmp.Height then
      ty:=Bmp.Height-1-y
    else
      ty:=yAmount;
    while x<Bmp.Width do
    begin
      cx:=x+ix;
      if cx>=Bmp.Width then
        Col:=Line[Bmp.Width-1]
      else
        Col:=Line[cx];
      if x+xAmount-1>=Bmp.Width then
        tx:=Bmp.Width-1-x
      else
        tx:=xAmount;
      Delta:=Bmp.RowInc-tx*3;
      Pix:=Ptr(Integer(Bmp.Pixels[y])+x*3);
      for cy:=1 to ty do
      begin
        for cx:=1 to tx do
        begin
          Pix^:=Col;
          Inc (Pix);
        end;
        Pix:=Ptr(Integer(Pix)+Delta);
      end;
      Inc (x,xAmount);
    end;
    Inc (y,yAmount);
  end;
end;

procedure RotateSize(var w,h:Integer;Angle:Extended);
var
Theta: Extended;
tw,th: Integer;
begin
  tw:=w; th:=h;
  Theta:=Abs(Angle)*(Pi/180);
  w:=Round(
     Abs(tw * Cos(Theta)) +
     Abs(th * Sin(Theta)));
  h:=Round(
     Abs(tw * Sin(Theta)) +
     Abs(th * Cos(Theta)));
end;

procedure Rotate(Bmp,Dst:TFastRGB;cx,cy:Integer;Angle:Double);
var
x,y,
dx,dy,
sdx,sdy,
xDiff,yDiff,
isinTheta,
icosTheta: Integer;
Tmp:       PFColor;
sinTheta,
cosTheta,
Theta:     Double;
begin

  Theta:=-Angle*Pi/180;
  sinTheta:=Sin(Theta);
  cosTheta:=Cos(Theta);
  xDiff:=(Dst.Width-Bmp.Width)div 2;
  yDiff:=(Dst.Height-Bmp.Height)div 2;
  isinTheta:=Round(sinTheta*$10000);
  icosTheta:=Round(cosTheta*$10000);

  Tmp:=Dst.Bits;
  for y:=0 to Dst.Height-1 do
  begin
    sdx:=Round(((cx+(-cx)*cosTheta-(y-cy)*sinTheta)-xDiff)*$10000);
    sdy:=Round(((cy+(-cx)*sinTheta+(y-cy)*cosTheta)-yDiff)*$10000);
    for x:=0 to Dst.Width-1 do
    begin
      dx:=(sdx shr 16);
      dy:=(sdy shr 16);
      if(dx>-1)and(dx<Bmp.Width)and(dy>-1)and(dy<Bmp.Height)then
      Tmp^:=Bmp.Pixels[dy,dx];
      Inc(sdx,icosTheta);
      Inc(sdy,isinTheta);
      Inc(Tmp);
    end;
    Tmp:=Ptr(Integer(Tmp)+Dst.Gap);
  end;
end;

procedure RotateWrap(Bmp,Dst:TFastRGB;cx,cy:Integer;Angle:Double);
var
x,y,
dx,dy,
sdx,sdy,
xDiff,yDiff,
isinTheta,
icosTheta: Integer;
Tmp:       PFColor;
sinTheta,
cosTheta,
Theta:     Double;
begin
  Theta:=-Angle*Pi/180;
  sinTheta:=Sin(Theta);
  cosTheta:=Cos(Theta);
  xDiff:=(Dst.Width-Bmp.Width)div 2;
  yDiff:=(Dst.Height-Bmp.Height)div 2;
  isinTheta:=Round(sinTheta*$10000);
  icosTheta:=Round(cosTheta*$10000);
  Tmp:=Dst.Bits;
  for y:=0 to Dst.Height-1 do
  begin
    sdx:=Round(((cx+(-cx)*cosTheta-(y-cy)*sinTheta)-xDiff)*$10000);
    sdy:=Round(((cy+(-cx)*sinTheta+(y-cy)*cosTheta)-yDiff)*$10000);
    for x:=0 to Dst.Width-1 do
    begin
      if sdx<0 then dx:=Bmp.Width-1-(((-sdx)shr 16)mod Bmp.Width)
      else begin
        dx:=sdx shr 16;
        if dx>Bmp.Width-1 then dx:=dx mod Bmp.Width;
      end;
      Inc(sdx,icosTheta);
      if sdy<0 then dy:=Bmp.Height-1-(((-sdy)shr 16)mod Bmp.Height)
      else begin
        dy:=sdy shr 16;
        if dy>Bmp.Height-1 then dy:=dy mod Bmp.Height;
      end;
      Inc(sdy,isinTheta);
      Tmp^:=Bmp.Pixels[dy,dx];
      Inc(Tmp);
    end;
    Tmp:=Ptr(Integer(Tmp)+Dst.Gap);
  end;
end;

procedure SmoothRotate(Bmp,Dst:TFastRGB;cx,cy:Integer;Angle:Extended);
var
Top,
Bottom,
Left,
Right,
eww,nsw,
fx,fy,
wx,wy:    Extended;
cAngle,
sAngle:   Double;
xDiff,
yDiff,
ifx,ify,
px,py,
ix,iy,
x,y:      Integer;
nw,ne,
sw,se:    TFColor;
Tmp:      PFColor;
begin
  Angle:=-Angle*Pi/180;
  sAngle:=Sin(Angle);
  cAngle:=Cos(Angle);
  xDiff:=(Dst.Width-Bmp.Width)div 2;
  yDiff:=(Dst.Height-Bmp.Height)div 2;
  Tmp:=Dst.Bits;
  for y:=0 to Dst.Height-1 do
  begin
    py:=2*(y-cy)+1;
    for x:=0 to Dst.Width-1 do
    begin
      px:=2*(x-cx)+1;
      fx:=(((px*cAngle-py*sAngle)-1)/ 2+cx)-xDiff;
      fy:=(((px*sAngle+py*cAngle)-1)/ 2+cy)-yDiff;
      ifx:=Round(fx);
      ify:=Round(fy);

      if(ifx>-1)and(ifx<Bmp.Width)and(ify>-1)and(ify<Bmp.Height)then
      begin
        eww:=fx-ifx;
        nsw:=fy-ify;
        iy:=TrimInt(ify+1,0,Bmp.Height-1);
        ix:=TrimInt(ifx+1,0,Bmp.Width-1);
        nw:=Bmp.Pixels[ify,ifx];
        ne:=Bmp.Pixels[ify,ix];
        sw:=Bmp.Pixels[iy,ifx];
        se:=Bmp.Pixels[iy,ix];

        Top:=nw.b+eww*(ne.b-nw.b);
        Bottom:=sw.b+eww*(se.b-sw.b);
        Tmp.b:=IntToByte(Round(Top+nsw*(Bottom-Top)));

        Top:=nw.g+eww*(ne.g-nw.g);
        Bottom:=sw.g+eww*(se.g-sw.g);
        Tmp.g:=IntToByte(Round(Top+nsw*(Bottom-Top)));

        Top:=nw.r+eww*(ne.r-nw.r);
        Bottom:=sw.r+eww*(se.r-sw.r);
        Tmp.r:=IntToByte(Round(Top+nsw*(Bottom-Top)));
      end;
      Inc(Tmp);
    end;
    Tmp:=Ptr(Integer(Tmp)+Dst.Gap);
  end;
end;

procedure SmoothRotateWrap(Bmp,Dst:TFastRGB;cx,cy:Integer;Degree:Extended);
var
  Theta, cosTheta, sinTheta: Single;
    sfrom_y, sfrom_x       : Single; //Real number
    ifrom_y, ifrom_x       : Integer; //Integer version
    xDiff,yDiff:             Integer;
    to_y, to_x             : Integer;
    weight_x, weight_y     : array[0..1] of Single;
    weight                 : Single;
    new_red, new_green     : Integer;
    new_blue               : Integer;
    total_red, total_green : Single;
    total_blue             : Single;
    ix, iy                 : Integer;
    sli, slo : PLine;
begin
    // Calculate the sine and cosine of theta for later.
  Theta:=-Degree*Pi/180;
  sinTheta:=Sin(Theta);
  cosTheta:=Cos(Theta);
  xDiff:=(Dst.Width-Bmp.Width)div 2;
  yDiff:=(Dst.Height-Bmp.Height)div 2;

    // Perform the rotation.
  for to_y := 0 to Dst.Height-1 do begin
    for to_x := 0 to Dst.Width-1 do begin
            // Find the location (from_x, from_y) that
            // rotates to position (to_x, to_y).
      sfrom_x := (cx +
          (to_x - cx) * cosTheta -
          (to_y - cy) * sinTheta)-xDiff;
      ifrom_x := Trunc(sfrom_x);

      sfrom_y := (cy +
          (to_x - cx) * sinTheta +
          (to_y - cy) * cosTheta)-yDiff;
      ifrom_y := Trunc(sfrom_y);

                // Calculate the weights.
      if sfrom_y >= 0  then begin
        weight_y[1] := sfrom_y - ifrom_y;
        weight_y[0] := 1 - weight_y[1];
      end else begin
        weight_y[0] := -(sfrom_y - ifrom_y);
        weight_y[1] := 1 - weight_y[0];
      end;
      if sfrom_x >= 0 then begin
        weight_x[1] := sfrom_x - ifrom_x;
        weight_x[0] := 1 - weight_x[1];
      end else begin
        weight_x[0] := -(sfrom_x - ifrom_x);
        Weight_x[1] := 1 - weight_x[0];
      end;

      if      ifrom_x<0        then ifrom_x:=Bmp.Width-1-(-ifrom_x mod Bmp.Width)
      else if ifrom_x>Bmp.Width-1  then ifrom_x:=ifrom_x mod Bmp.Width;
      if      ifrom_y<0        then ifrom_y:=Bmp.Height-1-(-ifrom_y mod Bmp.Height)
      else if ifrom_y>Bmp.Height-1 then ifrom_y:=ifrom_y mod Bmp.Height;

                // Average the color components of the four
                // nearest pixels in from_canvas.
      total_red   := 0.0;
      total_green := 0.0;
      total_blue  := 0.0;
      for ix := 0 to 1 do
      begin
        for iy := 0 to 1 do
        begin
          if ifrom_y + iy < Bmp.Height then
            sli := Bmp.Pixels[ifrom_y + iy]
          else
            sli := Bmp.Pixels[Bmp.Height - ifrom_y - iy];
          if ifrom_x + ix < Bmp.Width then begin
            new_red := sli^[ifrom_x + ix].r;
            new_green := sli^[ifrom_x + ix].g;
            new_blue := sli^[ifrom_x + ix].b;
          end
          else begin
            new_red := sli^[Bmp.Width - ifrom_x - ix].r;
            new_green := sli^[Bmp.Width - ifrom_x - ix].g;
            new_blue := sli^[Bmp.Width - ifrom_x - ix].b;
          end;
          weight := weight_x[ix] * weight_y[iy];
          total_red   := total_red   + new_red   * weight;
          total_green := total_green + new_green * weight;
          total_blue  := total_blue  + new_blue  * weight;
        end;
      end;
      slo := Dst.Pixels[to_y];
      slo^[to_x].r := Round(total_red);
      slo^[to_x].g := Round(total_green);
      slo^[to_x].b := Round(total_blue);
    end;
  end;
end;

procedure FishEye(Bmp,Dst:TFastRGB;Amount:Extended);
var
xmid,ymid              : Single;
fx,fy                  : Single;
r1, r2                 : Single;
ifx, ify               : integer;
dx, dy                 : Single;
rmax                   : Single;
ty, tx                 : Integer;
weight_x, weight_y     : array[0..1] of Single;
weight                 : Single;
new_red, new_green     : Integer;
new_blue               : Integer;
total_red, total_green : Single;
total_blue             : Single;
ix, iy                 : Integer;
sli, slo : PLine;
begin
  xmid := Bmp.Width/2;
  ymid := Bmp.Height/2;
  rmax := Dst.Width * Amount;

  for ty := 0 to Dst.Height - 1 do begin
    for tx := 0 to Dst.Width - 1 do begin
      dx := tx - xmid;
      dy := ty - ymid;
      r1 := Sqrt(dx * dx + dy * dy);
      if r1 = 0 then begin
        fx := xmid;
        fy := ymid;
      end
      else begin
        r2 := rmax / 2 * (1 / (1 - r1/rmax) - 1);
        fx := dx * r2 / r1 + xmid;
        fy := dy * r2 / r1 + ymid;
      end;
      ify := Trunc(fy);
      ifx := Trunc(fx);
                // Calculate the weights.
      if fy >= 0  then begin
        weight_y[1] := fy - ify;
        weight_y[0] := 1 - weight_y[1];
      end else begin
        weight_y[0] := -(fy - ify);
        weight_y[1] := 1 - weight_y[0];
      end;
      if fx >= 0 then begin
        weight_x[1] := fx - ifx;
        weight_x[0] := 1 - weight_x[1];
      end else begin
        weight_x[0] := -(fx - ifx);
        Weight_x[1] := 1 - weight_x[0];
      end;

      if ifx < 0 then
        ifx := Bmp.Width-1-(-ifx mod Bmp.Width)
      else if ifx > Bmp.Width-1  then
        ifx := ifx mod Bmp.Width;
      if ify < 0 then
        ify := Bmp.Height-1-(-ify mod Bmp.Height)
      else if ify > Bmp.Height-1 then
        ify := ify mod Bmp.Height;

      total_red   := 0.0;
      total_green := 0.0;
      total_blue  := 0.0;
      for ix := 0 to 1 do begin
        for iy := 0 to 1 do begin
          if ify + iy < Bmp.Height then
            sli := Bmp.Pixels[ify + iy]
          else
            sli := Bmp.Pixels[Bmp.Height - ify - iy];
          if ifx + ix < Bmp.Width then begin
            new_red := sli^[ifx + ix].r;
            new_green := sli^[ifx + ix].g;
            new_blue := sli^[ifx + ix].b;
          end
          else begin
            new_red := sli^[Bmp.Width - ifx - ix].r;
            new_green := sli^[Bmp.Width - ifx - ix].g;
            new_blue := sli^[Bmp.Width - ifx - ix].b;
          end;
          weight := weight_x[ix] * weight_y[iy];
          total_red   := total_red   + new_red   * weight;
          total_green := total_green + new_green * weight;
          total_blue  := total_blue  + new_blue  * weight;
        end;
      end;
      slo := Dst.Pixels[ty];
      slo^[tx].r := Round(total_red);
      slo^[tx].g := Round(total_green);
      slo^[tx].b := Round(total_blue);

    end;
  end;
end;

procedure Twist(Bmp,Dst:TFastRGB;Amount:integer);
var
  fxmid, fymid : Single;
  txmid, tymid : Single;
  fx,fy : Single;
  tx2, ty2 : Single;
  r : Single;
  theta : Single;
  ifx, ify : integer;
  dx, dy : Single;
  OFFSET : Single;
  ty, tx             : Integer;
  weight_x, weight_y     : array[0..1] of Single;
  weight                 : Single;
  new_red, new_green     : Integer;
  new_blue               : Integer;
  total_red, total_green : Single;
  total_blue             : Single;
  ix, iy                 : Integer;
  sli, slo : PLine;

  function ArcTan2(xt,yt : Single): Single;
  begin
    if xt = 0 then
      if yt > 0 then
        Result := Pi/2
      else
        Result := -(Pi/2)
    else begin
      Result := ArcTan(yt/xt);
      if xt < 0 then
        Result := Pi + ArcTan(yt/xt);
    end;
  end;

begin
  OFFSET := -(Pi/2);
  dx := Bmp.Width - 1;
  dy := Bmp.Height - 1;
  r := Sqrt(dx * dx + dy * dy);
  tx2 := r;
  ty2 := r;
  txmid := (Bmp.Width-1)/2;    //Adjust these to move center of rotation
  tymid := (Bmp.Height-1)/2;   //Adjust these to move ......
  fxmid := (Bmp.Width-1)/2;
  fymid := (Bmp.Height-1)/2;
  if tx2 >= Bmp.Width then tx2 := Bmp.Width-1;
  if ty2 >= Bmp.Height then ty2 := Bmp.Height-1;

  for ty := 0 to Round(ty2) do begin
    for tx := 0 to Round(tx2) do begin
      dx := tx - txmid;
      dy := ty - tymid;
      r := Sqrt(dx * dx + dy * dy);
      if r = 0 then begin
        fx := 0;
        fy := 0;
      end
      else begin
        theta := ArcTan2(dx,dy) - r/Amount - OFFSET;
        fx := r * Cos(theta);
        fy := r * Sin(theta);
      end;
      fx := fx + fxmid;
      fy := fy + fymid;

      ify := Trunc(fy);
      ifx := Trunc(fx);
                // Calculate the weights.
      if fy >= 0  then begin
        weight_y[1] := fy - ify;
        weight_y[0] := 1 - weight_y[1];
      end else begin
        weight_y[0] := -(fy - ify);
        weight_y[1] := 1 - weight_y[0];
      end;
      if fx >= 0 then begin
        weight_x[1] := fx - ifx;
        weight_x[0] := 1 - weight_x[1];
      end else begin
        weight_x[0] := -(fx - ifx);
        Weight_x[1] := 1 - weight_x[0];
      end;

      if ifx < 0 then
        ifx := Bmp.Width-1-(-ifx mod Bmp.Width)
      else if ifx > Bmp.Width-1  then
        ifx := ifx mod Bmp.Width;
      if ify < 0 then
        ify := Bmp.Height-1-(-ify mod Bmp.Height)
      else if ify > Bmp.Height-1 then
        ify := ify mod Bmp.Height;

      total_red   := 0.0;
      total_green := 0.0;
      total_blue  := 0.0;
      for ix := 0 to 1 do begin
        for iy := 0 to 1 do begin
          if ify + iy < Bmp.Height then
            sli := Bmp.Pixels[ify + iy]
          else
            sli := Bmp.Pixels[Bmp.Height - ify - iy];
          if ifx + ix < Bmp.Width then begin
            new_red := sli^[ifx + ix].r;
            new_green := sli^[ifx + ix].g;
            new_blue := sli^[ifx + ix].b;
          end
          else begin
            new_red := sli^[Bmp.Width - ifx - ix].r;
            new_green := sli^[Bmp.Width - ifx - ix].g;
            new_blue := sli^[Bmp.Width - ifx - ix].b;
          end;
          weight := weight_x[ix] * weight_y[iy];
          total_red   := total_red   + new_red   * weight;
          total_green := total_green + new_green * weight;
          total_blue  := total_blue  + new_blue  * weight;
        end;
      end;
      slo := Dst.Pixels[ty];
      slo^[tx].r := Round(total_red);
      slo^[tx].g := Round(total_green);
      slo^[tx].b := Round(total_blue);
    end;
  end;
end;

end.
