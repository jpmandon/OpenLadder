unit xmlunit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,laz2_dom,laz2_xmlwrite,laz2_xmlread,usimplegraph,
  LadderSymbol,VariableUnit,mouse;

type TXmlObject = class
  protected

  public
  constructor create;
  procedure saveProjectXML;
  procedure loadProjectXML;
  procedure saveBlockXML(graphName:string;graphe : TEvsSimpleGraph);
  procedure loadBlocXML(graphe:TEvsSimpleGraph;filename : string);
  procedure saveClipboardXML(graphe : TEvsSimpleGraph);
  procedure loadClipboardXML(graphe : TEvsSimpleGraph;posx,posy : integer);
  end;

implementation

uses main;

constructor TXmlObject.create;
begin
  inherited;
end;

procedure TXmlObject.saveProjectXML;
var
  i                   : integer;
  documentXML         : TXMLDocument;
  rootNode,parentNode : TDOMNode;
  classNode,textNode  : TDOMNode;
  ioNode              : TDOMNode;
  nameNode            : TDOMNode;
  gpioNode,typeNode   : TDOMNode;
begin
 documentXML:=TXMLDocument.Create;
  rootNode:=documentXML.CreateElement('project');
  documentXML.AppendChild(rootNode);
  // name
  parentNode:=documentXML.CreateElement('name');
  classNode:=documentXML.CreateTextNode(form1.projectCurrent.fname);
  parentNode.AppendChild(classNode);
  rootNode.AppendChild(parentNode);
  // bloc
  parentNode:=documentXML.CreateElement('blocs');
  rootNode.AppendChild(parentNode);
  for i:=0 to form1.projectCurrent.fBlocList.Count-1 do
     begin
     classNode:=documentXML.CreateElement('bloc');
     textNode:=documentXML.CreateTextNode(form1.projectCurrent.fBlocList[i]);
     classNode.AppendChild(textNode);
     parentNode.AppendChild(classNode);
     end;
  // hardware
  parentNode:=documentXML.CreateElement('hardware');
  rootNode.AppendChild(parentNode);
  // PLC
  classNode:=documentXML.CreateElement('plc');
  textNode:=documentXML.CreateTextNode(form1.projectCurrent.fplc);
  classNode.AppendChild(textNode);
  parentNode.AppendChild(classNode);
  // IO
  for i:=0 to ioPlcList.Count-1 do
     begin
     ioNode:=documentXML.CreateElement('IO');
     parentNode.AppendChild(ioNode);
     nameNode:=documentXML.CreateElement('NAME');
     ioNode.AppendChild(nameNode);
     textNode:=documentXML.CreateTextNode(ioPlcList[i].nameVar);
     nameNode.AppendChild(textNode);
     gpioNode:=documentXML.CreateElement('GPIO');
     textNode:=documentXML.CreateTextNode(ioPlcList[I].gpio);
     ioNode.AppendChild(gpioNode);
     gpioNode.AppendChild(textNode);
     typeNode:=documentXML.CreateElement('TYPE');
     textNode:=documentXML.CreateTextNode(ioPlcList[I].typeVar);
     ioNode.AppendChild(typeNode);
     typeNode.AppendChild(textNode);
     typeNode:=documentXML.CreateElement('COMMENT');
     textNode:=documentXML.CreateTextNode(ioPlcList[I].comment);
     ioNode.AppendChild(typeNode);
     typeNode.AppendChild(textNode);
     end;
  // VAR
  for i:=0 to varList.Count-1 do
     begin
     ioNode:=documentXML.CreateElement('VAR');
     parentNode.AppendChild(ioNode);
     nameNode:=documentXML.CreateElement('NAME');
     ioNode.AppendChild(nameNode);
     textNode:=documentXML.CreateTextNode(varList[i].nameVar);
     nameNode.AppendChild(textNode);
     typeNode:=documentXML.CreateElement('TYPE');
     textNode:=documentXML.CreateTextNode(varList[I].typeVar);
     ioNode.AppendChild(typeNode);
     typeNode.AppendChild(textNode);
     typeNode:=documentXML.CreateElement('COMMENT');
     textNode:=documentXML.CreateTextNode(varList[I].comment);
     ioNode.AppendChild(typeNode);
     typeNode.AppendChild(textNode);
     end;
  // TIMER
  for i:=0 to timerList.Count-1 do
     begin
     ioNode:=documentXML.CreateElement('TIMER');
     parentNode.AppendChild(ioNode);
     nameNode:=documentXML.CreateElement('NAME');
     ioNode.AppendChild(nameNode);
     textNode:=documentXML.CreateTextNode(timerList[i].nameVar);
     nameNode.AppendChild(textNode);
     typeNode:=documentXML.CreateElement('PRESETON');
     textNode:=documentXML.CreateTextNode(timerList[i].presetON);
     ioNode.AppendChild(typeNode);
     typeNode.AppendChild(textNode);
     typeNode:=documentXML.CreateElement('PRESETOFF');
     textNode:=documentXML.CreateTextNode(timerList[i].presetOFF);
     ioNode.AppendChild(typeNode);
     typeNode.AppendChild(textNode);
     typeNode:=documentXML.CreateElement('TYPE');
     textNode:=documentXML.CreateTextNode(timerList[i].typeVar);
     ioNode.AppendChild(typeNode);
     typeNode.AppendChild(textNode);
     end;

  WriteXMLFile(documentXML,form1.projectCurrent.fpath+form1.projectCurrent.fname+'.prj');
  documentXML.Free;
