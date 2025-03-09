unit projectunit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, Forms,SysUtils,ComCtrls,laddergraphunit,fgl,grids,
  LadderSymbol,FileUtil,process;

{ TProject}

type TProject = class
  fname            : string;
  fpath            : string;
  fplc             : string;
  fprojectTree     : TTreeView;                // project tree
  fBlocList        : TStringList;              // blocks in project

  constructor create(name : string;path:string;plc:string;projectTree:TTreeView);
  destructor destroy; override;
  procedure saveProject;
  procedure replaceProject(oldPath,oldName,newPath,newName:string);
  procedure loadProject;
  procedure loadConfig;
  procedure addBloc(blocName : string;ladderGraph:TLadderGraph);
  procedure renameBloc(oldBlocName : string; newBlocName : string);
  procedure updateProjectTree;
  procedure RenameVar(oldVarName,newVarName:string);
  procedure buildVarUnit;
  procedure binaryBuildX86;
  procedure binaryBuildTarget;

  end;

implementation

uses main,xmlunit;

{ TProject}

constructor TProject.create(name : string;path:string;plc:string;projectTree:TTreeView);
begin
  fname:=name;
  fpath:=path;
  fplc:=plc;
  fBlocList:=TStringList.create;
  fprojectTree:=projectTree;
end;

destructor TProject.destroy;
var
  i : integer;
begin
  i:=fprojectTree.Items.Count;
  while i>0 do
        begin
        fprojectTree.Items.Delete(fprojectTree.Items[0]);
        i:=fprojectTree.Items.Count;
        end;
  inherited;
end;

procedure TProject.saveproject;
var
  i            : integer;
  xmlDocument  : TXmlObject;
begin
  xmlDocument:=TXmlObject.create;
  xmlDocument.saveProjectXML;
  FreeAndNil(xmlDocument);
  for i:=0 to main.LadderGraphList.count-1 do
      begin
      xmlDocument:=TXmlObject.create;
      xmlDocument.saveBlockXML(LadderGraphList[i].name,LadderGraphList[i]);
      FreeAndNil(xmlDocument);
      TLadderGraph(main.LadderGraphList[i]).graphChanged:=false;
      end;
end;

procedure TProject.replaceProject(oldPath,oldName,newPath,newName:string);
var
  i            : integer;
  xmlDocument  : TXmlObject;
begin
  form1.projectCurrent.fname:=newName;
  form1.projectCurrent.fpath:=newPath;
  xmlDocument:=TXmlObject.create;
  xmlDocument.saveProjectXML;
  xmlDocument.free;
  if not(DirectoryExists(newPath+newName+'-data/')) then
    MkDir(newPath+newName+'-data/');
  for i:=0 to fBlocList.Count-1 do
      begin
      if FileExists(oldPath+oldName+'-data/'+fBlocList[i]+'.xml') then
         copyFile( oldPath+oldName+'-data/'+fBlocList[i]+'.xml',
                   newPath+newName+'-data/'+fBlocList[i]+'.xml');
      end;
end;

procedure TProject.loadProject;
var
  i            : integer;
  xmlDocument  : TXmlObject;
