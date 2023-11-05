unit FastRGB;

  //  TFastRGB v1.1
  //    Gordon Alex Cowie <gfody@jps.net>
  //    www.jps.net/gfody
  //    shared properties for TFastBMP and TFastDDB
  //    see readme.rtf for documentation.

interface

type
  bmTag=(PFastBMP,PFast256,PFastDDB); //abstract tag

  TFColor  = record b,g,r:Byte end;
  PFColor  =^TFColor;
  TLine    = array[0..0]of TFColor;
  PLine    =^TLine;
  TPLines  = array[0..0]of PLine;
  PPLines  =^TPLines;

TFastRGB=class
  Gap,    // space between scanlines
  RowInc, // distance to next scanline
  Size,   // size of Bits
  Width,
  Height:     Integer;
  Pixels:     PPLines;
  Bits:       Pointer;
  Tag:        bmTag;
  procedure   Draw(hDst,x,y:Integer);                       virtual; abstract;
  procedure   Stretch(hDst,x,y,w,h:Integer);                virtual; abstract;
  procedure   DrawRect(hDst,x,y,w,h,sx,sy:Integer);         virtual; abstract;
  procedure   TileDraw(hDst,x,y,w,h:Integer);               virtual; abstract;
  procedure   Resize(Dst:TFastRGB);                         virtual; abstract;
  procedure   SmoothResize(Dst:TFastRGB);                   virtual; abstract;
  procedure   CopyRect(Dst:TFastRGB;x,y,w,h,sx,sy:Integer); virtual; abstract;
  procedure   Tile(Dst:TFastRGB);                           virtual; abstract;
end;

function FRGB(r,g,b:Byte):TFColor;
function IntToByte(i:Integer):Byte;
function TrimInt(i,Min,Max:Integer):Integer;

implementation

function FRGB(r,g,b:Byte):TFColor;
begin
  Result.b:=b;
  Result.g:=g;
  Result.r:=r;
end;

function IntToByte(i:Integer):Byte;
begin
  if      i>255 then Result:=255
  else if i<0   then Result:=0
  else               Result:=i;
end;

function TrimInt(i,Min,Max:Integer):Integer;
begin
  if      i>Max then Result:=Max
  else if i<Min then Result:=Min
  else               Result:=i;
end;

end.
