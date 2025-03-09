unit lad2pas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,usimplegraph,laddersymbol,fgl,forms;

type

  { TSymbolList }

  TSymbolList = class(specialize TFPGObjectList<TSymbol>)
       constructor Create(aFreeObjects: Boolean);
    end;

type

{ TladToPas }

 TladToPas = class
  protected
    listeSymbolRung  : TSymbolList;
    fcopieGraphe     : TEvsSimpleGraph;
    fworkGraph       : TEvsSimpleGraph;
    ffilename        : string;
  public
    constructor create(workGraphe,copieGraphe:TEvsSimpleGraph);
    constructor create;
    destructor Destroy; override;
    // utilitaires
    procedure startConvert(graphName:string);
    procedure getSymbolRung(terminal : TSymbol);
    function findAndReduceSerial:boolean;
    function findAndReduceParrallel:boolean;
    function tryToOptimise(var equationList:TStringList):TStringList;
  end;

implementation

uses xmlunit,main;

{ TSymbolList }

constructor TSymbolList.Create(aFreeObjects: Boolean);
begin
  inherited Create(aFreeObjects);
end;

{ TLAD2PAS }

constructor TladToPas.create(workGraphe,copieGraphe:TEvsSimpleGraph);
begin
     listeSymbolRung:=TSymbolList.create(false);
     fworkGraph:=workGraphe;
     fcopieGraphe:=copieGraphe;
end;

constructor TladToPas.create;
begin

end;

destructor TladToPas.Destroy;
begin
     freeandnil(listeSymbolRung);
     inherited;
end;

procedure TladToPas.startConvert(graphName:string);
var
    i,j,index      : integer;
    nbGraphObject  : integer;
    matchSerial    : boolean=true;
    matchParrallel : boolean=true;
    terminalList   : TSymbolList;
    terminal       : TSymbol;
    virtualContact : TSymbol;
    equation       : string;
    xmlObject      : TXmlObject;
    linkList       : TEvsGraphObjectList;
    listEquation   : TStringList;
    filename       : String;
    fichier        : text;
begin
// build terminal list for workGraph
terminalList:=TSymbolList.Create(false);
for i:=0 to fworkGraph.ObjectsCount()-1 do
   if fworkGraph.Objects[i] is TSymbol then
      if TSymbol(fworkGraph.Objects[i]).isTerminal then
         terminalList.Add(TSymbol(fworkGraph.Objects[i]));
linkList := TEvsGraphObjectList.Create;
while terminalList.Count>0 do
   begin
          // build symbol list for current rung
          getSymbolRung(terminalList[0]);

          // build list of link beetween rung symbols
          for i:=0 to listeSymbolRung.Count-1 do
             begin
             if listeSymbolRung[i].symbolInput<>nil then
                for j:=0 to TConnexion(listeSymbolRung[i].symbolInput).LinkInputCount-1 do
                    linkList.add(TConnexion(listeSymbolRung[i].symbolInput).LinkInputs[j]);
             end;

          // make a copy of symbol in workgraph with the clipboard
          for i:=0 to listeSymbolRung.Count-1 do
             listeSymbolRung[i].Selected:=true;
          for i:=0 to linkList.Count-1 do
             linkList[i].Selected:=true;

          xmlObject:=TXmlObject.create;
          xmlObject.saveClipboardXML(fworkGraph);
          xmlObject.loadClipboardXML(fcopieGraphe,100,100);
          FreeAndNil(xmlObject);
          // replace variable with space in name with _
          for i:=0 to fcopieGraphe.ObjectsCount-1 do
             if fcopieGraphe.Objects[i].IsNode then
              if (fcopieGraphe.Objects[i] is TSymbol) and
                 not(fcopieGraphe.Objects[i] is TPowerRail) and
                    not(fcopieGraphe.Objects[i] is TVirtual) then
                    for j:=0 to TSymbol(fcopieGraphe.Objects[i]).getVarList.Count-1 do
                       if TSymbol(fcopieGraphe.Objects[i]).getVarList[j].IndexOf(' ')<> -1 then
                          TSymbol(fcopieGraphe.Objects[i]).SetVar(j,TSymbol(fcopieGraphe.Objects[i]).getVarList[j].Replace(' ','_'));

          // update listeSymbolRung for new graphe
          listeSymbolRung.Clear;
          for i:=0 to fcopieGraphe.ObjectsCount()-1 do
             if fcopieGraphe.Objects[i] is TSymbol then
                listeSymbolRung.Add(TSymbol(fcopieGraphe.Objects[i]));

          matchSerial:=true;
          matchParrallel:=true;
          // reduce and simplify
          while (matchSerial or matchParrallel) do
            begin
              // serial reduction
              matchSerial:=findAndReduceSerial;
              // parrallel reduction
              matchParrallel:=findAndReduceParrallel;
              application.ProcessMessages;
            end;

          // delete link in workGraph
          while TConnexion(terminalList[0].symbolInput).LinkInputCount>0 do
              begin
              index:=fworkGraph.Objects.IndexOf(TConnexion(terminalList[0].symbolInput).LinkInputs[0]);
              fworkGraph.Objects.Delete(index);
              end;
          // delete terminal in workGraph
          index:=fworkGraph.Objects.IndexOf(terminalList[0]);
          // remove terminal from list and graph
          terminalList.delete(0);
          fworkGraph.Objects.delete(index);
          // clear link list for next rung
          linkList.clear;

         end;

