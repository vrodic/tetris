unit VDB;
{VDB Text Database Class}
{CopyRight Vedran Rodic 1997}
interface

{/$DEFINE DEBUG}

uses WinTypes, WinProcs, Classes, SysUtils{$IFDEF DEBUG},Dialogs{$ENDIF};
Const Hdr = 'VDB'; {Header of database}
      Sep = ','; {Sepearator of VDB}

type TVDB = Class
     private
        FVDBStrings : TStringList;
        FNumRecords : Byte;
        FCurrRecord : Byte;
        FCurrLine : word;
        FVDBExists : Boolean;
        FFileName : string;
        FNumLines : word;
        function GetHeader : boolean;

     protected
     public
       procedure NewFile(NumRecords : Byte);
       function  GetNumLines : word;
       function  GetNumRecords : byte;
       function  OpenFile(FileName : string) : boolean;
       procedure SaveFile(FileName : string);
       function  GetData(line : word; numrec : byte): string;
       {procedure SetData(line : word; numrec : byte; str : string);}
       procedure AddString(str : string);
       constructor Create;
       destructor Destroy;
end;


implementation
constructor TVDB.Create;
begin
 { Main Initialization }
end;

destructor TVDB.Destroy;
begin
  { finalization }
end;

procedure TVDB.NewFile(NumRecords : byte);
begin
     FNumRecords := NumRecords;
     FVDBStrings := TStringList.Create;
     FVDBStrings.Add('');
     FVDBStrings.Strings[0] := Hdr + Sep + IntToStr(FNumRecords);
     FVDBExists := True;
     FCurrRecord := 1;
     FCurrLine := 1;
     FVDBStrings.Add('');
end;

function TVDB.GetNumRecords : byte;
begin
     Result := FNumRecords;
end;

function TVDB.GetHeader : boolean;
var firstline : string;
    head : string;
    i : integer;
    cr : integer;
    nr : string;
begin
     cr := 1;
     head := '';
     nr := '';
     firstline := FVDBStrings.Strings[0];
     for i := 1 to length(firstline) do
     begin
          if firstline[i] = Sep then
          begin
             inc(cr);
          end
          else
          begin
             case cr of 1: head := Head + firstline[i];
                        2: nr := nr + firstline[i];
             end;
          end;
     end;
     if not (head = Hdr) then
     begin
      Result := False;
      Exit;
     end;
     FNumRecords := StrToInt(nr);
     Result := True;
end;

function TVDB.OpenFile(FileName : string): boolean;
begin
 if FVDBExists then FVDBStrings.Free;
 FVDBStrings := TStringList.Create;
 FFileName := FileName;
 if not FileExists(FileName) then
 begin
      Result := False;
      exit;
 end;
 FVDBStrings.LoadFromFile(FileName);
 result := GetHeader;
 FNumLines := FVDBStrings.Count -1;
 FVDBExists := True;
end;

procedure TVDB.SaveFile(FileName : string);
begin
     if not FVDBExists then Exit;
     FFileName := FileName;
     {FVDBStrings.Delete(FNumLines);
     FVDBStrings.Delete(FNumLines);}
     {ShowMessage(FVDBStrings.Strings[FNumLines+3]);}
     FVDBStrings.SaveToFile(FFileName);
end;

procedure TVDB.AddString(str : string);
begin
     if FCurrRecord > FNumRecords then
     begin
          Inc(FCurrLine);
          FCurrRecord := 1;
          FVDBStrings.Add('');
{          if not VDStrings.Count = FCurrLine -1}
     end;
     if FCurrRecord = FNumRecords then
     begin
       FVDBStrings.Strings[FCurrLine] := FVDBStrings.Strings[FCurrLine] + str;
     end
     else
     begin
        if FCurrRecord = 1 then FVDBStrings.Strings[FCurrLine] := str+sep else
         FVDBStrings.Strings[FCurrLine] := FVDBStrings.Strings[FCurrLine] +str+sep;
     end;
     inc(FCurrRecord);
end;
function TVDB.GetData(Line : word; numrec : byte) : string;
var tmpstr : string;
    i : word;
    cr : byte;
    rt : string;
begin
     cr := 1;
     rt := '';
     if line > FNumLines then exit;
     if numrec > FNumRecords then exit;
     tmpstr := FVDBStrings.Strings[line];
     {$IFDEF DEBUG}
     ShowMessage(tmpstr);
     {$ENDIF}
     for i := 1 to length(tmpstr) do
     begin
          if tmpstr[i] = sep then
          begin
           inc(cr);
          end
          else
          begin
               if cr = numrec then
               begin
                rt := rt + tmpstr[i];
               end;
          end;
     end;
     Result := rt;
end;
{procedure TVDB.SetData(line: word; numrec : byte ; str : string);
var i : word;
    tmpstr : string;
    cr : byte;
begin
     cr := 1;
     if line > FNumLines then exit;
     if numrec > FNumRecords then exit;
     tmpstr := FVDBStrings.Strings[line];
     for i := 1 to length(tmpstr);
     begin
          if tmpstr[i] = sep then
          begin
               inc(cr);
               if cr =
          end;
     end;

      later
end;}

function TVDB.GetNumLines : word;
begin
     Result := FNumLines;
end;

end.