begin
  xmlDocument:=TXmlObject.create;
  xmlDocument.loadProjectXML;
  xmlDocument.free;
  // IO PLC Grid
  form1.IOplcGrid.RowCount:=1;
  for i:=0 to ioPlcList.Count-1 do
      begin
      if form1.IOplcGrid.RowCount<i+2 then form1.IOplcGrid.RowCount:=i+2;
      form1.IOplcGrid.Cells[0,i+1]:=ioPlcList[i].nameVar;
      form1.IOplcGrid.Cells[1,i+1]:=ioPlcList[i].gpio;
      form1.IOplcGrid.Cells[2,i+1]:=ioPlcList[i].typeVar;
      form1.IOplcGrid.Cells[3,i+1]:=ioPlcList[i].comment;
      end;
  form1.IOplcGrid.RowCount:=form1.IOplcGrid.RowCount+1;
  // VAR Grid
  form1.VARGrid.rowcount:=1;
  for i:=0 to varList.Count-1 do
      begin
      if form1.varGrid.RowCount<i+2 then form1.varGrid.RowCount:=i+2;
      form1.varGrid.Cells[0,i+1]:=varList[i].nameVar;
      form1.varGrid.Cells[1,i+1]:=varList[i].typeVar;
      form1.varGrid.Cells[2,i+1]:=varList[i].comment;
      end;
  form1.VARGrid.RowCount:=form1.VARGrid.RowCount+1;
  // Timer Grid
  form1.TimerGrid.rowcount:=1;
  for i:=0 to timerList.Count-1 do
      begin
      if form1.TimerGrid.RowCount<i+2 then form1.TimerGrid.RowCount:=i+2;
      form1.TimerGrid.Cells[0,i+1]:=timerList[i].nameVar;
      end;
  form1.TimerGrid.RowCount:=form1.TimerGrid.RowCount+1;

  // System bits
  loadConfig;
end;

procedure TProject.loadConfig;
var
  fichier    : TextFile;
  line       : string;
  sbname     : string;
  sbtype     : string;
  sbequation : string;
  sbcomment  : string;
  gpio       : string;
begin
     systemVarList.Clear;
     AssignFile(fichier,ExtractFilePath(paramstr(0))+'/config/'+self.fplc.replace(' ','_')+'/'+self.fplc.replace(' ','_')+'.cfg',fmInput);
     reset(fichier);
     form1.SystemGrid.RowCount:=2;
     while not(eof(fichier)) do
           begin
           readln(fichier,line);
           if line='#system variable' then
              begin
                   repeat
                   readln(fichier,line);
                   if line[1]<>'#' then
                      begin
                      sbname:=copy(line,0,pos(';',line)-1);
                      form1.SystemGrid.Cells[0,form1.SystemGrid.RowCount-1]:=sbname;
                      line:=copy(line,pos(';',line)+1,length(line));
                      sbtype:=copy(line,0,pos(';',line)-1);
                      form1.SystemGrid.cells[1,form1.SystemGrid.RowCount-1]:=sbtype;
                      line:=copy(line,pos(';',line)+1,length(line));
                      sbcomment:=copy(line,0,pos(';',line)-1);
                      form1.SystemGrid.cells[2,form1.SystemGrid.RowCount-1]:=sbcomment;
                      line:=copy(line,pos(';',line)+1,length(line));
                      sbequation:=line;
                      form1.SystemGrid.cells[3,form1.SystemGrid.RowCount-1]:=sbequation;
                      systemVarList.Add(sbname,sbequation);
                      form1.SystemGrid.rowcount:=form1.SystemGrid.rowcount+1;
                      end;
                   until line[1]='#';
                   form1.SystemGrid.rowcount:=form1.SystemGrid.rowcount-1;
              end;
           if line='#GPIO' then
              begin
              readln(fichier,line);
              form1.IOplcGrid.Columns[1].ButtonStyle:=cbsPickList;
              form1.IOplcGrid.Columns[1].PickList.clear;
               while pos(',',line)<>0 do
                  begin
                  gpio:=copy(line,0,pos(',',line)-1);
                  form1.IOplcGrid.Columns[1].PickList.add(gpio);
                  line:=copy(line,pos(',',line)+1,length(line));
                  if (pos(',',line)=0) and (line<>'') then
                     form1.IOplcGrid.Columns[1].PickList.Add(line);
                  end;
              end;
           end;
     CloseFile(fichier);
end;

procedure TProject.addBloc(blocName : string;ladderGraph:TLadderGraph);
begin
  fBlocList.Add(blocName);
  main.LadderGraphList.add(ladderGraph);
  updateProjectTree;
end;

