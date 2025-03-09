unit simulatorUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, TermVT, unterminal, Graphics, LadderSymbol,
  Generics.Collections;

type
  TscanType = (scanIOPLC,scanVar,scanSystemVar);

  { TResponseList }

  TResponseList = specialize TDictionary<string,string>;


type TSimulator = class(TConsoleProc)
     protected
     fexecName    : string;
     fopened      : boolean;
     fscanType    : TscanType;
     frequestList : TStringList;
     fresponseList: TResponseList;
     public
     constructor create;
     procedure buildRequestList;
     procedure startSimulator;
     procedure stopSimulator;
     procedure RefreshLine(const grilla: TtsGrid; fIni, HeightScr: integer);
     procedure RefreshLines(const grilla: TtsGrid; fIni, fFin,HeightScr: integer);
     procedure sendRequest;
     procedure sendSetRequest;
     procedure updateGraphWithData;
     procedure updateDataWatchGrid;
     end;

implementation

uses main;

constructor TSimulator.create;
begin
  inherited create(nil);
  OnRefreshLine:=@RefreshLine;
  OnRefreshLines:=@RefreshLines;
  fopened:=false;
  {$ifdef linux}
  LineDelimSend := LDS_LF;
  {$endif}
  fexecName := form1.projectCurrent.fpath+
               form1.projectCurrent.fname+'-data/runtime';
  frequestList:=TStringList.Create(false);
  fresponseList:=TResponseList.Create;
end;

// build request list

procedure TSimulator.buildRequestList;
var
  i,j,index      : integer;
  varName        : string;
begin
  frequestList.Clear;
  // add var in current graph
  for i:=0 to grapheCurrent.ObjectsCount-1 do
      if (grapheCurrent.Objects[i].IsNode) and
         (grapheCurrent.Objects[i] is TSymbol) and
         not(grapheCurrent.Objects[i] is TPowerRail) then
           begin
            // if timerObject add * to the request
            if (grapheCurrent.Objects[i] is TTimerObject) then
               begin
               varName:='*'+TSymbol(grapheCurrent.Objects[i]).allias;
               if frequestList.IndexOf(varName)=-1 then
                  frequestList.add(varName);
               end
            else
            begin
            for j:=0 to TSymbol(grapheCurrent.Objects[i]).getVarList.Count-1 do
                if (grapheCurrent.Objects[i] is TBit) or
                   (grapheCurrent.Objects[i] is TCoil) or
                   (grapheCurrent.Objects[i] is TTimerObject) then
                         // if bit or coil, add nothing
                            varName:=TSymbol(grapheCurrent.Objects[i]).getVarList[j]
                else
                    // if variable then add @ to the request
                   if not(TSymbol(grapheCurrent.Objects[i]).getVarList[j][1] in ['0'..'9']) then
                      varName:='@'+TSymbol(grapheCurrent.Objects[i]).getVarList[j];
                if frequestList.IndexOf(varName)=-1 then
                  frequestList.add(varName);
            end;
            end;
  // add var in datawatch grid
    for i:=1 to form1.dataWatchGrid.rowcount-1 do
        begin
        varName:=form1.dataWatchGrid.Cells[0,i];
        if length(varName)<>0 then
           begin
            if frequestList.IndexOf(varName)=-1 then
               begin
                if form1.IOplcGrid.Cols[0].IndexOf(varName)<>-1 then
                   begin
                     index:=form1.IOplcGrid.Cols[0].IndexOf(varName);
                     if form1.IOplcGrid.Cells[2,index]='ANALOG' then
                       // variable int
                       frequestList.add('@'+form1.dataWatchGrid.Cells[0,i])
                     else
                       // variable bit
                       frequestList.add(form1.dataWatchGrid.Cells[0,i])
                   end;
                if form1.VARGrid.Cols[0].IndexOf(varName)<>-1 then
                   begin
                     index:=form1.VARGrid.Cols[0].IndexOf(varName);
                     if form1.VARGrid.Cells[2,index]='BIT' then
                       // variable bit
                       frequestList.add(form1.dataWatchGrid.Cells[0,i])
                     else
                       // variable int
                       frequestList.add('@'+form1.dataWatchGrid.Cells[0,i])
                   end;
                if form1.SystemGrid.Cols[0].IndexOf(varName)<>-1 then
                   begin
                     index:=form1.SystemGrid.Cols[0].IndexOf(varName);
                     if form1.SystemGrid.Cells[2,index]='BIT' then
                       // variable bit
                       frequestList.add(form1.dataWatchGrid.Cells[0,i])
                     else
                       // variable int
                       frequestList.add('@'+form1.dataWatchGrid.Cells[0,i])
                   end;
                end;
            end;
        end;