end;

procedure TXmlObject.loadProjectXML;
var
  i,j,k                        : integer;
  strNode                      : string;
  nameVar,typeVar,gpio,comment : string;
  preset                       : string;
  presetON,presetOFF           : string;
  documentXML                  : TXMLDocument;
  filename                     : string;
begin
  ioPlcList.Clear;
  varList.clear;
  timerList.clear;
  documentXML:=TXMLDocument.create;
  readXMLFile(documentXML,form1.projectCurrent.fpath+form1.projectCurrent.fname+'.prj');
  with documentXML.DocumentElement.ChildNodes do
       begin
         for i:=0 to (count-1) do
             begin
             strNode:=item[i].NodeName;
               case strNode of
                    'name'  : ;
                    'blocs' : for j:=0 to item[i].ChildNodes.Count-1 do
                                  begin
                                  filename:=item[i].ChildNodes[j].FirstChild.NodeValue;
                                  if FileExists(form1.projectCurrent.fpath+form1.projectCurrent.fname+'-data/'+filename+'.xml') then
                                     form1.projectCurrent.fBlocList.add(filename);
                                  end;
                  'hardware': for j:=0 to item[i].ChildNodes.Count-1 do
                                  begin
                                    case item[i].ChildNodes.Item[j].NodeName of
                                         'plc' : form1.projectcurrent.fplc:=item[i].ChildNodes[j].FirstChild.NodeValue;
                                         'IO'  : begin
                                                 for k:=0 to item[i].ChildNodes[j].ChildNodes.Count-1 do
                                                     begin
                                                       case item[i].ChildNodes.Item[j].ChildNodes.Item[k].NodeName of
                                                            'NAME' : nameVar:=item[i].ChildNodes[j].ChildNodes[k].FirstChild.NodeValue;
                                                            'GPIO' : gpio:=item[i].ChildNodes[j].ChildNodes[k].FirstChild.NodeValue;
                                                            'TYPE' : typeVar:=item[i].ChildNodes[j].ChildNodes[k].FirstChild.NodeValue;
                                                         'COMMENT' : if item[i].ChildNodes[j].ChildNodes[k].FirstChild<>nil then
                                                                     comment:=item[i].ChildNodes[j].ChildNodes[k].FirstChild.NodeValue
                                                                     else comment:='';
                                                       end;
                                                     end;
                                                 ioPlcList.Add(TIOPlc.create(nameVar,typeVar,gpio,comment));
                                                 end;
                                         'VAR' : begin
                                                 for k:=0 to item[i].ChildNodes[j].ChildNodes.Count-1 do
                                                     begin
                                                       case item[i].ChildNodes[j].ChildNodes[k].NodeName of
                                                            'NAME' : nameVar:=item[i].ChildNodes[j].ChildNodes[k].FirstChild.NodeValue;
                                                            'TYPE' : typeVar:=item[i].ChildNodes[j].ChildNodes[k].FirstChild.NodeValue;
                                                         'COMMENT' : if item[i].ChildNodes[j].ChildNodes[k].FirstChild<>nil then
                                                                     comment:=item[i].ChildNodes[j].ChildNodes[k].FirstChild.NodeValue
                                                                     else comment:='';
                                                       end;
                                                     end;
                                                 varList.Add(TVariable.create(nameVar,typeVar,comment));
                                                 end;
                                       'TIMER' : begin
                                                 for k:=0 to item[i].ChildNodes[j].ChildNodes.Count-1 do
                                                     begin
                                                       case item[i].ChildNodes[j].ChildNodes[k].NodeName of
                                                            'NAME' : nameVar:=item[i].ChildNodes[j].ChildNodes[k].FirstChild.NodeValue;
                                                          'PRESET' : preset:=item[i].ChildNodes[j].ChildNodes[k].FirstChild.NodeValue;
                                                        'PRESETON' : begin
                                                                     presetON:=item[i].ChildNodes[j].ChildNodes[k].FirstChild.NodeValue;
                                                                     preset:=presetON;
                                                                     end;
                                                        'PRESETOFF': presetOFF:=item[i].ChildNodes[j].ChildNodes[k].FirstChild.NodeValue;
                                                          'TYPE'   : typeVar:=item[i].ChildNodes[j].ChildNodes[k].FirstChild.NodeValue;
                                                       end;
                                                     end;
                                                 timerList.Add(TTimerVar.create(nameVar,preset,presetON,presetOFF,typeVar));
                                                 end;

                                    end;
                                  end;
               end;

             end;
         form1.projectCurrent.updateProjectTree;
       end;
  documentXML.free;
end;

procedure TXmlObject.saveBlockXML(graphName:string;graphe : TEvsSimpleGraph);
var
  documentXML                         : TXMLDocument;
  rootNode,parentNode                 : TDOMNode;
  classNode                           : TDOMNode;
  startSymbolNode,symbolStartTypeNode : TDOMNode;
  endSymbolNode,symbolEndTypeNode     : TDOMNode;
  i,index                             : integer;
  filepath                            : string;
  filename                            : string;
