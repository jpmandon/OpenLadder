unit laddergraphunit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,usimplegraph,ComCtrls,ExtCtrls,Graphics, Dialogs,controls,forms,
  buttons,laddersymbol,lad2pas,menus,LMessages
  ;

type
  TGraphError=(errNone,errSingle,errNoVar);

type TLadderGraph = class(TEvsSimpleGraph)
  protected
    ftabsheet            : TTabSheet;
    fpanel               : TPanel;
    fname                : string;
    faowner              : TForm;
    fform                : TForm;
    fsurface             : TPageControl;
    fstartInsert         : boolean;
    fcurrentLink         : TEvsGraphLink;
    fListeSymbole        : TEvsGraphObjectList;
    fVisibleVar          : TStringList;
    fconvertisseur       : TladToPas;
    fobjectUnderMouse    : TEvsGraphObject;
    fgraphChanged        : boolean;
    fRectBeginDrag       : TRect;
    fOldMouseX           : integer;
    fSymbolError         : string;
    fOldVisibleBounds    : TRect;
    procedure DoNodeMoveResize(aNode: TEvsGraphNode); override;
    procedure DoObjectMouseEnter(aGraphObject: TEvsGraphObject);override;
    procedure DoObjectMouseLeave(aGraphObject: TEvsGraphObject);override;
    procedure mouseup(Sender: TObject;Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure mouseDown(Sender: TObject;Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure mouseMove(Sender: TObject; Shift: TShiftState;X, Y: Integer);
    procedure objectInserted(Graph: TEvsSimpleGraph; GraphObject: TEvsGraphObject);
    procedure objectRemoved(Graph: TEvsSimpleGraph; GraphObject: TEvsGraphObject);
    procedure objectChanged(Graph: TEvsSimpleGraph; GraphObject: TEvsGraphObject);
    procedure objectClick(Graph: TEvsSimpleGraph;aGraphObject: TEvsGraphObject);
    procedure onClickEvent(sender:TObject);
    procedure keyDown(sender:TObject;var key:word;shiftState:TShiftState);
    procedure commandModeChange(Sender : TObject);
    procedure dblClick(grapheCurrent:TEvsSimpleGraph;objet:TEvsGraphObject);

    procedure objectBeginDrag(graphe:TEvsSimpleGraph;objet:TEvsGraphObject;ht:DWord);
    procedure ObjectEndDrag(graphe:TEvsSimpleGraph;objet:TEvsGraphObject;ht:DWord;value : boolean);
    procedure showTab(sender:TObject);
    procedure graphChange(Sender:TObject);

    procedure showErrorForm(message:string;x,y:integer);
    procedure askInsert(lien:TEvsGraphLink;symbole:TSymbol);
  public
    constructor create(aOwner:TForm;surface:TPageControl;nom:string;visibility:boolean);
    constructor create(aOwner:TForm;nom:string);
    procedure expandGraphOnPanel;
    procedure deleteSymbol;
    procedure renameSymbol;
    function checkGraph:TGraphError;                                       // check error in graph
    procedure findInGraph(varName:string);                                 // find a var name in this graph
    procedure unHighLightGraph;                                            // clear highlighting of symbol

    property name:string read fname write fname;                           // get name of graph
    property convertisseur : TladToPas read fconvertisseur;
    property objectUnderMouse : TEvsGraphObject read fobjectUnderMouse;
    property graphChanged:boolean read fgraphChanged write FgraphChanged;
    property graphTabSheet:TTabSheet read ftabsheet;
    property SymbolError:string read fSymbolError;
    // var related with visible symbol on the graph
    property VisibleVar:TStringlist read fVisibleVar;
  end;




implementation

uses main;


constructor TLadderGraph.create(aOwner:TForm;surface:TPageControl;nom:string;visibility:boolean);
begin
  inherited create(aowner);
  faowner:=aowner;
  fsurface:=surface;
  fstartInsert:=false;
  self.color:=clBtnFace;
  self.SnapToGrid:=true;
  // création de l'onglet
  ftabsheet:=surface.AddTabSheet;
  fname:=nom;
  ftabsheet.caption:=fname;
  ftabsheet.OnShow:=@showTab;
  // création du fpanel dans l'onglet
  fpanel:=TPanel.create(ftabsheet);
  fpanel.Parent:=ftabsheet;
  fpanel.Top:=0;
  fpanel.left:=0;
  fpanel.height:=surface.height;
  fpanel.width:=surface.width;
  // définitions du graphe
  self.parent:=fpanel;
  self.GridSize:=8;
  self.Left:=fpanel.Left;
  self.top:=fpanel.top;
  self.AnchorSide[akLeft].side:=asrRight;
  self.AnchorSide[akLeft].Control :=surface;
  self.Anchors := self.Anchors + [akLeft];
  self.SetBounds(fpanel.Left, fpanel.Top, fpanel.Width-10, fpanel.Height-40);
  self.FixedScrollBars:=true;
  self.MinNodeSize:=2;
  //evenements
  self.OnMouseUp:=@mouseup;
  self.OnMouseDown:=@mouseDown;
  self.OnMouseMove:=@mouseMove;
  self.OnObjectInsert:=@objectInserted;
  self.OnObjectDblClick:=@dblClick;
  self.OnObjectClick:=@objectClick;
  self.OnKeyDown:=@keyDown;
  self.OnCommandModeChange:=@commandModeChange;
  self.OnObjectRemove:=@objectRemoved;
  self.OnObjectChange:=@objectChanged;
  self.OnObjectBeginDrag:=@objectBeginDrag;
  self.OnObjectEndDrag:=@objectEndDrag;
  self.OnClick:=@onClickEvent;
  self.OnGraphChange:=@graphChange;
  fOldVisibleBounds:=VisibleBounds;
  TControl(self).ShowHint:=true;
  // creation de la liste des symboles
  fListeSymbole:=TEvsGraphObjectList.create;
  // list of var related to visible symbol on the screen
  fVisibleVar:=TStringList.create;

  if not visibility then
     ftabsheet.TabVisible:=false
  else
     ftabsheet.TabVisible:=true;
  self.graphChanged:=false;
end;

// simplified constructor for virtual graph
constructor TLadderGraph.create(aOwner:TForm;nom:string);
begin
  inherited create(aowner);
  faowner:=aowner;
    // creation de la liste des symboles
  fListeSymbole:=TEvsGraphObjectList.create;
end;

procedure TLadderGraph.DoNodeMoveResize(aNode: TEvsGraphNode);
var
   i : integer;
   xpos,ypos : integer ;
begin
  Inherited;
    // mise à jour des positions des symboles
  if self.Objects.Count>0 then
    for i:=0 to self.Objects.Count-1 do
     if (aNode=self.Objects[i]) and
        (aNode.isNode) and
        (aNode.ClassParent.ClassName<>'TEvsEllipticNode') and
        (aNode.ClassName<>'TAllias') then
         begin
           xpos:=aNode.left;
           ypos:=aNode.top;
           if (xpos>10) and (xpos<1410) then
             begin
               if (self.Objects[i] is TSymbol) then
                TSymbol(self.Objects[i]).updatePosition(xpos,ypos)
               else
               if not(self.Objects[i] is TConnexion) then
                  begin
                  TEvsRectangularNode(self.Objects[i]).Top:=ypos;
                  TEvsRectangularNode(self.Objects[i]).left:=xpos;
                  end;
             end;
           if xpos<=10 then aNode.Left:=18;
           if xpos>=1410 then anode.left:=1401;
         end;
end;

procedure TLadderGraph.DoObjectMouseEnter(aGraphObject: TEvsGraphObject);
var
   oldGraphChange : boolean;
begin
  inherited;
  oldGraphChange:=graphChanged;
  fobjectUnderMouse:=aGraphObject;
  if aGraphObject.IsNode then
     // si point de connexion
     if aGraphObject.ClassParent.ClassName='TEvsEllipticNode' then
       begin
        TEvsEllipticNode(aGraphObject).Brush.Color:=clRed;
        fstartInsert:=true;
        if not(oldGraphChange) then graphChanged:=false;
       end;
end;

procedure TLadderGraph.DoObjectMouseLeave(aGraphObject: TEvsGraphObject);
var
   oldGraphChange : boolean;
begin
  Inherited;
  fobjectUnderMouse:=nil;
  if aGraphObject.IsNode then
     // si point de connexion
     if aGraphObject.ClassParent.ClassName='TEvsEllipticNode' then
       begin
        fstartInsert:=false;
        TEvsEllipticNode(aGraphObject).Brush.Color:=clWhite;
        if not(oldGraphChange) then graphChanged:=false;
       end;
end;

procedure TLadderGraph.mouseup(Sender: TObject;Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
var
   i              : integer;
   allTerminal    : boolean;
   testObj,selObj : TEvsGraphObject;
begin
  cursor:=crDefault;
  Refresh;
  if self.SelectedObjects.Count>0 then
    if self.SelectedObjects[0].IsLink then
       // si insertion de lien en cours
       begin
       fcurrentlink:=TEvsGraphLink(self.SelectedObjects[0]);
       // link non connecté d'un coté
       if fcurrentLink.HookedPointCount<2 then
          begin
          showErrorForm('Liaison non valide',fcurrentLink.BoundsRect.Left,fcurrentLink.BoundsRect.top);
          exit;
          end;
       // link connecté entre deux entrées ou deux sorties
       if fcurrentLink.HookedPointCount=2 then
          begin
          if (TConnexion(fcurrentLink.HookedObjectOf(0)).isInput and  TConnexion(fcurrentLink.HookedObjectOf(1)).isInput) then
                begin
                showErrorForm('link can not connect 2 input',fcurrentLink.BoundsRect.Left,fcurrentLink.BoundsRect.top);
                exit;
                end;
          if (not(TConnexion(fcurrentLink.HookedObjectOf(0)).isInput) and  not(TConnexion(fcurrentLink.HookedObjectOf(1)).isInput)) then
              begin
              showErrorForm('link can not connect 2 output',fcurrentLink.BoundsRect.Left,fcurrentLink.BoundsRect.top);
              exit;
              end;
          if (TConnexion(fcurrentLink.HookedObjectOf(0)).isInput) then
              begin
              showErrorForm('link should be connected from symbol output to symbol input',fcurrentLink.BoundsRect.Left,fcurrentLink.BoundsRect.top);
              exit;
              end;

          if (TConnexion(fcurrentLink.HookedObjectOf(1)).symbolOwner.isTerminal) then
             if (Tconnexion(fcurrentLink.HookedObjectOf(0)).LinkOutputCount>1) then
              begin
               allTerminal:=true;
               for i:=0 to Tconnexion(fcurrentLink.HookedObjectOf(0)).LinkOutputCount-1 do
                 if not (TConnexion(Tconnexion(fcurrentLink.HookedObjectOf(0)).LinkOutputs[i].HookedObjectOf(1)).symbolOwner.isTerminal) then
                    allTerminal:=false;
               if not allTerminal then
                  begin
                  showErrorForm('terminal can not be connected here',fcurrentLink.BoundsRect.Left,fcurrentLink.BoundsRect.top);
                  exit;
                  end;
               end;
          end;
       end;   //----------------
     // test while moving symbols
     if SelectedObjects.Count>0 then
         for i:=0 to self.ObjectsCount()-1 do
           begin
           testObj := Objects.Items[i];
           selObj  := SelectedObjects[0];

            if testObj.IsLink then
               if self.SelectedObjectsCount(TEvsGraphNode)>0 then
                  if (testObj.ContainsRect(selObj.BoundsRect)) and
                     (selObj.ClassName<>'TConnexion') and
                     (selObj.ClassName<>'TAllias') and
                     (TConnexion(TEvsGraphLink(testObj).HookedObjectOf(1)).symbolOwner<>selObj)
                     then
                     askInsert(TEvsGraphLink(testObj),TSymbol(selObj));
           end;
end;

procedure TLadderGraph.mouseDown(Sender: TObject;Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
begin
 if fstartInsert then self.CommandMode:=cmInsertLink;
 if button=mbMiddle then
    begin
    Cursor:=crSizeWE;
    fOldMouseX:=mouse.CursorPos.x;
    end;
end;

procedure TLadderGraph.mouseMove(Sender: TObject; Shift: TShiftState;X, Y: Integer);
begin
   if cursor=crSizeWE then
      begin
      if CursorPos.x>fOldMouseX then
            begin
            HorzScrollBar.position:=HorzScrollBar.position-(CursorPos.x-fOldMouseX);
            end;
      if CursorPos.x<fOldMouseX then
            begin
            HorzScrollBar.position:=HorzScrollBar.position+(fOldMouseX-CursorPos.x);
            end;
      end;
end;

procedure TLadderGraph.objectInserted(Graph: TEvsSimpleGraph; GraphObject: TEvsGraphObject);
begin
  // debut d'insertion de lien
  if self.CommandMode=cmInsertLink then
     begin
     fcurrentLink:=TEvsGraphLink(graphObject);
     end;
  graphChanged:=true;
  form1.compileIndicator.Brush.Color:=clRed;
end;

procedure  TLadderGraph.objectRemoved(Graph: TEvsSimpleGraph; GraphObject: TEvsGraphObject);
begin
  graphChanged:=true;
  form1.compileIndicator.Brush.Color:=clRed;
end;

procedure TLadderGraph.objectChanged(Graph: TEvsSimpleGraph; GraphObject: TEvsGraphObject);
begin
  if not(GraphObject is TConnexion) then
     begin
     graphChanged:=true;
     form1.compileIndicator.Brush.Color:=clRed;
     end;
end;

procedure TLadderGraph.objectClick(Graph: TEvsSimpleGraph;aGraphObject: TEvsGraphObject);
begin

end;

procedure TLadderGraph.keyDown(sender:TObject;var key:word;shiftState:TShiftState);
var
   i : integer;
begin
  // suppress
  if (key=46) and (self.SelectedObjectsCount()>0) then
     deleteSymbol;
  // copy
  if (ssCtrl in shiftState) and  (upcase(char(key))='C') then
     Form1.itemCopySymbolClick(sender);
  // paste
  if (ssCtrl in shiftState) and  (upcase(char(key))='V') then
     Form1.itemPasteSymbolClick(sender);
end;

procedure TLadderGraph.commandModeChange(Sender : TObject);
begin
//  if self.CommandMode=cmInsertLink then
//    begin
//    fcurrentLink:=nil;
//    end;
end;

procedure TLadderGraph.dblClick(grapheCurrent:TEvsSimpleGraph;objet:TEvsGraphObject);
begin
   if objet.IsNode then
     if objet.ClassName='TComment' then
       TComment(objet).doubleClick(objet)
     else
      TSymbol(objet).doubleClick(objet);
end;

// error form
procedure TLadderGraph.showErrorForm(message:string;x,y:integer);
begin
  MessageDlgPos(message,mtWarning,[mbOK],0,x,y);
  fcurrentLink.Destroy;
end;

// dialogue permettant d'insérer un symbole sur un lien existant
// appelé par l'evenement onMouseUp
procedure TLadderGraph.askInsert(lien:TEvsGraphLink;symbole:TSymbol);
var
   connecteur : array[0..1] of TConnexion;
   newLien : array[0..1] of TEvsGraphLink;
   i : integer;
begin
  if MessageDlgPos('Insérer le symbole ?',mtConfirmation,[mbCancel,mbOK],0,self.GraphToScreen(symbole.left,symbole.top).x,self.GraphToScreen(symbole.left,symbole.top).y)=mrOK then
     begin
     for i:=0 to lien.HookedPointCount-1 do
      begin
      connecteur[i]:=TConnexion(lien.HookedObjectOf(i));
      newlien[i]:=TevsGraphLink.Create(self);
      if not connecteur[i].isInput then
              newlien[i].Link(connecteur[i],TSymbol(symbole).symbolInput)
              else
              newlien[i].Link(Tconnexion(TSymbol(symbole).symbolOutput),connecteur[i]);
      end;
      lien.Delete;
     end;
end;

procedure TLadderGraph.deleteSymbol;
var
   i,j    : integer;
   symbol : TSymbol;
begin
 i:=SelectedObjects.count;
  while i>0 do
     begin
     if SelectedObjects[0].IsNode then
        begin
        symbol:=TSymbol(SelectedObjects.Items[0]);
        if SelectedObjects[0].ClassName<>'TComment' then
           begin
           if symbol.symbolInput<>nil then
             begin
             j:=symbol.symbolInput.LinkInputCount;
             while j>0 do
                   begin
                   symbol.symbolInput.LinkInputs[0].Delete;
                   j:=symbol.symbolInput.LinkInputCount;
                   end;
             end;
           if symbol.symbolOutput<>nil then
             begin
             j:=symbol.symbolOutput.LinkOutputCount;
             while j>0 do
                   begin
                   symbol.symbolOutput.LinkOutputs[0].Delete;
                   j:=symbol.symbolOutput.LinkOutputCount;
                   end;
             end;
           if symbol.symbolInput<>nil then symbol.symbolInput.Delete;
           if symbol.symbolOutput<>nil then symbol.symbolOutput.Delete;
           if symbol.textAllias<>nil then symbol.textAllias.delete;
           symbol.delete;
           end
           else SelectedObjects[0].Delete;
        end
        else SelectedObjects[0].Delete;
        i:=SelectedObjects.count;
     end;


end;

procedure TLadderGraph.renameSymbol;
var
   symbol : TSymbol;
begin
     if SelectedObjects[0].IsNode then
       if SelectedObjects[0].ClassName<>'TComment' then
        begin
        symbol:=TSymbol(SelectedObjects.Items[0]);
        symbol.doubleClick(symbol);
        end;
end;

procedure TLadderGraph.showTab(sender:TObject);
begin
     expandGraphOnPanel;
end;

// expand graph on all panel area
procedure TLadderGraph.expandGraphOnPanel;
begin
  if grapheCurrent<>nil then
     begin
     //ftabsheet.SetBounds(fsurface.left,fsurface.Top-100,fsurface.Width,fsurface.Height);
     fsurface.width:=form1.width-form1.traitProjectTree.left-form1.VariablesPageControl.width+104;
     fpanel.Width:=fsurface.width;
     self.width:=fpanel.Width-10;
     end;
end;

{ Object move }

procedure TLadderGraph.objectBeginDrag(graphe:TEvsSimpleGraph;objet:TEvsGraphObject;ht:DWord);
begin
  // for over writing
  fRectBeginDrag:=objet.BoundsRect;
end;

procedure TLadderGraph.ObjectEndDrag(graphe:TEvsSimpleGraph;objet:TEvsGraphObject;ht:DWord;value : boolean);
var
   i : integer;
begin
  // test over writing
  for i:=0 to grapheCurrent.Objects.count-1 do
   if (grapheCurrent.Objects[i].IsNode) and
      (grapheCurrent.Objects[i].ClassName<>'TConnexion') and
      (grapheCurrent.Objects[i].ClassName<>'TAllias')
      then
      begin
      if (objet.ContainsRect(grapheCurrent.Objects[i].BoundsRect)) and
         (objet<>grapheCurrent.Objects[i]) then
             objet.BoundsRect:=fRectBeginDrag;
      end;
end;

procedure TLadderGraph.onClickEvent(sender:TObject);
var
   i : integer;
begin
  for i:=0 to ObjectsCount()-1 do
      if Objects[i] is Tsymbol
         then if TSymbol(Objects[I]).highlighted then
              TSymbol(Objects[I]).unhighLight;
end;

procedure TLadderGraph.graphChange(Sender:TObject);
begin
  graphChanged:=true;
end;

function TLadderGraph.checkGraph:TGraphError;
var
   i,j,k      : integer;
   tryNumber  : longint;
   objet      : TEvsGraphObject;
   varSymbol  : TStringList;
   varExist   : boolean;
begin
// check unconnected symbols
for i:=0 to Objects.Count-1 do
 begin
 objet:=Objects[i];
 if objet is TSymbol then
    begin
    if TSymbol(objet).symbolInput<>nil then
        if (TSymbol(objet).symbolInput.LinkInputCount=0) then
           begin
           result:=errSingle;
           exit;
           end;
    if (not TSymbol(objet).isTerminal) and
       (TSymbol(objet).symbolOutput<>nil) then
        if (TSymbol(objet).symbolOutput.LinkOutputCount=0) then
          begin
          result:=errSingle;
          exit;
          end;
    end;
 end;
// check existing var
for i:=0 to ObjectsCount-1 do
    if Objects[i] is TSymbol then
      if TSymbol(Objects[i]).ClassName<>'TPowerRail' then
      begin
      varSymbol:=TSymbol(Objects[i]).getVarList;
      for j:=0 to varSymbol.Count-1 do
       if not trystrtoint(varSymbol[j],tryNumber) then
          begin
          varExist:=false;
          for k:=0 to varList.Count-1 do
              if varList[k].nameVar=varSymbol[j]
                 then varExist:=true;
          if not varExist then
              for k:=0 to ioPlcList.Count-1 do
                  if ioPlcList[k].nameVar=varSymbol[j]
                     then varExist:=true;
          if not varExist then
              for k:=0 to form1.SystemGrid.RowCount-1 do
                  if form1.SystemGrid.Cells[0,k]=varSymbol[j]
                     then varExist:=true;
          if not varExist then
              for k:=0 to timerList.Count-1 do
                  if timerList[k].nameVar=varSymbol[j]
                     then varExist:=true;
          // error var doesn't exist
          if not varExist then
             begin
             fSymbolError:=varSymbol[j];
             result:=errNoVar;
             exit;
             end;
          end;
      end;
 result:=errNone;
end;

procedure TLadderGraph.findInGraph(varName:string);
var
   i,j        : integer;
   varSymbol  : TStringList;
   tryNumber  : longint;
begin
for i:=0 to ObjectsCount-1 do
    if Objects[i] is TSymbol then
      if TSymbol(Objects[i]).ClassName<>'TPowerRail' then
      begin
      varSymbol:=TSymbol(Objects[i]).getVarList;
      for j:=0 to varSymbol.Count-1 do
       if not trystrtoint(varSymbol[j],tryNumber) then
          begin
          if varSymbol[j]=varName then
            begin
            crossRefList.add(TSymbol(Objects[i]));
            classCrossRefList.add(TSymbol(Objects[i]).classname);
            end;
          end;
      end;
end;

procedure TLadderGraph.unHighLightGraph;
var
   i : integer;
begin
for i:=0 to ObjectsCount-1 do
   if Objects[i] is TSymbol then TSymbol(Objects[i]).unHighlight;
end;

end.