procedure TProject.renameBloc(oldBlocName : string; newBlocName : string);
begin
  if fBlocList.IndexOf(oldBlocName)>-1 then
     begin
     fBlocList.delete(fBlocList.IndexOf(oldBlocName));
     fBlocList.Add(newBlocName);
     end;
end;

procedure TProject.updateProjectTree;
var
  i : integer;
  node : TTreeNode;
begin
  while fprojectTree.Items.Count>0 do
      fprojectTree.Items[0].Delete;
  fprojectTree.Items.Add(nil,self.fname);
  // Ladder blocks
  fprojectTree.Items.AddChild(fprojectTree.items.FindNodeWithText(fname),'Block');
  node:=fprojectTree.items.FindNodeWithText('Block');
  for i:=0 to fBlocList.Count-1 do
      fprojectTree.Items.AddChild(node,fBlocList[i]);
  // Hardware
  fprojectTree.Items.AddChild(fprojectTree.items.FindNodeWithText(fname),'Hardware');
  node:=fprojectTree.items.FindNodeWithText('Hardware');
  fprojectTree.Items.AddChild(node,fplc);
  // IO
  fprojectTree.Items.AddChild(node,'IO');
  node:=fprojectTree.items.FindNodeWithText('IO');
  for i:=0 to ioPlcList.Count-1 do
      begin
        fprojectTree.Items.AddChild(node, ioPlcList.Items[i].nameVar+' '+
                                          ioPlcList.Items[i].gpio+' '+
                                          ioPlcList.Items[i].typeVar);
      end;
  // expand all
  fprojectTree.FullExpand;
end;

procedure TProject.RenameVar(oldVarName,newVarName:string);
var
  i,n,o        : integer;
  graphe       : TLadderGraph;
  listeVar     : TStringList;
  xmlDocument  : TXmlObject;
  found        : boolean=false;

  procedure findAndReplaceVar;
  var
    j,k : integer;
  begin
  if listeVar.Count>0 then
    for j:=0 to graphe.ObjectsCount-1 do
      if graphe.Objects[j].IsNode then
         begin
         if graphe.Objects[j] is TSymbol then
            begin
            listeVar:=TSymbol(graphe.Objects[j]).getVarList;
            if listeVar<>nil then
               begin
               for k:=0 to listeVar.Count-1 do
                   begin
                   if listeVar[k]=oldVarName then listeVar[k]:=newVarName;
                   end;
               TSymbol(graphe.Objects[j]).SetVar(listeVar);
               end;
            end;
         end;
  end;

begin
  // for all the graphe in use
  // test and replace if oldnamevar is used
  listeVar:=TStringList.Create;
  for i:=0 to ladderGraphList.count-1 do
      begin
      graphe:=ladderGraphList[i];
      findAndReplaceVar;
      end;

  // do the same for all blocks of the project
  for i:=0 to fBlocList.count-1 do
      begin
      found:=false;
      // if bloc is not in graphlist
      for n:=0 to ladderGraphList.Count-1 do
      if ladderGraphList[n].name=fBlocList[i] then found:=true;
      if not found then
         begin
         if FileExists(fpath+fname+'-data/'+fBlocList[i]+'.xml') then
            begin
             graphe:=TLadderGraph.create(form1,'virtual');
             xmlDocument:=TXmlObject.create;
             xmlDocument.loadBlocXML (graphe,
                                     fpath+fname+'-data/'+fBlocList[i]+'.xml');
             graphe.name:=fBlocList[i];
             findAndReplaceVar;
             xmlDocument.saveBlockXML(graphe.name, graphe);
            end;
         // delete page of tabsheet
         for o:=0 to form1.ladderSurface.PageCount-1 do
             if form1.ladderSurface.Pages[o].Caption=fBlocList[i] then
                form1.ladderSurface.Pages[o].Free;
         freeandnil(graphe);
         freeandnil(xmlDocument);
         end;
      end;
  // do the same for dataWatch tab and cross references tab
  for i:=0 to form1.dataWatchGrid.RowCount-1 do
    if form1.dataWatchGrid.Cells[0,i]=oldVarName then
       form1.dataWatchGrid.Cells[0,i]:=newVarName;
  for i:=0 to form1.crossRefGrid.RowCount-1 do
    if form1.crossRefGrid.Cells[0,i]=oldVarName then
       form1.crossRefGrid.Cells[0,i]:=newVarName;