begin
 // re-identifier tous les symboles du graphe
  if graphe.Objects.count>0 then
     for i:=0 to graphe.Objects.count-1 do
         graphe.Objects[i].ID:=i+1;
  documentXML:=TXMLDocument.Create;
 rootNode:=documentXML.CreateElement('bloc');
 documentXML.AppendChild(rootNode);
 // symbol
 index:=0;
 for i:=0 to graphe.Objects.Count-1 do
    if (graphe.Objects[i] is TSymbol) or
       (graphe.Objects[i] is TComment) then
     begin
     // création des entêtes de symboles
     rootnode:=documentXML.DocumentElement;
     parentNode:=documentXML.CreateElement('symbol');
     TDOMElement(parentNode).SetAttribute('id',inttostr(graphe.Objects[i].ID));
     rootNode.AppendChild(parentNode);
     // création des attributs de symboles
     parentNode:=documentXML.CreateElement('classe');
     classNode:=documentXML.CreateTextNode(graphe.Objects[i].ClassName);
     parentNode.AppendChild(classNode);
     rootNode.ChildNodes[index].AppendChild(parentNode);
     //--------------------------
     parentNode:=documentXML.CreateElement('centerX');
     classNode:=documentXML.CreateTextNode (inttostr(TEvsRectangularNode(graphe.Objects[i]).Left));
     parentNode.AppendChild(classNode);
     rootNode.ChildNodes[index].AppendChild(parentNode);
     //--------------------------
     parentNode:=documentXML.CreateElement('centerY');
     classNode:=documentXML.CreateTextNode(inttostr(TEvsRectangularNode(graphe.Objects[i]).Top));
     parentNode.AppendChild(classNode);
     rootNode.ChildNodes[index].AppendChild(parentNode);
     //--------------------------
     parentNode:=documentXML.CreateElement('allias');
     if graphe.Objects[i] is TSymbol then
        classNode:=documentXML.CreateTextNode(TSymbol(graphe.Objects[i]).allias)
     else
        classNode:=documentXML.CreateTextNode(TEvsRectangularNode(graphe.Objects[i]).text);
     parentNode.AppendChild(classNode);
     rootNode.ChildNodes.Item[index].AppendChild(parentNode);
     if graphe.Objects[i].ClassName<>'TComment' then
        begin
         //--------------------------
         parentNode:=documentXML.CreateElement('fonction');
         classNode:=documentXML.CreateTextNode(TSymbol(graphe.Objects[i]).fonction);
         parentNode.AppendChild(classNode);
         rootNode.ChildNodes[index].AppendChild(parentNode);

        if (graphe.Objects[i].ClassName='TMath') then
           begin
            //--------------------------
           parentNode:=documentXML.CreateElement('var1');
           classNode:=documentXML.CreateTextNode(TMath(graphe.Objects[i]).Var1);
           parentNode.AppendChild(classNode);
           rootNode.ChildNodes[index].AppendChild(parentNode);
           //--------------------------
           parentNode:=documentXML.CreateElement('var2');
           classNode:=documentXML.CreateTextNode(TMath(graphe.Objects[i]).Var2);
           parentNode.AppendChild(classNode);
           rootNode.ChildNodes[index].AppendChild(parentNode);
            //--------------------------
           parentNode:=documentXML.CreateElement('var3');
           classNode:=documentXML.CreateTextNode(TMath(graphe.Objects[i]).Var3);
           parentNode.AppendChild(classNode);
           rootNode.ChildNodes[index].AppendChild(parentNode);
           end;
         if (graphe.Objects[i].ClassName='TCompare') then
            begin
             //--------------------------
            parentNode:=documentXML.CreateElement('var1');
            classNode:=documentXML.CreateTextNode(TCompare(graphe.Objects[i]).Var1);
            parentNode.AppendChild(classNode);
            rootNode.ChildNodes[index].AppendChild(parentNode);
            //--------------------------
            parentNode:=documentXML.CreateElement('var2');
            classNode:=documentXML.CreateTextNode(TCompare(graphe.Objects[i]).Var2);
            parentNode.AppendChild(classNode);
            rootNode.ChildNodes[index].AppendChild(parentNode);
            end;
         if (graphe.Objects[i].ClassName='TStore') then
             begin
               //--------------------------
              parentNode:=documentXML.CreateElement('var1');
              classNode:=documentXML.CreateTextNode(TStore(graphe.Objects[i]).Var1);
              parentNode.AppendChild(classNode);
              rootNode.ChildNodes[index].AppendChild(parentNode);
              //--------------------------
              parentNode:=documentXML.CreateElement('var2');
              classNode:=documentXML.CreateTextNode(TStore(graphe.Objects[i]).Var2);
              parentNode.AppendChild(classNode);
              rootNode.ChildNodes[index].AppendChild(parentNode);
             end;
         if (graphe.Objects[i] is TTimerObject) then
            if (graphe.Objects[i] is TFlash) then
                 begin
                 //--------------------------
                 parentNode:=documentXML.CreateElement('presetON');
                 classNode:=documentXML.CreateTextNode(inttostr(TFlash(graphe.Objects[i]).presetON));
                 parentNode.AppendChild(classNode);
                 rootNode.ChildNodes[index].AppendChild(parentNode);
                 //--------------------------
                 parentNode:=documentXML.CreateElement('presetOFF');
                 classNode:=documentXML.CreateTextNode(inttostr(TFlash(graphe.Objects[i]).presetOFF));
                 parentNode.AppendChild(classNode);
                 rootNode.ChildNodes[index].AppendChild(parentNode);
                 end
                 else
                 begin
                 //--------------------------
                 parentNode:=documentXML.CreateElement('preset');
                 classNode:=documentXML.CreateTextNode(inttostr(TTimerObject(graphe.Objects[i]).preset));
                 parentNode.AppendChild(classNode);
                 rootNode.ChildNodes[index].AppendChild(parentNode);
                 end;
         end
         else
            begin
            //--------------------------
            parentNode:=documentXML.CreateElement('fonction');
            classNode:=documentXML.CreateTextNode('comment');
            parentNode.AppendChild(classNode);
            rootNode.ChildNodes[index].AppendChild(parentNode);
            //--------------------------
            parentNode:=documentXML.CreateElement('background');
            classNode:=documentXML.CreateTextNode(
              inttostr(TEvsRectangularNode(graphe.Objects[i]).Brush.Color));
            parentNode.AppendChild(classNode);
            rootNode.ChildNodes[index].AppendChild(parentNode);
            //--------------------------
            parentNode:=documentXML.CreateElement('text');
            classNode:=documentXML.CreateTextNode(
              inttostr(TEvsRectangularNode(graphe.Objects[i]).Font.Color));
            parentNode.AppendChild(classNode);
            rootNode.ChildNodes[index].AppendChild(parentNode);
            //--------------------------
            parentNode:=documentXML.CreateElement('width');
            classNode:=documentXML.CreateTextNode(
              inttostr(TEvsRectangularNode(graphe.Objects[i]).Width));
            parentNode.AppendChild(classNode);
            rootNode.ChildNodes[index].AppendChild(parentNode);
            end;
        index:=index+1;
        end;
  // wire
  for i:=0 to graphe.Objects.count-1 do
     if graphe.Objects.Items[i].IsLink then
        begin
        // création des entêtes de fils
        rootnode:=documentXML.DocumentElement;
        parentNode:=documentXML.CreateElement('wire');
        TDOMElement(parentNode).SetAttribute('id',inttostr(graphe.Objects[i].ID));
        rootNode.AppendChild(parentNode);

        // création des attributs de fils
        parentNode:=documentXML.CreateElement('startSymbol');
        startSymbolNode:=documentXML.CreateTextNode(inttostr(TConnexion(TEvsGraphLink(graphe.Objects[i]).HookedObjectOf(0)).symbolOwner.ID));
        parentNode.AppendChild(startSymbolNode);
        rootNode.ChildNodes[index].AppendChild(parentNode);
        parentNode:=documentXML.CreateElement('symbolStartType');
        if TConnexion(TEvsGraphLink(graphe.Objects.Items[i]).HookedObjectOf(0)).isInput then
           SymbolStartTypeNode:=documentXML.CreateTextNode('input')
           else
           SymbolStartTypeNode:=documentXML.CreateTextNode('output');
        parentNode.AppendChild(symbolStartTypeNode);
        rootNode.ChildNodes.Item[index].AppendChild(parentNode);
        parentNode:=documentXML.CreateElement('endSymbol');
        endSymbolNode:=documentXML.CreateTextNode(inttostr(TConnexion(TEvsGraphLink(graphe.Objects[i]).HookedObjectOf(1)).symbolOwner.ID));
        parentNode.AppendChild(endSymbolNode);
        rootNode.ChildNodes.Item[index].AppendChild(parentNode);
        parentNode:=documentXML.CreateElement('symbolEndType');
        if TConnexion(TEvsGraphLink(graphe.Objects[i]).HookedObjectOf(1)).isInput then
           symbolEndTypeNode:=documentXML.CreateTextNode('input')
           else
           symbolEndTypeNode:=documentXML.CreateTextNode('output');
        parentNode.AppendChild(symbolEndTypeNode);
        rootNode.ChildNodes.Item[index].AppendChild(parentNode);
        inc(index);
        end;
 filepath:=form1.projectCurrent.fpath+form1.projectCurrent.fname+'-data/';
 filename:=form1.projectCurrent.fpath+form1.projectCurrent.fname+'-data/'+graphName+'.xml';
 if not(DirectoryExists(filepath)) then
    MkDir(filepath);
 if FileExists(filename) then
    DeleteFile(filename);
 WriteXMLFile(documentXML,filename);