end;

// start exec code

procedure TSimulator.startSimulator;
var
  fichier : text;
  i       : integer;
  j       : integer;
  varName : string;
  index   : integer;
begin
  // build request list
  frequestList.clear;
  // save project
  Form1.projectCurrent.saveProject;
  // build request list
  buildRequestList;
  // generate code for current ladder project for simulator
  form1.itemCompileClick(self);
  if graphError then
     begin
     graphError:=false;
     exit;
     end;
  // set flag for simulation
  assignfile(fichier,form1.projectCurrent.fpath+form1.projectCurrent.fname+'-data/simulator.cfg');
  rewrite(fichier);
  writeln(fichier,'{$DEFINE Simulator}');
  CloseFile(fichier);
  // build lib folder for compiler
  if not DirectoryExists(form1.projectCurrent.fpath+form1.projectCurrent.fname+'-data/lib') then
     MkDir(form1.projectCurrent.fpath+form1.projectCurrent.fname+'-data/lib');
  // generate binary code
  Form1.projectCurrent.binaryBuildX86;
  // start current project exec file
  Open(fexecName,'');
  sendRequest;
  fopened:=true;
  form1.simulatorRunIndicator.Brush.Color:=clLime;
end;

// ask to stop and kill exec code
procedure TSimulator.stopSimulator;
var
  fichier : text;
begin
  if fopened then
     begin
      // ask project exec to be killed
      SendLn('*');
      Sleep(100);
      // close pipe
      form1.TabSheetDataWatch.Visible:=false;
      close;
      assignfile(fichier,form1.projectCurrent.fpath+form1.projectCurrent.fname+'-data/simulator.cfg');
      rewrite(fichier);
      writeln(fichier,'{$UNDEF Simulator}');
      CloseFile(fichier);
      form1.simulatorRunIndicator.Brush.Color:=clRed;
     end;
end;

// Event line received from exec code
procedure TSimulator.RefreshLine(const grilla: TtsGrid; fIni, HeightScr: integer);
var
  i        : integer;
  variable : string;
  data     : string;
begin
  data:='';
  if data='*' then
     // project exec is killed
     begin
     fopened:=true;
     exit;
     end;
  while data<>'#' do
  begin
   data:=grilla[fIni];
   variable:=copy(data,0,pos('=',data)-1);
   data:=copy(data,pos('=',data)+1,length(data));
   for i:=1 to form1.dataWatchGrid.RowCount-1 do
      if form1.dataWatchGrid.Cells[0,i]=Variable then
         form1.dataWatchGrid.Cells[1,i]:=data;
  end;
end;

// Event lines received from exec code
procedure TSimulator.RefreshLines(const grilla: TtsGrid; fIni, fFin,
  HeightScr: integer);
var
  i,j     : integer;
  diff    : integer;
  varName : string;
  etat    : string;
begin
// get data from code running
diff:=fFin-fIni;
if diff>0 then
   begin
   fresponseList.Clear;
    for i:=0 to diff do
       begin
       if grilla[fIni+i]='*' then
          // project exec is killed
          begin
          fopened:=false;
          exit;
          end;
       if pos('=',grilla[fIni+i])<>0 then
          begin
          for j:=0 to frequestList.Count-1 do
             if frequestList[j]=copy(grilla[fIni+i],0,pos('=',grilla[fIni+i])-1) then
                begin
                varName:=copy(grilla[fIni+i],0,pos('=',grilla[fIni+i])-1);
                if (varName[1]='@') then
                   varName:=copy(varName,2,length(varName));
                etat:=copy(grilla[fIni+i],pos('=',grilla[fIni+i])+1,length(grilla[fIni+i]));
                if not fresponseList.ContainsKey(varName) then
                   begin
                   fresponseList.Add(varName,etat);
                   end;
                end;
          end;
       end;
    updateGraphWithData;
    updateDataWatchGrid;
   end;