end;

procedure TProject.buildVarUnit;
var
    fileName            : string;
    fichier             : text;
    i                   : integer;
    runTimeTemplateFile : string;
    line                : string;
    textFileListStr     : TStringList;
    tempStr             : string;
    found               : boolean;
begin
  // build Var Unit
  fileName:=fpath+fname+'-data/varunit.pas';
   if FileExists(fileName) then
      DeleteFile(fileName);

    // Transfer runtime file template to the project data folder
   if FileExists(fpath+fname+'-data/varunit.pas') then
      DeleteFile(fpath+fname+'-data/varunit.pas');
   runTimeTemplateFile:=ExtractFilePath(paramstr(0))+'/runtime/varunit.pas';
   CopyFile(runTimeTemplateFile,fpath+fname+'-data/varunit.pas');

   // Transfer timeunit file template to the project data folder
   if FileExists(fpath+fname+'-data/timeunit.pas') then
      DeleteFile(fpath+fname+'-data/timeunit.pas');
   runTimeTemplateFile:=ExtractFilePath(paramstr(0))+'/runtime/timeunit.pas';
   CopyFile(runTimeTemplateFile,fpath+fname+'-data/timeunit.pas');

   textFileListStr:=TStringList.Create;
   textFileListStr.Clear;
   assign(fichier,fpath+fname+'-data/varunit.pas');
   reset(fichier);
   while not(eof(fichier)) do
      begin
      readln(fichier,line);
      found:=false;
      // add Var declaration
      if pos('//var',line)<>0 then
           begin
           found:=true;
           textFileListStr.Add(line);
              if varList.Count>0 then
                 begin
                 textFileListStr.Add('var');
                 tempStr:='';
                  for i:=0 to varList.count-1 do
                      begin
                        tempStr:= '   '+varList[i].nameVar.Replace(' ','_')+chr(9)+
                                  chr(9)+': ';
                        case varList[i].typeVar of
                             'BIT'  : tempStr:=tempStr+'TBIT;';
                             'PULSE': tempstr:=tempStr+'TFront;';
                             'INT'  : tempStr:=tempStr+'integer;';
                             'DINT' : tempStr:=tempStr+'longInt;';
                             'WORD' : tempStr:=tempStr+'word;';
                             'DWORD': tempStr:=tempStr+'dword;';
                        end;
                      textFileListStr.Add(tempStr);
                      end;
                 end;
           end;
      // add IO declaration
      if pos('//IO',line)<>0 then
                 begin
                 found:=true;
                 textFileListStr.Add(line);
                    if ioPlcList.Count>0 then
                       begin
                       textFileListStr.Add('var');
                       tempStr:='';
                       for i:=0 to ioPlcList.count-1 do
                           textFileListStr.Add( '   '+
                                                ioPlcList[i].nameVar.Replace(' ','_')+
                                                chr(9)+chr(9)+': TIO;');

                       end;
                 end;
      // add system var declaration
      if pos('//SYSTEM',line)<>0 then
                 begin
                 found:=true;
                 textFileListStr.Add(line);
                    if ioPlcList.Count>0 then
                       begin
                       textFileListStr.Add('var');
                       tempStr:='';
                       for i:=1 to form1.SystemGrid.RowCount-1 do
                           case form1.SystemGrid.Cells[1,i] of
                                'BIT' : textFileListStr.Add('   '+form1.SystemGrid.Cells[0,i]+chr(9)+chr(9)+': TBIT;');
                                'INT' : textFileListStr.Add('   '+form1.SystemGrid.Cells[0,i]+chr(9)+chr(9)+': integer;');
                           end;
                       end;
                 end;
      // add timer declaration
      if pos('//TIME',line)<>0 then
                 begin
                 found:=true;
                 textFileListStr.Add(line);
                    if timerList.Count>0 then
                       begin
                       textFileListStr.Add('var');
                       tempStr:='';
                       for i:=0 to timerList.Count-1 do
                           case timerList[i].typeVar of
                                'Ton'    : textFileListStr.Add('   '+timerList[i].nameVar+chr(9)+chr(9)+': TTon;');
                                'Toff'   : textFileListStr.Add('   '+timerList[i].nameVar+chr(9)+chr(9)+': TToff;');
                                'TFlash' : textFileListStr.Add('   '+timerList[i].nameVar+chr(9)+chr(9)+': TFlash;');
                           end;
                       end;
                 end;
      // add initVar
      if pos('//INITVAR',line)<>0 then
                 begin
                 found:=true;
                 textFileListStr.Add(line);
                 tempStr:='';
                 for i:=0 to varList.count-1 do
                    if varList[i].typeVar='BIT' then
                    begin
                    tempStr:=varList[i].nameVar.Replace(' ','_')+':=';
                    tempStr:= tempStr+'TBIT.create('+''''+
                              varList[i].nameVar.Replace(' ','_')+
                              ''',false);';
                    textFileListStr.Add(tempStr);
                    tempStr:='bitList.Add('+varList[i].nameVar.Replace(' ','_')+');';
                    textFileListStr.Add(tempStr);
                    end;
                 end;
      // add initIO
      if pos('//INITIO',line)<>0 then
                 begin
                 found:=true;
                 textFileListStr.Add(line);
                 tempStr:='';
                 for i:=0 to ioPlcList.count-1 do
                    begin
                    tempStr:= ioPlcList[i].nameVar.Replace(' ','_')+':=TIO.create(';
                    tempStr:= tempStr+''''+ioPlcList[i].nameVar.Replace(' ','_')+''','+
                              ''''+ioPlcList[i].gpio+''','+''''+
                              ioPlcList[i].typeVar+''');';
                    textFileListStr.Add(tempStr);
                    tempStr:='bitList.Add('+ioPlcList[i].nameVar.Replace(' ','_')+');';
                    textFileListStr.Add(tempStr);
                    end;
                 end;
      if pos('//INITSYSTEM',line)<>0 then
                 begin
                 found:=true;
                 textFileListStr.Add(line);
                 tempStr:='';
                 for i:=1 to form1.SystemGrid.RowCount-1 do
                    if form1.SystemGrid.Cells[1,i]='BIT' then
                    begin
                    tempStr:= form1.SystemGrid.Cells[0,i]+':=TBIT.create(';
                    tempStr:= tempStr+''''+form1.SystemGrid.Cells[0,i]+''','+
                              systemVarList[form1.SystemGrid.Cells[0,i]]+');';
                    textFileListStr.Add(tempStr);
                    tempStr:='bitList.Add('+form1.SystemGrid.Cells[0,i]+');';
                    textFileListStr.Add(tempStr);
                    end;
                 end;
      if pos('//INITTIME',line)<>0 then
                 begin
                 found:=true;
                 textFileListStr.Add(line);
                 tempStr:='';
                 for i:=0 to timerList.Count-1 do
                    begin
                    case timerList[i].typeVar of
                         'Ton'  : begin
                                  tempStr:= timerList[i].nameVar+':=TTOn.create('+
                                  ''''+timerList[i].nameVar+''',false,'+
                                  timerList[i].preset+');';
                                  end;
                         'Toff' : begin
                                  tempStr:= timerList[i].nameVar+':=TTOff.create('+
                                  ''''+timerList[i].nameVar+''',false,'+
                                  timerList[i].preset+');';
                                  end;
                       'TFlash' : begin
                                  tempStr:= timerList[i].nameVar+':=TFlash.create('+
                                  ''''+timerList[i].nameVar+''',false,'+
                                  timerList[i].presetON+','+timerList[i].presetOFF+');';
                                  end;
                         end;
                    textFileListStr.Add(tempStr);
                    tempstr:='bitlist.add('+timerList[i].nameVar+');';
                    textFileListStr.Add(tempStr);
                    end;
                 end;
      if pos('//INITFRONT',line)<>0 then
                 begin
                 found:=true;
                 textFileListStr.Add(line);
                 tempStr:='';
                 for i:=1 to form1.VARGrid.RowCount-1 do
                    if form1.VARGrid.Cells[1,i]='PULSE' then
                                        begin
                                        tempStr:= form1.VARGrid.Cells[0,i]+':=TFRONT.create(';
                                        tempStr:= tempStr+''''+form1.VARGrid.Cells[0,i]+''',false);';
                                        textFileListStr.Add(tempStr);
                                        tempStr:='frontList.Add('+form1.VARGrid.Cells[0,i]+');';
                                        textFileListStr.Add(tempStr);
                                        end;
                 end;
      if pos('//GETVARVALUE',line)<>0 then
                 begin
                 found:=true;
                 textFileListStr.Add(line);
                 tempStr:='';
                 for i:=1 to form1.SystemGrid.RowCount-1 do
                    if (form1.SystemGrid.Cells[1,i]<>'BIT') and (form1.SystemGrid.Cells[1,i]<>'PULSE') then
                    begin
                    tempStr:= ''''+form1.SystemGrid.Cells[0,i]+''': result:=inttostr('+form1.SystemGrid.Cells[0,i]+');';
                    textFileListStr.Add(tempStr);
                    end;
                 for i:=0 to varList.Count-1 do
                    if (varList[i].typeVar<>'BIT') and (varList[i].typeVar<>'PULSE') then
                    begin
                    tempStr:= ''''+varList[i].nameVar+''': result:=inttostr('+varList[i].nameVar+');';
                    textFileListStr.Add(tempStr);
                    end;
                 end;
      if pos('//SETVARVALUE',line)<>0 then
                 begin
                 found:=true;
                 textFileListStr.Add(line);
                 tempStr:='';
                 for i:=1 to form1.SystemGrid.RowCount-1 do
                    if (form1.SystemGrid.Cells[1,i]<>'BIT') and (form1.SystemGrid.Cells[1,i]<>'PULSE') then
                    begin
                    tempStr:= ''''+form1.SystemGrid.Cells[0,i]+''': '+form1.SystemGrid.Cells[0,i]+':=strtoint(value);';
                    textFileListStr.Add(tempStr);
                    end;
                 for i:=0 to varList.Count-1 do
                    if (varList[i].typeVar<>'BIT') and (varList[i].typeVar<>'PULSE') then
                    begin
                    tempStr:= ''''+varList[i].nameVar+''': '+varList[i].nameVar+':=strtoint(value);';
                    textFileListStr.Add(tempStr);
                    end;
                 end;
      if not found then
                    textFileListStr.Add(line);
      end;

   closefile(fichier);
   textFileListStr.SaveToFile(fpath+fname+'-data/varunit.pas');
   FreeAndNil(textFileListStr);

    // build platform.cfg file
    fileName:=fpath+fname+'-data/platform.cfg';
    if FileExists(fileName) then
       DeleteFile(fileName);
    AssignFile(fichier,fileName);
    rewrite(fichier);
    writeln(fichier,'{$Define '+fplc.Replace(' ','_')+'}');
    CloseFile(fichier);
    // build runtime file
    // Transfer runtime file template to the project data folder
    if FileExists(fpath+fname+'-data/runtime.lpr') then
       DeleteFile(fpath+fname+'-data/runtime.lpr');
    runTimeTemplateFile:=ExtractFilePath(paramstr(0))+'/runtime/runtime.lpr';
    CopyFile(runTimeTemplateFile,fpath+fname+'-data/runtime.lpr');
    // add ladder bloc code to runtime file
    textFileListStr:=TStringList.Create;
    textFileListStr.Clear;
    assign(fichier,fpath+fname+'-data/runtime.lpr');
    reset(fichier);
    while not(eof(fichier)) do
       begin
       readln(fichier,line);
       if pos('//blocks',line)=0 then textFileListStr.Add(line)
          else
            begin
            textFileListStr.Add(line);
            for i:=0 to fBlocList.Count-1 do
              textFileListStr.add('{$I '''+fBlocList[i]+'.pas''}');
            end;
       end;
    closefile(fichier);
    textFileListStr.SaveToFile(fpath+fname+'-data/runtime.lpr');
    FreeAndNil(textFileListStr);
    // add simulator state file
    // Transfer simulator file template to the project data folder
    if FileExists(fpath+fname+'-data/simulator.cfg')
       then DeleteFile(fpath+fname+'-data/simulator.cfg');
    runTimeTemplateFile:=ExtractFilePath(paramstr(0))+'/runtime/simulator.cfg';
    CopyFile(runTimeTemplateFile,fpath+fname+'-data/simulator.cfg');
    // add pipe file for simulation
    // Transfer pipe file template to the project data folder
    if FileExists(fpath+fname+'-data/pipe.pas')
       then DeleteFile(fpath+fname+'-data/pipe.pas');
    runTimeTemplateFile:=ExtractFilePath(paramstr(0))+'/runtime/pipe.pas';
    CopyFile(runTimeTemplateFile,fpath+fname+'-data/pipe.pas');
    // add bitunit file for simulation
    // Transfer bitunit to the project data folder
    if FileExists(fpath+fname+'-data/bitunit.pas')
       then DeleteFile(fpath+fname+'-data/bitunit.pas');
    runTimeTemplateFile:=ExtractFilePath(paramstr(0))+'/runtime/bitunit.pas';
    CopyFile(runTimeTemplateFile,fpath+fname+'-data/bitunit.pas');