end;

procedure TXmlObject.loadBlocXML(graphe:TEvsSimpleGraph;filename : string);
var
  documentXML : TXMLDocument;
  i,j,n         : integer;
  symbolLink  : TEvsGraphLink;
  symbolType,symbolID,symbolClasse,symbolCenterX,symbolCenterY : string;
  symbolAllias,symbolFonction,symbolStart,symbolEnd            : string;
  var1,var2,var3                                               : String;
  preset,presetON,presetOFF                                    : string;
  backColor,textColor                                          : string;
  commentwidth                                                 : string;
  symbolStartType,symbolEndType                                : string;
  symbolStartobj,symbolEndobj                                  : TConnexion;
begin
     documentXML:=TXMLDocument.create;
     readXMLFile(documentXML,filename);
     with documentXML.DocumentElement.ChildNodes do
          begin
            for i:=0 to (count-1) do
               begin
                 symbolType:= item[i].NodeName;
                 symbolID  := item[i].Attributes.Item[0].NodeValue;
                 for j:=0 to (item[i].ChildNodes.count -1) do
                    begin
                      case item[i].ChildNodes.item[j].NodeName of
                      'classe'         : symbolClasse:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      'centerX'        : symbolCenterX:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      'centerY'        : symbolCenterY:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      'allias'         : symbolAllias :=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      'fonction'       : symbolFonction:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      'startSymbol'    : symbolStart:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      'symbolStartType': symbolStartType:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      'endSymbol'      : symbolEnd:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      'symbolEndType'  : symbolEndType:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      'var1'           : var1:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      'var2'           : var2:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      'var3'           : var3:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      'preset'         : preset:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      'presetON'       : presetON:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      'presetOFF'      : presetOFF:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      'background'     : backColor:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      'text'           : textColor:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      'width'          : commentwidth:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                      end;
                    end;
            if symbolType='symbol' then
               begin
               case symbolClasse of
                    'TBit'      : TBit.create(graphe,symbolFonction,symbolAllias);
                    'TFrontCoil': TFrontCoil.create(graphe,symbolFonction,symbolAllias);
                    'TCoil'     : TCoil.create(graphe,symbolFonction,symbolAllias);
                    'TPowerRail': TPowerRail.create(graphe,symbolFonction,symbolAllias);
                    'TCompare'  : TCompare.create(graphe,symbolFonction,var1,var2);
                    'TStore'    : TStore.create(graphe,symbolFonction,var1,var2);
                    'TComment'  : TComment.create(graphe,symbolFonction,symbolAllias);
                    'TMath'     : TMath.create(graphe,symbolFonction,var1,var2,var3);
                    'TTon'      : TTOn.create(graphe,symbolFonction,symbolAllias,strtoint(preset));
                    'TToff'     : TTOff.create(graphe,symbolFonction,symbolAllias,strtoint(preset));
                    'TFlash'    : TFlash.create(graphe,symbolFonction,symbolAllias,strtoint(presetON),strtoint(presetON));
                    end;
               if symbolClasse<>'TComment' then
                  begin
                  TSymbol(graphe.Objects[graphe.Objects.Count-1]).updatePosition(strtoint(symbolCenterX),strtoint(symbolCenterY));
                  TSymbol(graphe.Objects[graphe.Objects.Count-1]).ID:=strtoint(symbolID);
                  end
               else
                  begin
                  TComment(graphe.Objects[graphe.Objects.Count-1]).updatePosition(strtoint(symbolCenterX),strtoint(symbolCenterY));
                  TComment(graphe.Objects[graphe.Objects.Count-1]).ID:=strtoint(symbolID);
                  TComment(graphe.Objects[graphe.Objects.Count-1]).Brush.Color:=strtoint(backColor);
                  TComment(graphe.Objects[graphe.Objects.Count-1]).Font.Color:=strtoint(textColor);
                  if commentwidth<>'' then
                     TEvsRectangularNode(graphe.Objects[graphe.Objects.Count-1]).Width:=strtoint(commentwidth);
                  end;
               end;
            if symbolType='wire' then
               begin
               graphe.CommandMode:=cmInsertLink;
               for j:=0 to graphe.Objects.Count-1 do
                  begin
                  if (graphe.Objects[j] is TSymbol) and
                     (graphe.Objects[j].ID=strtoint(symbolStart))
                     then
                     symbolStartobj:=TSymbol(graphe.Objects[j]).symbolOutput;
                  if (graphe.Objects[j] is TSymbol) and
                     (graphe.Objects[j].ID=strtoint(symbolEnd)) then
                     symbolEndobj:=TSymbol(graphe.Objects[j]).symbolInput;
                  end;
               symbolLink:=TEvsGraphLink.Create(graphe);
               symbolLink.Link(symbolStartobj,symbolEndobj);
               end;

            end;
          end;
     documentXML.free;
