unit FastDraw;
                  //FastDraw 2/28/99
interface         //  ported a lot from Menno Victor van der star's
                  //  old graphics unit. Frith's home page, and graphics
uses FastRGB,     //  gems books.  All functions assume safe coordinates.
     Windows;     //  www.jps.net/gfody
                  //                    - please help!! anyone!

procedure Circle(Bmp:TFastRGB;x,y,radius:Integer;clr:TFColor);
procedure Rectangle(Bmp:TFastRGB;x,y,w,h:Integer;clr:TFColor);
procedure FillRect(Bmp:TFastRGB;x,y,w,h:Integer;clr:TFColor);
procedure Ellipse(Bmp:TFastRGB;x,y,h,k:Integer;clr:TFColor);
procedure Line(Bmp:TFastRGB;x1,y1,x2,y2:Integer;clr:TFColor);
procedure BSpline(Bmp:TFastRGB;pnts:array of TPoint;Segments:Word;clr:TFColor);
procedure PolyLine(Bmp:TFastRGB;pnts:array of TPoint;clr:TFColor);
// fake anti-aliasing. uses precalculated colors passed as an array[0..255]
// use ColorFill to fill an array with the transition of the line color and
// the background color.
procedure ColorFill(var clr:array of TFColor;fc,bc:TFColor);
procedure FSmoothLine(Bmp:TFastRGB;x1,y1,x2,y2:Integer;clr:array of TFColor);
procedure FSmoothPolyLine(Bmp:TFastRGB;pnts:array of TPoint;clr:array of TFColor);

implementation

// the fastest circle algorithm in the world - Frith
procedure Circle(Bmp:TFastRGB;x,y,radius:Integer;clr:TFColor);
var
balance,
xoff,yoff: Integer;
begin
  xoff:=0;
  yoff:=radius;
  balance:=-radius;
  repeat
    Bmp.Pixels[y+yoff,x+xoff]:=clr;
    Bmp.Pixels[y+yoff,x-xoff]:=clr;
    Bmp.Pixels[y-yoff,x-xoff]:=clr;
    Bmp.Pixels[y-yoff,x+xoff]:=clr;
    Bmp.Pixels[y+xoff,x+yoff]:=clr;
    Bmp.Pixels[y+xoff,x-yoff]:=clr;
    Bmp.Pixels[y-xoff,x-yoff]:=clr;
    Bmp.Pixels[y-xoff,x+yoff]:=clr;
    Inc(xoff);
    Inc(balance,xoff);
    if balance >= 0 then
    begin
      Dec(balance,yoff);
      Dec(yoff);
    end;
  until xoff>=yoff;
end;

// assumes positive width and height, this is a bounding rectangle
procedure Rectangle(Bmp:TFastRGB;x,y,w,h:Integer;clr:TFColor);
var
Tmp: PFColor;
i:   Integer;
begin
  Tmp:=@Bmp.Pixels[y,x];
  for i:=1 to w-1 do
  begin
    Tmp^:=clr;
    Inc(Tmp);
  end;
  for i:=1 to h-1 do
  begin
    Tmp^:=clr;
    Tmp:=Ptr(Integer(Tmp)+Bmp.RowInc);
  end;
  for i:=1 to w-1 do
  begin
    Tmp^:=clr;
    Dec(Tmp);
  end;
  for i:=1 to h-1 do
  begin
    Tmp^:=clr;
    Tmp:=Ptr(Integer(Tmp)-Bmp.RowInc);
  end;
end;

procedure FillRect(Bmp:TFastRGB;x,y,w,h:Integer;clr:TFColor);
var
Tmp:   PFColor;
d,i,j: Integer;
begin
  d:=Bmp.RowInc-(w*3);
  Tmp:=@Bmp.Pixels[y,x];
  for j:=0 to h-1 do
  begin
    for i:=0 to w-1 do
    begin
      Tmp^:=clr;
      Inc(Tmp);
    end;
    Tmp:=Ptr(Integer(Tmp)+d);
  end;
end;

// Frith's ellipse
procedure Ellipse(Bmp:TFastRGB;x,y,h,k:Integer;clr:TFColor);
var
slope_mn,
slope_md,
position_mn,
position_md,
x_position,
y_position,
balance:    Integer;
begin
  if h=k then
  begin
    Circle(Bmp,x+(h div 2),y+(k div 2),h div 2,clr);
    Exit;
  end;
  h:=h div 2;
  k:=k div 2;
  x:=x+h;
  y:=y+k;
  slope_md:=k*k;
  slope_mn:=h*h;
  position_md:=0;
  position_mn:=h*h*k;
  x_position:=0;
  y_position:=k;
  balance:=0;

  while((y_position>0)or(x_position<h))do
  begin
    Bmp.Pixels[y+y_position,x+x_position]:=clr;
    Bmp.Pixels[y+y_position,x-x_position]:=clr;
    Bmp.Pixels[y-y_position,x+x_position]:=clr;
    Bmp.Pixels[y-y_position,x-x_position]:=clr;
    if balance<0 then
    begin
      Inc(balance,position_mn);
      Dec(position_mn,slope_mn);
      Dec(y_position);
    end else
    begin
      Inc(position_md,slope_md);
      Dec(balance,position_md);
      Inc(x_position);
    end;
  end;
  Bmp.Pixels[y,x+x_position]:=clr;
  Bmp.Pixels[y,x-x_position]:=clr;
end;

