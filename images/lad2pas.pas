unit lad2pas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,usimplegraph,laddersymbol,fgl;

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
  public
    constructor create(copieGraphe:TEvsSimpleGraph);
    destructor Destroy; override;
    // utilitaires
    procedure startConvert;
    procedure getSymbolRung(terminal : TSymbol);
    function findAndReduceSerial:boolean;
    function findAndReduceParrallel:boolean;
  end;

implementation

//uses main;

{ TSymbolList }

constructor TSymbolList.Create(aFreeObjects: Boolean);
begin
  inherited Create(aFreeObjects);
end;

{ TLAD2PAS }

constructor TladToPas.create(copieGraphe:TEvsSimpleGraph);
var
    i : integer;
begin
     listeSymbolRung:=TSymbolList.create(false);
     fcopieGraphe:=copieGraphe;
end;

destructor TladToPas.Destroy;
begin
     listeSymbolRung.free;
     inherited;
end;

procedure TladToPas.startConvert;
var
    nbGraphObject   : integer;
    matchSerial    : boolean=true;
    matchParrallel : boolean=true;
    terminalDone   : TSymbolList;
    symbolDone     : TSymbol;
begin
// genere la liste des symboles du rung
nbGraphObject:=0;
terminalDone:=TSymbolList.Create(false);
while nbGraphObject<fcopieGraphe.ObjectsCount()-1 do
   begin
   // pour chaque symbole terminal
   if (fcopieGraphe.Objects[nbGraphObject].isNode) and
      (fcopieGraphe.Objects[nbGraphObject].ClassParent.ClassName='TSymbol') and
      (TSymbol(fcopieGraphe.Objects[nbGraphObject]).isTerminal) and
      (terminalDone.IndexOf(TSymbol(fcopieGraphe.Objects[nbGraphObject]))<0) then
         begin
          // céer la liste des symboles du rung
         symbolDone:=TSymbol(fcopieGraphe.Objects[nbGraphObject]);
          getSymbolRung(TSymbol(fcopieGraphe.Objects[nbGraphObject]));
          matchSerial:=true;
          matchParrallel:=true;
          // réduire et simplifier
          while (matchSerial or matchParrallel) do
            begin
              // réduire et simplifier le rung (symboles en série)
              matchSerial:=findAndReduceSerial;
              // réduire et simplifier le rung (symboles en parralléle)
              matchParrallel:=findAndReduceParrallel;
            end;
          terminalDone.Add(symbolDone);
          nbGraphObject:=0;
         end;
   inc(nbGraphObject);
   end;
terminalDone.Destroy;
end;

//-------------------------------------------------------------------
// genere la liste des symboles d'un rung
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
         for j:=0 to listeAmont.Items[i].symbolInput.LinkInputCount-1 do
            begin
            if TConnexion(listeAmont.Items[i].symbolInput.LinkInputs[j].HookedObjectOf(0)).symbolOwner.ClassName<>'TPowerRail' then
               begin
               k:=0;
               duplicatedSymbol:=false;
               while k<listeAmont.Count do
                     begin
                     if listeAmont.Items[k]=TConnexion(listeAmont.Items[i].symbolInput.LinkInputs[j].HookedObjectOf(0)).symbolOwner then
                        duplicatedSymbol:=true;
                     k:=k+1;
                     end;
               if not(duplicatedSymbol) then
                 begin
                 listeAmont.Add(TConnexion(listeAmont.Items[i].symbolInput.LinkInputs[j].HookedObjectOf(0)).symbolOwner);
                 listeSymbolRung.Add(TSymbol(TConnexion(listeAmont.Items[i].symbolInput.LinkInputs[j].HookedObjectOf(0)).symbolOwner));
                 end;
               end
               else
               begin
               if listeSymbolRung.IndexOf(TConnexion(listeAmont.Items[i].symbolInput.LinkInputs[j].HookedObjectOf(0)).symbolOwner)<0 then
                  begin
                       listeSymbolRung.add(TSymbol(TConnexion(listeAmont.Items[i].symbolInput.LinkInputs[j].HookedObjectOf(0)).symbolOwner));
                  end;
               end;
            end;
          listeAmont.Remove(listeAmont.Items[i]);
          i:=i+1;
          end;

      if listeAmont.Count=1 then
         if listeAmont.Items[0].ClassName='TPowerRail' then listeAmont.Clear;
      end;

end;