// build equation list

nbGraphObject:=0;
listEquation:=TStringList.Create;
equation:='// '+graphName;
listEquation.add(equation);
while nbGraphObject<fcopieGraphe.ObjectsCount() do
   begin
   equation:='';
   if (fcopieGraphe.Objects[nbGraphObject].isNode) and
      (fcopieGraphe.Objects[nbGraphObject] is TSymbol) and
      (TSymbol(fcopieGraphe.Objects[nbGraphObject]).isTerminal) then
            begin
             terminal:=TSymbol(fcopieGraphe.Objects[nbGraphObject]);
             equation:=equation+terminal.allias+terminal.codeBefore;
             virtualContact:=TConnexion(terminal.symbolInput.LinkInputs[0].HookedObjectOf(0)).symbolOwner;
             if virtualContact.isVirtual then
                equation:=terminal.codeBefore+virtualContact.equation+terminal.codeAfter
             else if virtualContact.ClassName<>'TPowerRail' then
                equation:=terminal.codeBefore+virtualContact.equation+terminal.codeAfter;
             if virtualContact.ClassName='TPowerRail' then
                equation:=terminal.codeBefore+'(TRUE)'+terminal.codeAfter;
             listEquation.add(equation);
            end;
      inc(nbGraphObject);
   end;

// try to optimise code

listEquation:=tryToOptimise(listEquation);

// save code

filename := form1.projectCurrent.fpath+form1.projectCurrent.fname+'-data/'+
            graphname+'.pas';
if FileExists(filename) then
   DeleteFile(filename);
AssignFile(fichier,filename);
Rewrite(fichier);
for i:=0 to listEquation.Count-1 do
   writeln(fichier,listEquation[i]);
CloseFile(fichier);

end;

//-------------------------------------------------------------------
// build list symbol for rung
//-------------------------------------------------------------------
procedure TladToPas.getSymbolRung(terminal : TSymbol);
var
    i,j,k           : integer;
    listeAmont      : TSymbolList;
    duplicatedSymbol: boolean;
begin
listeAmont:=TSymbolList.Create(false);
listeSymbolRung.Clear;
listeAmont.Add(terminal);
listeSymbolRung.add(terminal);
while listeAmont.Count>0 do
      begin
      i:=0;
      while i<listeAmont.count do
         begin
         for j:=0 to listeAmont[i].symbolInput.LinkInputCount-1 do
            begin
            if TConnexion(listeAmont[i].symbolInput.LinkInputs[j].HookedObjectOf(0)).symbolOwner.ClassName<>'TPowerRail' then
               begin
               k:=0;
               duplicatedSymbol:=false;
               while k<listeAmont.Count do
                     begin
                     if listeAmont[k]=TConnexion(listeAmont[i].symbolInput.LinkInputs[j].HookedObjectOf(0)).symbolOwner then
                        duplicatedSymbol:=true;
                     k:=k+1;
                     end;
               if not(duplicatedSymbol) then
                 begin
                 listeAmont.Add(TConnexion(listeAmont[i].symbolInput.LinkInputs[j].HookedObjectOf(0)).symbolOwner);
                 listeSymbolRung.Add(TSymbol(TConnexion(listeAmont[i].symbolInput.LinkInputs[j].HookedObjectOf(0)).symbolOwner));
                 end;
               end
               else
               begin
               if listeSymbolRung.IndexOf(TConnexion(listeAmont[i].symbolInput.LinkInputs[j].HookedObjectOf(0)).symbolOwner)<0 then
                  begin
                       listeSymbolRung.add(TSymbol(TConnexion(listeAmont[i].symbolInput.LinkInputs[j].HookedObjectOf(0)).symbolOwner));
                  end;
               end;
            end;
          listeAmont.Delete(i);
          i:=i+1;
          end;

      if listeAmont.Count=1 then
         if listeAmont[0].ClassName='TPowerRail' then listeAmont.Clear;
      end;

end;

//-------------------------------------------------------------------
// recherche et réduction des symboles en serie
//-------------------------------------------------------------------
function TladToPas.findAndReduceSerial:boolean;
var
    i              : integer;
    symboleAnalyse : TSymbol;
    symboleConnecte: TSymbol;
    virtualSymbole : TVirtual;
    temp           : string;