end;

procedure TXmlObject.saveClipboardXML(graphe : TEvsSimpleGraph);
var
  documentXML                         : TXMLDocument;
  rootNode,parentNode                 : TDOMNode;
  classNode                           : TDOMNode;
  startSymbolNode,symbolStartTypeNode : TDOMNode;
  endSymbolNode,symbolEndTypeNode     : TDOMNode;
  i,index                             : integer;
begin
  // re-identifier tous les symboles du graphe
  if graphe.Objects.count>0 then
     for i:=0 to graphe.Objects.count-1 do
        begin
        graphe.Objects[i].ID:=i+1;
        end;
  documentXML:=TXMLDocument.Create;
  rootNode:=documentXML.CreateElement('bloc');
  documentXML.AppendChild(rootNode);
  // symbol
  index:=0;
  for i:=0 to graphe.SelectedObjects.Count-1 do
    if graphe.SelectedObjects[i].IsNode then
      begin
      // création des entêtes de symboles
      rootnode:=documentXML.DocumentElement;
      parentNode:=documentXML.CreateElement('symbol');
      TDOMElement(parentNode).SetAttribute('id',inttostr(graphe.SelectedObjects[i].ID));
      rootNode.AppendChild(parentNode);
      // création des attributs de symboles
      parentNode:=documentXML.CreateElement('classe');
      classNode:=documentXML.CreateTextNode(graphe.SelectedObjects[i].ClassName);
      parentNode.AppendChild(classNode);
      rootNode.ChildNodes[index].AppendChild(parentNode);
      //--------------------------
      parentNode:=documentXML.CreateElement('centerX');
      classNode:=documentXML.CreateTextNode (inttostr(TEvsRectangularNode(graphe.SelectedObjects[i]).Left));
      parentNode.AppendChild(classNode);
      rootNode.ChildNodes[index].AppendChild(parentNode);
      //--------------------------
      parentNode:=documentXML.CreateElement('centerY');
      classNode:=documentXML.CreateTextNode(inttostr(TEvsRectangularNode(graphe.SelectedObjects[i]).Top));
      parentNode.AppendChild(classNode);
      rootNode.ChildNodes[index].AppendChild(parentNode);
      //--------------------------
      parentNode:=documentXML.CreateElement('allias');
      classNode:=documentXML.CreateTextNode(TEvsRectangularNode(graphe.SelectedObjects[i]).text);
      parentNode.AppendChild(classNode);
      rootNode.ChildNodes[index].AppendChild(parentNode);

      if graphe.SelectedObjects[i].ClassName<>'TComment' then
         begin
          //--------------------------
          parentNode:=documentXML.CreateElement('fonction');
          classNode:=documentXML.CreateTextNode(TSymbol(graphe.SelectedObjects[i]).fonction);
          parentNode.AppendChild(classNode);
          rootNode.ChildNodes[index].AppendChild(parentNode);

          if (graphe.SelectedObjects[i].ClassName='TCompare')
             or (graphe.SelectedObjects[i].ClassName='TStore') then
             begin
              //--------------------------
             parentNode:=documentXML.CreateElement('var1');
             classNode:=documentXML.CreateTextNode(TCompare(graphe.SelectedObjects[i]).Var1);
             parentNode.AppendChild(classNode);
             rootNode.ChildNodes[index].AppendChild(parentNode);
             //--------------------------
             parentNode:=documentXML.CreateElement('var2');
             classNode:=documentXML.CreateTextNode(TCompare(graphe.SelectedObjects[i]).Var2);
             parentNode.AppendChild(classNode);
             rootNode.ChildNodes[index].AppendChild(parentNode);
             end;
          if (graphe.SelectedObjects[i].ClassName='TMath') then
             begin
              //--------------------------
             parentNode:=documentXML.CreateElement('var1');
             classNode:=documentXML.CreateTextNode(TMath(graphe.SelectedObjects[i]).Var1);
             parentNode.AppendChild(classNode);
             rootNode.ChildNodes[index].AppendChild(parentNode);
             //--------------------------
             parentNode:=documentXML.CreateElement('var2');
             classNode:=documentXML.CreateTextNode(TMath(graphe.SelectedObjects[i]).Var2);
             parentNode.AppendChild(classNode);
             rootNode.ChildNodes[index].AppendChild(parentNode);
              //--------------------------
             parentNode:=documentXML.CreateElement('var3');
             classNode:=documentXML.CreateTextNode(TMath(graphe.SelectedObjects[i]).Var3);
             parentNode.AppendChild(classNode);
             rootNode.ChildNodes[index].AppendChild(parentNode);
             end;
             if (graphe.SelectedObjects[i] is TTimerObject) then
                if (graphe.SelectedObjects[i] is TFlash) then
                   begin
                   //--------------------------
                   parentNode:=documentXML.CreateElement('presetON');
                   classNode:=documentXML.CreateTextNode(inttostr(TFlash(graphe.SelectedObjects[i]).presetON));
                   parentNode.AppendChild(classNode);
                   rootNode.ChildNodes[index].AppendChild(parentNode);
                   //--------------------------
                   parentNode:=documentXML.CreateElement('presetOFF');
                   classNode:=documentXML.CreateTextNode(inttostr(TFlash(graphe.SelectedObjects[i]).presetOFF));
                   parentNode.AppendChild(classNode);
                   rootNode.ChildNodes[index].AppendChild(parentNode);
                   end
                   else
                   begin
                   //--------------------------
                   parentNode:=documentXML.CreateElement('preset');
                   classNode:=documentXML.CreateTextNode(inttostr(TTimerObject(graphe.SelectedObjects[i]).preset));
                   parentNode.AppendChild(classNode);
                   rootNode.ChildNodes[index].AppendChild(parentNode);
                   end;
          end
          else
             begin
             //--------------------------
             parentNode:=documentXML.CreateElement('fonction');
             classNode:=documentXML.CreateTextNode('comment');
             parentNode.AppendChild(classNode);
             rootNode.ChildNodes[index].AppendChild(parentNode);
             //--------------------------
             parentNode:=documentXML.CreateElement('background');
             classNode:=documentXML.CreateTextNode(
               inttostr(TEvsRectangularNode(graphe.SelectedObjects[i]).Brush.Color));
             parentNode.AppendChild(classNode);
             rootNode.ChildNodes[index].AppendChild(parentNode);
             //--------------------------
             parentNode:=documentXML.CreateElement('text');
             classNode:=documentXML.CreateTextNode(
               inttostr(TEvsRectangularNode(graphe.SelectedObjects[i]).Font.Color));
             parentNode.AppendChild(classNode);
             rootNode.ChildNodes[index].AppendChild(parentNode);
             //--------------------------
             parentNode:=documentXML.CreateElement('width');
             classNode:=documentXML.CreateTextNode(
               inttostr(TEvsRectangularNode(graphe.SelectedObjects[i]).Width));
             parentNode.AppendChild(classNode);
             rootNode.ChildNodes[index].AppendChild(parentNode);
             end;
         inc(index);
         end;
   // wire
   for i:=0 to graphe.SelectedObjects.count-1 do
      if graphe.SelectedObjects[i].IsLink then
         begin
         // création des entêtes de fils
         rootnode:=documentXML.DocumentElement;
         parentNode:=documentXML.CreateElement('wire');
         TDOMElement(parentNode).SetAttribute('id',inttostr(graphe.SelectedObjects[i].ID));
         rootNode.AppendChild(parentNode);

         // création des attributs de fils
         parentNode:=documentXML.CreateElement('startSymbol');
         startSymbolNode:=documentXML.CreateTextNode(inttostr(TConnexion(TEvsGraphLink(graphe.SelectedObjects[i]).HookedObjectOf(0)).symbolOwner.ID));
         parentNode.AppendChild(startSymbolNode);
         rootNode.ChildNodes[index].AppendChild(parentNode);
         parentNode:=documentXML.CreateElement('symbolStartType');
         if TConnexion(TEvsGraphLink(graphe.SelectedObjects.Items[i]).HookedObjectOf(0)).isInput then
            SymbolStartTypeNode:=documentXML.CreateTextNode('input')
            else
            SymbolStartTypeNode:=documentXML.CreateTextNode('output');
         parentNode.AppendChild(symbolStartTypeNode);
         rootNode.ChildNodes.Item[index].AppendChild(parentNode);
         parentNode:=documentXML.CreateElement('endSymbol');
         endSymbolNode:=documentXML.CreateTextNode(inttostr(TConnexion(TEvsGraphLink(graphe.SelectedObjects[i]).HookedObjectOf(1)).symbolOwner.ID));
         parentNode.AppendChild(endSymbolNode);
         rootNode.ChildNodes[index].AppendChild(parentNode);
         parentNode:=documentXML.CreateElement('symbolEndType');
         if TConnexion(TEvsGraphLink(graphe.SelectedObjects.Items[i]).HookedObjectOf(1)).isInput then
            symbolEndTypeNode:=documentXML.CreateTextNode('input')
            else
            symbolEndTypeNode:=documentXML.CreateTextNode('output');
         parentNode.AppendChild(symbolEndTypeNode);
         rootNode.ChildNodes.Item[index].AppendChild(parentNode);
         inc(index);
         end;
  if not(DirectoryExists(form1.projectCurrent.fpath+form1.projectCurrent.fname+'-data/')) then
     MkDir(form1.projectCurrent.fpath+form1.projectCurrent.fname+'-data/');
  WriteXMLFile(documentXML,form1.projectCurrent.fpath+form1.projectCurrent.fname+'-data/'+'clipboard.xml');
 end;