//bressenham line algorithm- fully integer
procedure Line(Bmp:TFastRGB;x1,y1,x2,y2:Integer;clr:TFColor);
var
d,ax,ay,
sx,sy,
dx,dy:  Integer;
Begin
  dx:=x2-x1; ax:=Abs(dx)shl 1; if dx<0 then sx:=-1 else sx:=1;
  dy:=y2-y1; ay:=Abs(dy)shl 1; if dy<0 then sy:=-1 else sy:=1;
  Bmp.Pixels[y1,x1]:=clr;
  if ax>ay then
  begin
    d:=ay-(ax shr 1);
    while x1<>x2 do
    begin
      if d>-1 then
      begin
        Inc(y1,sy);
        Dec(d,ax);
      end;
      Inc(x1,sx);
      Inc(d,ay);
      Bmp.Pixels[y1,x1]:=clr;
    end;
  end else
  begin
    d:=ax-(ay shr 1);
    while y1<>y2 do
    begin
      if d>=0 then
      begin
        Inc(x1,sx);
        Dec(d,ay);
      end;
      Inc(y1,sy);
      Inc(d,ax);
      Bmp.Pixels[y1,x1]:=clr;
    end;
  end;
end;


procedure BSpline(Bmp:TFastRGB;pnts:array of TPoint;Segments:Word;clr:TFColor);
function SplineB(mu:Real;p0,p1,p2,p3:Integer):Integer;
var
mu2,mu3: Real;
begin
  mu2:=mu*mu;
  mu3:=mu2*mu;
  Result:=Round((1/6)*(mu3*(-p0+3*p1-3*p2+p3)+mu2*(3*p0-6*p1+3*p2)+mu*(-3*p0+3*p2)+(p0+4*p1+p2)));
end;
var
mu,mudelta:      Real;
NumPoints:       Word;
x1,y1,x2,y2,n,h: Integer;
begin
  NumPoints:=TrimInt(High(pnts)+1,4,16383);
  mudelta:=1/Segments;
  for n:=3 to NumPoints-1 do
  begin
    mu:=0;
    x1:=SplineB(mu,pnts[n-3].x,pnts[n-2].x,pnts[n-1].x,pnts[n].x);
    y1:=SplineB(mu,pnts[n-3].y,pnts[n-2].y,pnts[n-1].y,pnts[n].y);
    mu:=mu+mudelta;
    for h:=1 to Segments do
    begin
      x2:=SplineB(mu,pnts[n-3].x,pnts[n-2].x,pnts[n-1].x,pnts[n].x);
      y2:=SplineB(mu,pnts[n-3].y,pnts[n-2].y,pnts[n-1].y,pnts[n].y);
      Line(Bmp,x1,y1,x2,y2,clr);
      mu:=mu+mudelta;
      x1:=x2;
      y1:=y2;
    end;
  end;
end;

procedure PolyLine(Bmp:TFastRGB;pnts:array of TPoint;clr:TFColor);
var
n,i: Integer;
begin
  n:=High(pnts)+1;
  for i:=0 to n-1 do
  Line(Bmp,pnts[i].x,pnts[i].y,pnts[(i+1) mod n].x,pnts[(i+1) mod n].y,clr);
end;

// fills array[0..255] with transition from fc to bc
procedure ColorFill(var clr:array of TFColor;fc,bc:TFColor);
var
ri,gi,bi,i: Integer;
begin
  bi:=bc.b-fc.b;
  gi:=bc.g-fc.g;
  ri:=bc.r-fc.r;
  for i:=0 to 255 do
  begin
    clr[i].b:=fc.b+MulDiv(i,bi,255);
    clr[i].g:=fc.g+MulDiv(i,gi,255);
    clr[i].r:=fc.r+MulDiv(i,ri,255);
  end;
end;

procedure FSmoothLine(Bmp:TFastRGB;x1,y1,x2,y2:Integer;clr:array of TFColor);
var
ea,ec: Word;
ci:    Byte;
dx,dy,
d,s:   Integer;
begin
  if(y1=y2)or(x1=x2)then
  begin
    Line(Bmp,x1,y1,x2,y2,clr[0]);
    Exit;
  end;

  if y1>y2 then
  begin
    d:=y1; y1:=y2; y2:=d;
    d:=x1; x1:=x2; x2:=d;
  end;

  dx:=x2-x1;
  dy:=y2-y1;

  if dx>-1 then s:=1 else
  begin
    s:=-1;
    dx:=-dx;
  end;

  ec:=0;
  Bmp.Pixels[y1,x1]:=clr[0];

  if dy>dx then
  begin
    ea:=(dx shl 16)div dy;
    while dy>1 do
    begin
      Dec(dy);
      d:=ec;
      Inc(ec,ea);
      if ec<=d then Inc(x1,s);
      Inc(y1);
      ci:=ec shr 8;
      Bmp.Pixels[y1,x1]:=clr[ci];
      Bmp.Pixels[y1,x1+s]:=clr[ci xor 255];
    end;
  end else
  begin
    ea:=(dy shl 16)div dx;
    while dx>1 do
    begin
      Dec(dx);
      d:=ec;
      Inc(ec,ea);
      if ec<=d then Inc(y1);
      Inc(x1,s);
      ci:=ec shr 8;
      Bmp.Pixels[y1,x1]:=clr[ci];
      Bmp.Pixels[y1+1,x1]:=clr[ci xor 255];
    end;
  end;
  Bmp.Pixels[y2,x2]:=clr[0];
end;

procedure FSmoothPolyLine(Bmp:TFastRGB;pnts:array of TPoint;clr:array of TFColor);
var
 n,i:Integer;
begin
  n:=High(pnts)+1;
  for i:=0 to n-1 do
  FSmoothLine(Bmp,pnts[i].x,pnts[i].y,pnts[(i+1) mod n].x,pnts[(i+1) mod n].y,clr);
end;

end.