begin
i:=0;
while i<listeSymbolRung.Count do
   begin
   symboleAnalyse:=listeSymbolRung[i];
   if (not(symboleAnalyse.isTerminal) and (symboleAnalyse.ClassName<>'TPowerRail')) then
        // si il n'y a qu'un fil à l'entrée du symbole
        if symboleAnalyse.symbolInput.LinkInputCount=1 then
           begin
           symboleConnecte:=Tconnexion(symboleAnalyse.symbolInput.LinkInputs[0].HookedObjectOf(0)).symbolOwner;
           // si le symbole connecté n'est pas un powerRail
           if (symboleConnecte.ClassName<>'TPowerRail') and
              (symboleConnecte.symbolOutput.LinkOutputCount=1) then
              begin
              // créer le symbole equivalent
              virtualSymbole:=TVirtual.create(fcopieGraphe,'contactNO',symboleAnalyse.allias+'&'+symboleConnecte.allias);
              listeSymbolRung.Add(virtualSymbole);
              // check system var and bit
              temp:=symboleConnecte.equation;
              virtualSymbole.equation:=('('+symboleAnalyse.equation+' AND '+temp+')');
              // fabriquer les anciennes connexions
              // connexions de sortie
              while symboleAnalyse.symbolOutput.LinkOutputCount>0 do
                 // creer le symbole virtuel equivalent
                 begin
                 fcopieGraphe.InsertLink(virtualSymbole.symbolOutput,
                                          Tconnexion(symboleAnalyse.symbolOutput.LinkOutputs[0].HookedObjectOf(1)).symbolOwner.symbolInput);
                 fcopieGraphe.Objects.Remove(symboleAnalyse.symbolOutput.LinkOutputs[0]);
                 end;
              // supprimer le conducteur entre les deux symboles en serie
              fcopieGraphe.Objects.Remove(symboleAnalyse.symbolInput.LinkInputs[0]);
              // supprimer les connexions du symbole 1
              fcopieGraphe.Objects.Remove(symboleAnalyse.symbolOutput);
              // supprimer le symbole 1
              listeSymbolRung.Remove(symboleAnalyse);
              fcopieGraphe.Objects.Remove(symboleAnalyse);
              // connexions d'entree
              while symboleConnecte.symbolInput.LinkInputCount>0 do
                 // creer le nouveau lien et supprimer l'ancien
                 begin
                 fcopieGraphe.InsertLink(TConnexion(symboleConnecte.symbolInput.LinkInputs[0].HookedObjectOf(0)).symbolOwner.symbolOutput,
                                        virtualSymbole.symbolInput );
                 fcopieGraphe.Objects.Remove(symboleConnecte.symbolInput.LinkInputs[0]);
                 end;
              // supprimer les connexions du symbole 2
              fcopieGraphe.Objects.Remove(symboleConnecte.symbolInput);
              fcopieGraphe.Objects.Remove(symboleConnecte.symbolOutput);
              // supprimer le symbole 2
              listeSymbolRung.remove(symboleConnecte);
              fcopieGraphe.Objects.Remove(symboleConnecte);
              findAndReduceSerial:=true;
              end;
           end;
   i:=i+1;
   end;
findAndReduceSerial:=false;
end;

//-------------------------------------------------------------------
// recherche et réduction des symboles en parrallele
//-------------------------------------------------------------------
function TladToPas.findAndReduceParrallel:boolean;
var
    i,j,k           : integer;
    n               : integer;
    symboleAnalyse  : TSymbol;
    tenant1,tenant2 : TSymbol;
    listeParrallele : TSymbolList;
    virtualSymbole  : TVirtual;
    connexion : TConnexion;
    lien      : TEvsGraphLink;