procedure TXmlObject.loadClipboardXML(graphe : TEvsSimpleGraph;posx,posy : integer);
var
  documentXML : TXMLDocument;
  i,j         : integer;
  symbolLink  : TEvsGraphLink;
  symbolType,symbolID,symbolClasse,symbolCenterX,symbolCenterY : string;
  symbolAllias,symbolFonction,symbolStart,symbolEnd            : string;
  var1,var2,var3                                               : String;
  preset,presetON,presetOFF                                    : string;
  backColor,textColor                                          : string;
  commentwidth                                                 : string;
  symbolStartType,symbolEndType                                : string;
  symbolStartobj,symbolEndobj                                  : TConnexion;
  offsetx,offsety                                              : integer;
  maxLeftXpos                                                  : integer=-1;
  pastedArray                                                  : array [0..255] of integer;
  indexPastedArray                                             : integer;
  topY                                                         : integer;
begin
     indexPastedArray:=0;
     documentXML:=TXMLDocument.create;
     readXMLFile(documentXML,form1.projectCurrent.fpath+form1.projectCurrent.fname+'-data/clipboard.xml');
     with documentXML.DocumentElement.ChildNodes do
          begin
            for i:=0 to (count-1) do
                  begin
                  symbolType:= item[i].NodeName;
                  symbolID  := item[i].Attributes[0].NodeValue;
                  for j:=0 to (item[i].ChildNodes.count -1) do
                  begin
                    case item[i].ChildNodes[j].NodeName of
                    'classe'         : symbolClasse:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                    'centerX'        : symbolCenterX:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                    'centerY'        : begin
                                       symbolCenterY:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                                       if strtoint(symbolCenterY)<posy then offsetY:=posy-strtoint(symbolCenterY);
                                       if strtoint(symbolCenterY)>posy then offsetY:=-(strtoint(symbolCenterY)-posy);
                                       end;
                    'allias'         : symbolAllias :=Item[i].ChildNodes[j].FirstChild.NodeValue;
                    'fonction'       : symbolFonction:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                    'startSymbol'    : symbolStart:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                    'symbolStartType': symbolStartType:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                    'endSymbol'      : symbolEnd:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                    'symbolEndType'  : symbolEndType:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                    'var1'           : var1:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                    'var2'           : var2:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                    'var3'           : var3:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                    'preset'         : preset:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                    'presetON'       : presetON:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                    'presetOFF'      : presetOFF:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                    'background'     : backColor:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                    'text'           : textColor:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                    'width'          : commentwidth:=Item[i].ChildNodes[j].FirstChild.NodeValue;
                    end;
                  end;
                  if (maxLeftXpos=-1) or (strtoint(symbolCenterX)<maxLeftXpos) then
                     begin
                     maxLeftXpos:=strtoint(symbolCenterX);
                     if maxLeftXpos<posx then offsetX:=-(posx-maxLeftXpos);
                     if maxLeftXpos>posx then offsetx:=maxLeftXpos-posx;
                     end;

                  if symbolType='symbol' then
                   begin
                   case symbolClasse of
                        'TBit'      : TBit.create(graphe,symbolFonction,symbolAllias);
                        'TFrontCoil': TFrontCoil.create(graphe,symbolFonction,symbolAllias);
                        'TCoil'     : TCoil.create(graphe,symbolFonction,symbolAllias);
                        'TPowerRail': TPowerRail.create(graphe,symbolFonction,symbolAllias);
                        'TCompare'  : TCompare.create(graphe,symbolFonction,var1,var2);
                        'TStore'    : TStore.create(graphe,symbolFonction,var1,var2);
                        'TComment'  : TComment.create(graphe,symbolFonction,symbolAllias);
                        'TMath'     : TMath.create(graphe,symbolFonction,var1,var2,var3);
                        'TTon'      : TTOn.create(graphe,symbolFonction,symbolAllias,strtoint(preset));
                        'TToff'     : TTOff.create(graphe,symbolFonction,symbolAllias,strtoint(preset));
                        'TFlash'    : TFlash.create(graphe,symbolFonction,symbolAllias,strtoint(presetON),strtoint(presetOFF));
                        end;

                   inc(indexPastedArray);
                   pastedArray[indexPastedArray-1]:=graphe.Objects.Count-1;

                   if symbolClasse<>'TComment' then
                      begin
                      TSymbol(graphe.Objects[graphe.Objects.Count-1]).updatePosition(strtoint(symbolCenterX),strtoint(symbolCenterY));
                      TSymbol(graphe.Objects[graphe.Objects.Count-1]).ID:=strtoint(symbolID);
                      end
                   else
                      begin
                      TComment(graphe.Objects[graphe.Objects.Count-1]).updatePosition(strtoint(symbolCenterX),strtoint(symbolCenterY));
                      TComment(graphe.Objects[graphe.Objects.Count-1]).ID:=strtoint(symbolID);
                      TComment(graphe.Objects[graphe.Objects.Count-1]).Brush.Color:=strtoint(backColor);
                      TComment(graphe.Objects[graphe.Objects.Count-1]).Font.Color:=strtoint(textColor);
                      if commentwidth<>'' then
                         TEvsRectangularNode(graphe.Objects[graphe.Objects.Count-1]).Width:=strtoint(commentwidth);
                      end;
                   end;
                  if symbolType='wire' then
                     begin
                     graphe.CommandMode:=cmInsertLink;
                     for j:=0 to graphe.Objects.Count-1 do
                        begin
                        if (graphe.Objects[j] is TSymbol) and
                           (graphe.Objects[j].ID=strtoint(symbolStart)) then
                              symbolStartobj:=TSymbol(graphe.Objects[j]).symbolOutput;
                        if (graphe.Objects[j] is TSymbol) and
                           (graphe.Objects[j].ID=strtoint(symbolEnd)) then
                           symbolEndobj:=TSymbol(graphe.Objects[j]).symbolInput;
                        end;
                     symbolLink:=TEvsGraphLink.Create(graphe);
                     symbolLink.Link(symbolStartobj,symbolEndobj);
                     end;

                  end;

          end;
          // find Y min symbol
          topY:=20000;
          for i:=0 to indexPastedArray-1 do
              if graphe.Objects[pastedArray[i]].BoundsRect.Top<topY then
                 topY:=graphe.Objects[pastedArray[i]].BoundsRect.Top;
          offsety:=posy-topy;
          // update x and y symbol position
          for i:=0 to indexPastedArray-1 do
             begin
             if graphe.Objects[pastedArray[i]] is TSymbol then
                 TSymbol(graphe.Objects[pastedArray[i]]).updatePosition(
                 graphe.Objects[pastedArray[i]].BoundsRect.Left-offsetx-37,
                 graphe.Objects[pastedArray[i]].BoundsRect.Top+offsety);
             if graphe.Objects[pastedArray[i]] is TComment then
                 TComment(graphe.Objects[pastedArray[i]]).updatePosition(
                 graphe.Objects[pastedArray[i]].BoundsRect.Left-offsetX-(graphe.Objects[pastedArray[i]].BoundsRect.width*2),
                 graphe.Objects[pastedArray[i]].BoundsRect.Top-(graphe.Objects[pastedArray[i]].BoundsRect.Height)+offsetY);
             end;

          documentXML.free;

end;

end.