//-------------------------------------------------------------------
// recherche et réduction des symboles en serie
//-------------------------------------------------------------------
function TladToPas.findAndReduceSerial:boolean;
var
    i : integer;
    symboleAnalyse : TSymbol;
    symboleConnecte: TSymbol;
    virtualSymbole : TVirtual;
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
           if symboleConnecte.ClassName<>'TPowerRail' then
              begin
              // créer le symbole equivalent
              virtualSymbole:=TVirtual.create(fcopieGraphe,'contactNO',symboleAnalyse.allias+'&'+symboleConnecte.allias);
              listeSymbolRung.Add(virtualSymbole);
              virtualSymbole.equation:='('+symboleAnalyse.equation+' AND '+symboleConnecte.equation+')';
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
              fcopieGraphe.Objects.Remove(symboleAnalyse.symbolInput);
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
              exit;
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
begin
for i:=0 to listeSymbolRung.Count-1 do
   writeln(listeSymbolRung.Items[i].allias);
listeParrallele:=TSymbolList.create(false);
i:=0;
while i<listeSymbolRung.Count do
   begin
   symboleAnalyse:=listeSymbolRung[i];
   writeln(symboleAnalyse.allias);
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
             tenant1:=TConnexion(listeParrallele.Items[j].symbolInput.LinkInputs[0].HookedObjectOf(0)).symbolOwner;
             for k:=j to listeParrallele.Count-1 do
                begin
                tenant2:=TConnexion(listeParrallele.Items[k].symbolInput.LinkInputs[0].HookedObjectOf(0)).symbolOwner;
                if (listeParrallele.Items[j]<>listeParrallele.Items[k]) and (tenant1=tenant2) then
                   // les tenants sont communs
                   begin
                   // créer le symbole equivalent
                   virtualSymbole:=TVirtual.create(fcopieGraphe,'contactNO',listeParrallele.Items[j].allias+'+'+listeParrallele.Items[k].allias);
                   listeSymbolRung.Add(virtualSymbole);
                   virtualSymbole.equation:='('+listeParrallele.Items[j].equation+' OR '+listeParrallele.Items[k].equation+')';
                   // fabriquer les anciennes connexions
                   // connexions de sortie
                   fcopieGraphe.InsertLink(virtualSymbole.symbolOutput,symboleAnalyse.symbolInput);
                   n:=0;
                   while n<symboleAnalyse.symbolInput.LinkInputCount-1 do
                      begin
                      if TConnexion(symboleAnalyse.symbolInput.LinkInputs[n].HookedObjectOf(0)).symbolOwner=listeParrallele.Items[j] then
                         fcopieGraphe.Objects.remove(symboleAnalyse.symbolInput.LinkInputs[n]);
                      if TConnexion(symboleAnalyse.symbolInput.LinkInputs[n].HookedObjectOf(0)).symbolOwner=listeParrallele.Items[k] then
                         fcopieGraphe.Objects.remove(symboleAnalyse.symbolInput.LinkInputs[n]);
                      n:=n+1;
                      end;
                   fcopieGraphe.Objects.remove(listeParrallele.items[j].symbolOutput);
                   fcopieGraphe.Objects.remove(listeParrallele.items[k].symbolOutput);
                   // connexions d'entree
                   fcopieGraphe.InsertLink(tenant1.symbolOutput,virtualSymbole.symbolInput);
                   n:=0;
                   while n<tenant1.symbolOutput.LinkOutputCount-1 do
                      begin
                      if TConnexion(tenant1.symbolOutput.LinkOutputs[n].HookedObjectOf(1)).symbolOwner=listeParrallele.Items[j] then
                         fcopieGraphe.Objects.remove(tenant1.symbolOutput.LinkOutputs[n]);
                      if TConnexion(tenant1.symbolOutput.LinkOutputs[n].HookedObjectOf(1)).symbolOwner=listeParrallele.Items[k] then
                         fcopieGraphe.Objects.remove(tenant1.symbolOutput.LinkOutputs[n]);
                      n:=n+1;
                      end;
                   fcopieGraphe.Objects.remove(listeParrallele.items[j].symbolInput);
                   fcopieGraphe.Objects.remove(listeParrallele.items[k].symbolInput);

                   listeSymbolRung.Remove(listeParrallele.items[j]);
                   fcopieGraphe.Objects.remove(listeParrallele.items[j]);
                   listeSymbolRung.Remove(listeParrallele.items[k]);
                   fcopieGraphe.Objects.remove(listeParrallele.items[k]);

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

end.