end;

procedure TProject.binaryBuildX86;
var
    compiler : TProcess;
begin
  if FileExists(fpath+fname+'-data/runtime') then
     DeleteFile(fpath+fname+'-data/runtime');
  compiler:=TProcess.create(nil);
  compiler.Executable:=ExtractFilePath(paramstr(0))+'/runtime/compileX86.sh';
  compiler.Parameters.add(ExtractFilePath(paramstr(0))+'/');
  compiler.Parameters.add(fpath+fname+'-data/',[]);
  compiler.Parameters.add(fname,[]);
  compiler.Options:=compiler.Options+[poWaitOnExit];
  compiler.Execute;
  compiler.free;
end;

procedure TProject.binaryBuildTarget;
var
    compiler   : TProcess;
    fichier    : text;
    chaine     : string;
begin
    if FileExists(fpath+fname+'-data/simulator.cfg')
       then begin
            Assign(fichier,fpath+fname+'-data/simulator.cfg');
            rewrite(fichier);
            writeln(fichier,'');
            CloseFile(fichier);
            end;
    if not DirectoryExists(fpath+fname+'-data/bin') then
       MkDir(fpath+fname+'-data/bin');
    compiler:=TProcess.create(nil);
    compiler.Executable:=ExtractFilePath(paramstr(0))+'/config/'+fplc.replace(' ','_')+'/compileTarget.sh';
    compiler.Parameters.add(ExtractFilePath(paramstr(0))+'/');
    compiler.Parameters.add(fpath+fname+'-data/',[]);
    compiler.Parameters.add(fplc.replace(' ','_'),[]);
    compiler.Options:=compiler.Options+[poWaitOnExit];
    compiler.Execute;
    compiler.free;
end;

end.