begin
listeParrallele:=TSymbolList.create(false);
i:=0;
while i<listeSymbolRung.Count do
   begin
  symboleAnalyse:=listeSymbolRung[i];
   if symboleAnalyse.ClassName<>'TPowerRail' then
      if symboleAnalyse.symbolInput.LinkInputCount>1 then
         begin
         // faire une liste des symboles en //
         for j:=0 to symboleAnalyse.symbolInput.LinkInputCount-1 do
            listeParrallele.add(Tconnexion(symboleAnalyse.symbolInput.LinkInputs[j].HookedObjectOf(0)).symbolOwner);
         // chercher les tenants communs
         j:=0;
         while j<listeParrallele.Count do
             begin
             tenant1:=TConnexion(listeParrallele[j].symbolInput.LinkInputs[0].HookedObjectOf(0)).symbolOwner;
             for k:=j to listeParrallele.Count-1 do
                begin
                tenant2:=TConnexion(listeParrallele[k].symbolInput.LinkInputs[0].HookedObjectOf(0)).symbolOwner;
                if (listeParrallele[j]<>listeParrallele[k]) and (tenant1=tenant2) then
                   // les tenants sont communs
                   begin
                   // créer le symbole equivalent
                   virtualSymbole:=TVirtual.create(fcopieGraphe,'contactNO',listeParrallele[j].allias+'+'+listeParrallele[k].allias);
                   listeSymbolRung.Add(virtualSymbole);
                   virtualSymbole.equation:='('+listeParrallele[j].equation+' OR '+listeParrallele[k].equation+')';
                   // fabriquer les anciennes connexions
                   // connexions de sortie
                   fcopieGraphe.InsertLink(virtualSymbole.symbolOutput,symboleAnalyse.symbolInput);
                   n:=0;
                   while n<symboleAnalyse.symbolInput.LinkInputCount-1 do
                      begin
                      if TConnexion(symboleAnalyse.symbolInput.LinkInputs[n].HookedObjectOf(0)).symbolOwner=listeParrallele[j] then
                         fcopieGraphe.Objects.remove(symboleAnalyse.symbolInput.LinkInputs[n]);
                      if TConnexion(symboleAnalyse.symbolInput.LinkInputs[n].HookedObjectOf(0)).symbolOwner=listeParrallele[k] then
                         fcopieGraphe.Objects.remove(symboleAnalyse.symbolInput.LinkInputs[n]);
                      n:=n+1;
                      end;
                   fcopieGraphe.Objects.remove(listeParrallele[j].symbolOutput);
                   fcopieGraphe.Objects.remove(listeParrallele[k].symbolOutput);
                   // connexions d'entree
                   fcopieGraphe.InsertLink(tenant1.symbolOutput,virtualSymbole.symbolInput);
                   n:=0;
                   while n<tenant1.symbolOutput.LinkOutputCount-1 do
                      begin
                      if TConnexion(tenant1.symbolOutput.LinkOutputs[n].HookedObjectOf(1)).symbolOwner=listeParrallele[j] then
                         fcopieGraphe.Objects.remove(tenant1.symbolOutput.LinkOutputs[n]);
                      if TConnexion(tenant1.symbolOutput.LinkOutputs[n].HookedObjectOf(1)).symbolOwner=listeParrallele[k] then
                         fcopieGraphe.Objects.remove(tenant1.symbolOutput.LinkOutputs[n]);
                      n:=n+1;
                      end;
                   fcopieGraphe.Objects.remove(listeParrallele[j].symbolInput);
                   fcopieGraphe.Objects.remove(listeParrallele[k].symbolInput);

                   listeSymbolRung.Remove(listeParrallele[j]);
                   fcopieGraphe.Objects.remove(listeParrallele[j]);
                   listeSymbolRung.Remove(listeParrallele[k]);
                   fcopieGraphe.Objects.remove(listeParrallele[k]);

                   findAndReduceParrallel:=true;
                   exit;
                   end;
                end;
             listeParrallele.clear;
             j:=j+1;
             end;
         end;
   i:=i+1;
   end;
listeParrallele.Destroy;
findAndReduceParrallel:=false;
end;

function TLadToPas.tryToOptimise(var equationList:TStringList):TStringList;
var
    i,j          : integer;
    currentLine  : string;
    workline     : string;
    condition    : string;
    conditionCurrentLine : string;
    action       : string;
    action1      : string;
    listAction   : TStringList;
    newEquationList : TStringList;
begin
listAction:=TStringList.create(false);
newEquationList:=TStringList.create(false);
i:=0;
while i<equationList.count do
   begin
   listAction.Clear;
   currentLine:=equationList[i];
   if pos('if',currentLine)<>0 then
      begin
      condition:=copy(currentLine,0,pos(' then',currentLine)-1);
      action1:=copy(currentLine,pos('then ',currentLine)+5,length(currentLine));
      j:=i+1;
      while j<equationList.count do
         begin
         workline:=equationList[j];
         conditionCurrentLine:=copy(workline,0,pos(' then',workline)-1);
         if (condition=conditionCurrentLine) and (pos('else',workline)=0)  then
            begin
            if listAction.IndexOf(action1)=-1 then listAction.Add(action1);
            action:=copy(workline,pos('then ',workline)+5,length(workline));
            listAction.Add(action);
            equationList.Delete(j);
            end
            else
            j:=j+1;
         end;
      end;
   if listAction.Count<1 then
      begin
      newEquationList.Add(equationList[i]);
      end
      else
      begin
      newEquationList.add(condition+' then begin');
      for j:=0 to listAction.Count-1 do
          newEquationList.Add(listAction[j]);
      newEquationList.add('end;');
      end;
   listAction.clear;
   i:=i+1;
   end;
result:=newEquationList;
FreeAndNil(listAction);
end;

end.