end;

// send reading request
procedure TSimulator.sendRequest;
var
  i       : integer;
  request : string;
begin
  // send request
  request:='';
  for i:=0 to frequestList.Count-1 do
     request:=request+frequestList[i]+',';
  request:=copy(request,0,length(request)-1);
  SendLn('?'+request);
end;

procedure TSimulator.sendSetRequest;
begin
  sendLn('='+dataWatchInstruction);
end;

procedure TSimulator.updateGraphWithData;
var
  i       : integer;
begin
  for i:=0 to grapheCurrent.ObjectsCount-1 do
      if (grapheCurrent.Objects[i].IsNode) and
         (grapheCurrent.Objects[i] is TSymbol) and
         not(grapheCurrent.Objects[i] is TPowerRail) then
            begin
            if (fresponseList.ContainsKey(TSymbol(grapheCurrent.Objects[i]).allias)) or
               (fresponseList.ContainsKey('*'+TSymbol(grapheCurrent.Objects[i]).allias)) then
               begin
               case grapheCurrent.Objects[i].ClassName of
                    'TBit'   : if (fresponseList[TSymbol(grapheCurrent.Objects[i]).allias]='On') or
                                  (fresponseList[TSymbol(grapheCurrent.Objects[i]).allias]='Set')
                                  then TBit(grapheCurrent.Objects[i]).HighLight(true)
                                  else TBit(grapheCurrent.Objects[i]).HighLight(false);
                    'TCoil'  : begin
                               case fresponseList[TSymbol(grapheCurrent.Objects[i]).allias] of
                                    'On'      : TCoil(grapheCurrent.Objects[i]).HighLight(true);
                                    'Off'     : TCoil(grapheCurrent.Objects[i]).HighLight(false);
                                    'Set'     : begin
                                                 if TCoil(grapheCurrent.Objects[i]).fonction='coilSET' then
                                                   TCoil(grapheCurrent.Objects[i]).HighLight(true);
                                                 if TCoil(grapheCurrent.Objects[i]).fonction='coilRESET' then
                                                   TCoil(grapheCurrent.Objects[i]).HighLight(false);
                                                end;
                                    'Reset'   : begin
                                                 if TCoil(grapheCurrent.Objects[i]).fonction='coilSET' then
                                                   TCoil(grapheCurrent.Objects[i]).HighLight(false);
                                                 if TCoil(grapheCurrent.Objects[i]).fonction='coilRESET' then
                                                   TCoil(grapheCurrent.Objects[i]).HighLight(true);
                                                end;
                                    end;
                               end;
                  'TCompare' : begin

                               end;
                    'TFlash' : case fresponseList['*'+TSymbol(grapheCurrent.Objects[i]).allias] of
                               'enabled'  : TTimerObject(grapheCurrent.Objects[i]).HighLight(true);
                               'disabled' : TTimerObject(grapheCurrent.Objects[i]).HighLight(false);
                               end;
                    'TTon'   : case fresponseList['*'+TSymbol(grapheCurrent.Objects[i]).allias] of
                               'enabled'  : TTimerObject(grapheCurrent.Objects[i]).HighLight(true);
                               'disabled' : TTimerObject(grapheCurrent.Objects[i]).HighLight(false);
                               end;
                    'TToff'  : case fresponseList['*'+TSymbol(grapheCurrent.Objects[i]).allias] of
                               'enabled'  : TTimerObject(grapheCurrent.Objects[i]).HighLight(true);
                               'disabled' : TTimerObject(grapheCurrent.Objects[i]).HighLight(false);
                               end;
                    end;

               end;

            end;
end;

procedure TSimulator.updateDataWatchGrid;
var
  i : integer;
begin
  for i:=1 to form1.dataWatchGrid.RowCount-1 do
     if form1.dataWatchGrid.Cells[0,i]<>'' then
         if (fresponseList.ContainsKey(form1.dataWatchGrid.Cells[0,i])) then
           form1.dataWatchGrid.Cells[1,i]:=
              fresponseList[form1.dataWatchGrid.Cells[0,i]];
end;

end.

