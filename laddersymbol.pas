unit LadderSymbol;

{$mode ObjFPC}{$H+}{$M+}

interface

uses
  Classes, SysUtils,usimplegraph,graphics,forms,
  doubleclickbit,doubleclickcompare,doubleclickstore,
  doubleclickcomment,doubleclickmath,doubleclicktimer,
  doubleclickflash,
  stdctrls,
  fgl;

type

 TSymbol = class;

 { TSymbolList }

TSymbolList = class(specialize TFPGObjectList<TSymbol>)
     constructor Create(aFreeObjects: Boolean);
end;

 { TAllias }

 type TAllias = class(TEvsRectangularNode)
  protected
  fowner  : TSymbol;
  fposx   : integer;
  fposy   : integer;
  flastx  : longint;
  flasty  : longint;
  public
  constructor create(graphe:TEvsSimpleGraph;sender:TSymbol); reintroduce;
  procedure updatePosition(newx:longint;newy:longint);
 end;

{ TConnexion }

 type TConnexion = class(TEvsEllipticNode)
  protected
  ftype  : string; // 'in' ou 'out'
  fowner : TSymbol;
  private
    function GetPreviousLink() : TConnexion;
  public
    constructor create(graphe:TEvsSimpleGraph; sender:TSymbol; sens:string); reintroduce;
    procedure updatePosition(newx:longint;newy:longint);
    function  isInput: boolean;
  published
    property previousLink: TConnexion read GetPreviousLink;
    property symbolOwner : TSymbol read fowner;
end;

type TSymbol = class(TEvsRectangularNode)
  protected
  symbol      : TEvsRectangularNode;
  flastx      : longint;
  flasty      : longint;
  fallias     : string;
  finput      : TConnexion;
  foutput     : TConnexion;
  ftextAllias : TAllias;
  fequation   : string;
  ffonction   : string;
  fcodeBefore : string;
  fCodeAfter  : string;
  fhighlighted: boolean;
  fBGcolor    : TColor;
  fvarList    : TStringList;
  fSaveBrushColor : longint;
  public
  constructor create(sender:TEvsSimpleGraph; inputExist, outputExist:boolean; fonctionName:string; symallias:string);
  procedure updateAbsolutePosition(newx:longint;newy:longint);
  procedure updatePosition(newx:longint;newy:longint);
  function codeBefore:string; virtual; Abstract;
  function codeAfter:string; virtual; Abstract;
  procedure setCodeBefore(code:string);
  procedure setCodeAfter(code:string);
  procedure writeAllias(name:string);
  function isTerminal:boolean; virtual; abstract;
  function isVirtual:boolean; virtual; abstract;
  function getVarList:TStringList; virtual; abstract;
  procedure SetVar(list:TStringList); virtual; Abstract;
  procedure SetVar(index:integer;name:string); virtual; Abstract;
  procedure doubleClick(objet:TEvsGraphObject); virtual; abstract;
  procedure highLight(state:boolean); virtual;
  procedure highLightblue; virtual;
  procedure unHighlight; virtual;
  property allias:string read fallias write fallias;
  property symbolInput:TConnexion read finput write finput;
  property symbolOutput:TConnexion read foutput write foutput;
  property textAllias:TAllias read ftextAllias write ftextAllias;
  property fonction : string read ffonction;
  property equation : string read fequation write fequation;
  property highlighted : boolean read fhighlighted;
end;

  type TPowerRail = class(TSymbol)
  protected

  public
  constructor create(sender:TEvsSimpleGraph;fonctionName:string;symallias:string);
  function codeBefore:string; override;
  function codeAfter:string; override;
  function isTerminal:boolean; override;
  function isVirtual:boolean; override;
  function getVarList: TStringList; override;
  procedure doubleClick(objet:TEvsGraphObject); override;
  end;

  type TComment = class(TEvsRectangularNode)
    protected
    ffonction : string;
    public
    constructor create(sender:TEvsSimpleGraph;fonctionName:string;symallias:string);
    procedure updatePosition(newx:longint;newy:longint);
    function isTerminal:boolean;
    function isVirtual:boolean;
    function readText:string;
    procedure setText(strtext:string);
    procedure doubleClick(objet:TEvsGraphObject);
    property allias:string read readText write setText;
    end;

  type TBit = class(TSymbol)
  public
  constructor create(sender:TEvsSimpleGraph;fonctionName:string;symallias:string);
  function codeBefore:string; override;
  function codeAfter:string; override;
  function isTerminal:boolean; override;
  function isVirtual:boolean; override;
  procedure doubleClick(objet:TEvsGraphObject); override;
  procedure setEquation(equat:string);
  function getVarList: TStringList; override;
  procedure SetVar(list:TStringList); override;
  procedure SetVar(index:integer;name:string); override;
  procedure HighLight(state:boolean); override;
  procedure highLightblue; override;
  procedure unHighlight; override;
  end;

  type TCoil = class(TSymbol)
  protected

  public
  constructor create(sender:TEvsSimpleGraph;fonctionName:string;symallias:string);
  destructor destroy;
  function codeBefore:string; override;
  function codeAfter:string; override;
  function isTerminal:boolean; override;
  function isVirtual:boolean; override;
  procedure doubleClick(objet:TEvsGraphObject); override;
  function getVarList: TStringList; override;
  procedure SetVar(list:TStringList); override;
  procedure SetVar(index:integer;name:string); override;
  procedure HighLight(state:boolean); override;
  procedure highLightblue; override;
  procedure unHighLight; override;
  end;

  type TFrontCoil = class(TCoil)
  protected

  public
  function codeBefore:string; override;
  function codeAfter:string; override;
  function isTerminal:boolean; override;
  function isVirtual:boolean; override;
  procedure doubleClick(objet:TEvsGraphObject); override;
  end;

  type TStore = class(TSymbol)
  protected
  protected
  fvar1 : string;
  fvar2 : string;
  public
  constructor create(sender:TEvsSimpleGraph;fonctionName:string;var1:string;var2:string);
  function codeBefore:string; override;
  function codeAfter:string; override;
  function isTerminal:boolean; override;
  function isVirtual:boolean; override;
  procedure doubleClick(objet:TEvsGraphObject); override;
  function getVarList: TStringList; override;
  procedure SetVar(list:TStringList); override;
  procedure SetVar(index:integer;name:string); override;
  property var1:string read fvar1 write fvar1;
  property var2:string read fvar2 write fvar2;
  end;

  type TVirtual = class(TSymbol)
  public
  constructor create(sender:TEvsSimpleGraph;fonctionName:string;symallias:string);
  function codeBefore:string; override;
  function codeAfter:string; override;
  function isTerminal:boolean; override;
  function isVirtual:boolean; override;
  procedure setEquation(equat:string);
  end;

  type TCompare = class(TSymbol)
    protected
    fvar1 : string;
    fvar2 : string;
    public
    constructor create(sender:TEvsSimpleGraph;fonctionName:string;var1:string;var2:string);
    function isTerminal:boolean; override;
    function isVirtual:boolean; override;
    procedure setEquation(equat:string);
    function getOperateur:string;
    procedure doubleClick(objet:TEvsGraphObject); override;
    function getVarList: TStringList; override;
    procedure SetVar(list:TStringList); override;
    procedure SetVar(index:integer;name:string); override;
    property var1:string read fvar1 write fvar1;
    property var2:string read fvar2 write fvar2;
    end;

  type TMath = class(TSymbol)
    protected
    fvar1 : string;
    fvar2 : string;
    fvar3 : string;
    public
    constructor create(sender:TEvsSimpleGraph;fonctionName:string;var1:string;var2:string;var3:string);
    function isTerminal:boolean; override;
    function isVirtual:boolean; override;
    procedure setEquation(equat:string);
    function getOperateur:string;
    function codeBefore:string; override;
    function codeAfter:string; override;
    procedure doubleClick(objet:TEvsGraphObject); override;
    function getVarList: TStringList; override;
    procedure SetVar(list:TStringList); override;
    procedure SetVar(index:integer;name:string); override;
    property var1:string read fvar1 write fvar1;
    property var2:string read fvar2 write fvar2;
    property var3:string read fvar3 write fvar3;
    end;

  type TTimerObject = class(TSymbol)
    protected
      ftimerEnabled :boolean;
      fpresetValue  :word;
      fcurrentValue :word;
      fstate        : boolean;
    public
      property currentValue:word read fcurrentValue;
      property preset:word read fpresetValue write fpresetValue;
      property state:boolean read fstate;
      property timerEnabled:boolean read ftimerEnabled write ftimerEnabled;
      constructor Create(sender:TEvsSimpleGraph;fonctionName,alliasValue:string;presetValue:word);
      function isTerminal:boolean; override;
      function isVirtual:boolean; override;
      function codeBefore:string; override;
      function codeAfter:string; override;
      function getVarList: TStringList; override;
      procedure doubleClick(objet:TEvsGraphObject); override;
      procedure highLight(etat:boolean); override;
      procedure unhighLight; override;
  end;

  type TTon = class(TTimerObject)
    function codeAfter:string; override;
  end;

  type TToff = class(TTimerObject)
    public
      function codeAfter:string; override;
  end;

  type TFlash = class(TTimerObject)
    protected
      fpresetON  : word;
      fpresetOff : word;
    public
      constructor Create(sender:TEvsSimpleGraph;fonctionName,alliasValue:string;presetValueON,presetValueOFF:word);
      function codeAfter:string; override;
      property presetON:word read fpresetON write fpresetON;
      property presetOFF:word read fpresetOFF write fpresetOFF;
      procedure doubleClick(objet:TEvsGraphObject); override;
  end;


implementation

uses main;

const
  onColorR : byte=$AD;
  onColorV : byte=$DF;
  onColorB : byte=$9F;
  offColorR : byte=$E1;
  offColorV : byte=$7C;
  offColorB : byte=$7C;

{ TSymbolList }

constructor TSymbolList.Create(aFreeObjects: Boolean);
begin
  inherited Create(aFreeObjects);
end;

constructor TSymbol.create( sender:TEvsSimpleGraph;
                            inputExist,outputExist:boolean;
                            fonctionName:string;
                            symallias:string);
begin
  Inherited create(sender);
  sender.BeginUpdate;
  with self do
     begin
     SetBounds(sender.ClientToGraph(0,0).x+17,sender.ClientToGraph(0,0).Y,75,50);
     Font.Height:=10;
     Margin:=0;
     Alignment:=taLeftJustify;
     Layout:=tlTop;
     Pen.Style:=psClear;
     brush.Color:=sender.Brush.Color;
     fSaveBrushColor:=brush.color;
     fBGcolor:=brush.color;
     pen.Color:=sender.Brush.Color;
     ffonction:=fonctionName;
     if fonctionName<>'powerRail' then
        begin
          if symallias='' then text:=copy('??????',0,20)
                        else text:=copy(symallias,0,20);
        end;

     Options:=[goSelectable];
     if fonctionName<>'' then
        background.LoadFromFile(ExtractFilePath(paramstr(0))+'/images/'+fonctionName+'.png');
     end;
  flastx:=sender.ClientToGraph(0,0).x+17;
  flasty:=sender.ClientToGraph(0,0).Y;
  if inputExist then
     SymbolInput:=TConnexion.create(sender,self,'input');
  if outputExist then
     SymbolOutput:=TConnexion.create(sender,self,'output');
  if symallias='' then text:=copy('??????',0,20)
                        else text:=copy(symallias,0,20);
  allias:=text;
  textAllias:=TAllias.create(sender,self);
  if fonctionName='powerRail' then textAllias.text:='';
  //Hint:=textAllias.Text;
  Hint:=allias;
  fhighlighted:=false;
  sender.EndUpdate;
end;

procedure TSymbol.updateAbsolutePosition(newx:longint;newy:longint);
begin
  self.SetBounds(newx,newy,75,50);
  if symbolInput<>nil then
     SymbolInput.updatePosition(newx,newy);
  if symbolOutput<>nil then
     symbolOutput.updatePosition(newx,newy);
end;

procedure TSymbol.updatePosition(newx:longint;newy:longint);
begin
  self.SetBounds(newx,newy,75,50);
  if symbolInput<>nil then
     SymbolInput.updatePosition(newx-flastx,newy-flasty);
  if symbolOutput<>nil then
     symbolOutput.updatePosition(newx-flastx,newy-flasty);
  textAllias.updatePosition(newx-flastx,newy-flasty);
  flastx:=newx;
  flasty:=newy;
end;

procedure TSymbol.setCodeBefore(code:string);
begin
    fcodeBefore:=code;
end;

procedure TSymbol.setCodeAfter(code:string);
begin
     fCodeAfter:=code;
end;

procedure TSymbol.writeAllias(name:string);
begin
  textAllias.Text:=name;
  fallias:=name;
end;

procedure TSymbol.highLight(state:boolean);
begin
end;

procedure TSymbol.highLightblue;
begin
end;

procedure TSymbol.unHighlight;
begin
end;

function TConnexion.GetPreviousLink(): TConnexion;
begin
  if LinkInputCount > 0 then
    Result := Linkinputs[0].HookedObjectOf(0) as TConnexion
  else
    Result := nil;
end;

constructor TConnexion.create( graphe:TEvsSimpleGraph;
                               sender:TSymbol;
                               sens:string);
var
  offsetx : integer;
  offsety : integer;
begin
  inherited create(graphe);
  offsety:=17;
  if sens='input' then
     begin
       offsetx:=0;
       ftype:='in';
     end
     else
     begin
       offsetx:=92;
       ftype:='out';
     end;
  with self do
     begin
     options:=[goLinkable];
     SetBounds(graphe.ClientToGraph(0,0).x+offsetx,graphe.ClientToGraph(0,0).Y+offsety,16,16);
     end;
  fowner:=Tsymbol(sender);
end;

procedure TConnexion.updatePosition(newx: longint; newy: longint);
begin
  self.moveby(newx,newy);
end;

function TConnexion.isInput: boolean;
begin
  if ftype='in' then isInput:=true
  else isInput:=false;
end;

constructor TAllias.create(graphe:TEvsSimpleGraph;sender:TSymbol);
var
  offsety : integer;
  recLeft : integer;
  recTop  : integer;
begin
  inherited create(graphe);
  offsety := 50;
  with self do
     begin
     BeginUpdate;
     Font.Height:=12;
     Margin:=0;
     Alignment:=taLeftJustify;
     Pen.Style:=psSolid;
     options:=[goShowCaption];
     recLeft:=graphe.ClientToGraph(0,0).x-10;
     recTop:=graphe.ClientToGraph(0,0).Y+offsety;
     SetBounds(recLeft,recTop,140,20);
     brush.Color:=graphe.Brush.Color;
     pen.Color:=graphe.Brush.Color;
     text:=sender.Text;
     hint:=sender.text;
     Alignment:=taLeftJustify;
     Layout:=tlCenter;
     fowner:=sender;
     EndUpdate;
     end;
end;

procedure TAllias.updatePosition(newx:longint;newy:longint);
begin
  self.MoveBy(newx,newy);
end;

{ TPOWERRAIL }

constructor TPowerRail.create( sender:TEvsSimpleGraph;
                               fonctionName:string;
                               symallias:string);
begin
  inherited create(sender,false,true,fonctionName,symallias);
  ffonction:=fonctionName;
  fallias:='pwr-'+inttostr(self.ID);
end;

function TPowerRail.codeBefore:string;
begin
result:='';
end;

function TPowerRail.codeAfter:string;
begin
result:='';
end;

function TPowerRail.isTerminal:boolean;
begin
result:=false;
end;

function TPowerRail.isVirtual:boolean;
begin
result:=false;
end;

procedure TPowerRail.doubleClick(objet:TEvsGraphObject);
begin
end;

function TPowerRail.getVarList: TStringList;
begin
     result:=nil;
end;

{ /TPOWERRAIL }

{ TCOMMENT }

constructor TComment.create(sender:TEvsSimpleGraph;fonctionName:string;symallias:string);
begin
  inherited create(sender);
  self.Brush.Color:=sender.Brush.Color;
  self.Pen.Color:=clBlack;
  ffonction:=fonctionName;
  with self do
     begin
     options:=[goSelectable,goShowCaption];
     SetBounds(sender.ClientToGraph(0,0).x,sender.ClientToGraph(0,0).Y,100,50);
     setText(symallias);
     end;
end;

procedure TComment.updatePosition(newx:longint;newy:longint);
begin
  self.moveby(newx,newy);
end;

function TComment.isTerminal:boolean;
begin
  result:=false;
end;

function TComment.isVirtual:boolean;
begin
  result:=false;
end;

function TComment.readText:string;
begin
  result:=text;
end;

procedure Tcomment.setText(strtext:string);
begin
  text:=strtext;
end;

procedure TComment.doubleClick(objet:TEvsGraphObject);
begin
  commentForm.Left:=objet.BoundsRect.Left;
  commentForm.Top:=objet.BoundsRect.top;
  commentForm.symbole:=self;
  commentForm.editComment.Text:=allias;
  commentForm.BackgroundColorButton.Brush.Color:=
              TEvsRectangularNode(self).Brush.Color;
  commentForm.TextcolorButton.Font.Color:=
              TEvsRectangularNode(self).Font.Color;
  commentForm.show;
end;

{ /TCOMMENT }

{ TBIT }

constructor TBit.create( sender:TEvsSimpleGraph;
                         fonctionName:string;
                         symallias:string);
begin
  inherited create(sender,true,true,fonctionName,symallias);
  if symallias<>'' then allias:=symallias;
  ffonction:=fonctionName;
  case ffonction of
     'contactNO' : begin
                   self.fCodeBefore:='';
                   self.fCodeAfter:='.state';
                   end;
     'contactNC' : begin
                   self.fCodeBefore:='NOT(';
                   self.fCodeAfter:='.state)';
                   end;
     end;
  fequation:=codeBefore+allias+codeAfter;
  fvarList:=TStringList.Create();
  fvarList.Add(allias);
end;

function TBit.codeBefore:string;
begin
   result:=fcodeBefore;
end;

function TBit.codeAfter:string;
begin
     result:=fCodeAfter;
end;

function TBit.isTerminal:boolean;
begin
  case ffonction of
  'contactNO' : result:=false;
  'contactNC' : result:=false;
  end;
end;

function TBit.isVirtual:boolean;
begin
  result:=false;
end;

procedure TBit.doubleClick(objet:TEvsGraphObject);
var
  i : integer;

begin
  bitForm.Left:=objet.BoundsRect.Left;
  bitForm.Top:=objet.BoundsRect.top;
  bitform.symbole:=self;

  // varList in listBox
  bitForm.contactListBox.Clear;
  for i:=0 to varList.Count-1 do
     if varList.Items[i].typeVar='BIT' then
        bitForm.contactListBox.items.Add(varList.Items[i].nameVar);
  // IOPLClist in listBox
  for i:=0 to ioPlcList.Count-1 do
     if (ioPlcList.Items[i].typeVar='INPUT') or
        (ioPlcList.Items[i].typeVar='OUTPUT') then
        bitForm.contactListBox.items.Add(ioPlcList.Items[i].nameVar);
  // timerlist in listBox
  for i:=0 to timerList.Count-1 do
        bitForm.contactListBox.items.Add(timerList.Items[i].nameVar);
  bitForm.contactListBox.Sorted:=true;
  bitForm.nameField.text:=self.fallias;
  bitForm.nameField.SelectAll;
  if bitForm.CheckBoxSystemBit.checked then
     for i:=1 to Form1.SystemGrid.RowCount-1 do
       if form1.SystemGrid.Cells[0,i]<>'' then
       begin
         if form1.SystemGrid.Cells[1,i]='BIT' then
            begin
            bitform.contactListBox.Items.Add(form1.SystemGrid.Cells[0,i]);
            end;
       end;
  bitForm.Caption:='Select Contact';
  bitForm.show;

end;

procedure TBit.setEquation(equat:string);
begin
  fequation:=equat;
end;

function TBit.getVarList: TStringList;
begin
  fvarList.Clear;
  fvarList.Add(allias);
  result:=fvarList;
end;

procedure TBit.SetVar(list:TStringList);
begin
  allias:=list[0];
  Text:=list[0];
  textAllias.Text:=list[0];
end;

procedure TBit.SetVar(index:integer;name:string);
begin
  allias:=name;
  Text:=name;
  textAllias.Text:=name;
end;

procedure TBit.HighLight(state:boolean);
begin
  case ffonction of
       'contactNO' : begin
                     if state then
                        Brush.Color:=RGBToColor(onColorR,onColorV,onColorB)
                     else Brush.Color:=RGBToColor(offColorR,offColorV,offColorB);
                     end;
       'contactNC' : begin
                     if state then
                        Brush.Color:=RGBToColor(offColorR,offColorV,offColorB)
                     else Brush.Color:=RGBToColor(onColorR,onColorV,onColorB);
                     end;
       end;
  fhighlighted:=true;
end;

procedure TBit.highLightblue;
begin
  Brush.Color:=clSkyBlue;
  fhighlighted:=true;
end;

procedure TBit.unHighlight;
begin
  Brush.Color:=fSaveBrushColor;
end;

{ /TBIT }

{ TCOIL }

constructor Tcoil.create( sender:TEvsSimpleGraph;
                          fonctionName:string;
                          symallias:string);
begin
  inherited create(sender,true,false,fonctionName,symallias);
  if symallias<>'' then allias:=symallias;
  ffonction:=fonctionName;
  fvarList:=TStringList.Create();
  fvarList.Add(allias);
end;

destructor Tcoil.destroy;
begin
  inherited;
  finput.Delete;
  ftextAllias.delete;
end;

function Tcoil.codeBefore:string;
begin
     case ffonction of
     'coilNO'    : result:=fallias+'.state:=(';
     'coilSET'   : result:='if ';
     'coilRESET' : result:='if ';
     end;
end;

function Tcoil.codeAfter:string;
begin
  case ffonction of
  'coilNO'    : result:=');';
  'coilSET'   : result:=' then '+fallias+'.setState;';
  'coilRESET' : result:=' then '+fallias+'.resetState;';
  end;
end;

function Tcoil.isTerminal:boolean;
begin
  case ffonction of
  'coilNO'    : result:=true;
  'coilSET'   : result:=true;
  'coilRESET' : result:=true;
  end;
end;

function Tcoil.isVirtual:boolean;
begin
  result:=false;
end;

procedure Tcoil.doubleClick(objet:TEvsGraphObject);
var
  i : integer;

begin
  bitForm.Left:=objet.BoundsRect.Left;
  bitForm.Top:=objet.BoundsRect.top;
  bitform.symbole:=self;

  // afficher la liste des variables dans la listBox
  bitForm.contactListBox.Clear;
  for i:=0 to varList.Count-1 do
     if varList.Items[i].typeVar='BIT' then
        bitForm.contactListBox.items.Add(varList.Items[i].nameVar);
  // ajouter la liste des IOPLC dans la listBox
  for i:=0 to ioPlcList.Count-1 do
     if ioPlcList.Items[i].typeVar='OUTPUT' then
        bitForm.contactListBox.items.Add(ioPlcList.Items[i].nameVar);
  bitForm.contactListBox.Sorted:=true;
  bitForm.nameField.text:=self.fallias;
  bitForm.Caption:='Select Coil';
  bitForm.show;

end;

function TCoil.getVarList: TStringList;
begin
  fvarList.Clear;
  fvarList.add(allias);
  result:=fvarList;
end;

procedure TCoil.SetVar(list:TStringList);
begin
  allias:=list[0];
  Text:=list[0];
  textAllias.Text:=list[0];
end;

procedure TCoil.SetVar(index:integer;name:string);
begin
  allias:=name;
  Text:=name;
  textAllias.Text:=name;
end;

procedure TCoil.HighLight(state:boolean);
begin
  case ffonction of
       'coilNO' :    begin
                     if state then
                        Brush.Color:=RGBToColor(onColorR,onColorV,onColorB)
                     else Brush.Color:=fSaveBrushColor;
                     end;
       'coilSET' :   begin
                     if state then
                        Brush.Color:=RGBToColor(onColorR,onColorV,onColorB)
                     else Brush.Color:=fSaveBrushColor;
                     end;
       'coilRESET' : begin
                     if state then
                        Brush.Color:=RGBToColor(onColorR,onColorV,onColorB)
                     else Brush.Color:=fSaveBrushColor;
                     end;
       end;
  fhighlighted:=true;
end;

procedure TCoil.highLightblue;
begin
  brush.Color:=clSkyBlue;
  fhighlighted:=true;
end;

procedure TCoil.unHighlight;
begin
  Brush.Color:=fSaveBrushColor;
end;

{ /TCOIL }

{ TCoilFront }

function TFrontCoil.codeBefore:string;
begin
  case ffonction of
       'BobineP' : result:='if ';
       'BobineN' : result:='if not ';
       end;
end;

function TFrontcoil.codeAfter:string;
begin
case ffonction of
     'BobineP' : result:=' then begin if not ('+fallias+'.OldState) then begin '+fallias+'.NumScan:=CurrScan+1; end; end '+#10+
                         'else begin if '+fallias+'.OldState then '+fallias+'.OldState:=false; end;';
     'BobineN' : result:=' then begin if not ('+fallias+'.OldState) then begin '+fallias+'.NumScan:=CurrScan+1; end; end '+#10+
                         'else begin if ('+fallias+'.OldState) then '+fallias+'.OldState:=false; end;';
     end;
end;

function TFrontCoil.isTerminal:boolean;
begin
  result:=true;
end;

function TFrontCoil.isVirtual:boolean;
begin
  result:=false;
end;

procedure TFrontcoil.doubleClick(objet:TEvsGraphObject);
var
  i : integer;

begin
  bitForm.Left:=objet.BoundsRect.Left;
  bitForm.Top:=objet.BoundsRect.top;
  bitform.symbole:=self;

  // afficher la liste des variables dans la listBox
  bitForm.contactListBox.Clear;
  for i:=0 to varList.Count-1 do
     if (varList.Items[i].typeVar='BIT') or
        (varList.Items[i].typeVar='PULSE') then
        bitForm.contactListBox.items.Add(varList.Items[i].nameVar);
  // ajouter la liste des IOPLC dans la listBox
  for i:=0 to ioPlcList.Count-1 do
     if ioPlcList.Items[i].typeVar='OUTPUT' then
        bitForm.contactListBox.items.Add(ioPlcList.Items[i].nameVar);
  bitForm.contactListBox.Sorted:=true;
  bitForm.nameField.text:=self.fallias;
  bitForm.Caption:='Select Coil';
  bitForm.show;

end;

{ TCoilFront }

{ TStore }

constructor TStore.create( sender:TEvsSimpleGraph;
                           fonctionName:string;
                           var1:string;
                           var2:string);
var
  alliasValue   : string;
begin
  alliasValue:=var2+':='+var1;
  inherited create(sender,true,false,fonctionName,alliasValue);
  ffonction:=fonctionName;
  fvar1:=var1;
  fvar2:=var2;
  fequation:='('+fvar2+':='+fvar1+')';
  fvarList:=TStringList.Create();
  fvarList.Add(fvar1);
  fvarList.Add(fvar2);
end;

function TStore.codeBefore:string;
begin
result:='if ';
end;

function TStore.codeAfter:string;
begin
result:=' then '+fvar2+':='+fvar1+';';
end;

function TStore.isTerminal:boolean;
begin
  result:=true;
end;

function TStore.isVirtual:boolean;
begin
  result:=false;
end;

procedure TStore.doubleClick(objet:TEvsGraphObject);
var
  i            : integer;
  selectedVar  : integer;
begin
  storeForm.Left:=objet.BoundsRect.Left;
  storeForm.Top:=objet.BoundsRect.top;
  storeForm.fsymbole:=self;
  // Variable List
  storeForm.ComboBoxVar1.Clear;
  storeForm.ComboBoxVar2.Clear;
  for i:=0 to varList.Count-1 do
     if varList.Items[i].typeVar<>'Bit' then
        begin
        storeForm.ComboBoxVar1.Items.Add(varList.Items[i].nameVar);
        storeForm.ComboBoxVar2.Items.Add(varList.Items[i].nameVar);
        end;
  if storeForm.CheckBoxSystemVar.checked then
     begin
     for i:=1 to form1.SystemGrid.RowCount-1 do
       if (form1.SystemGrid.Cells[1,i]<>'BIT') and
          (form1.SystemGrid.Cells[0,i]<>'') then
          begin
          storeForm.ComboBoxVar1.Items.Add(form1.SystemGrid.Cells[0,i]);
          storeForm.ComboBoxVar2.Items.Add(form1.SystemGrid.Cells[0,i]);
          end;
     end;
  storeForm.ComboBoxVar1.Sorted:=true;
  storeForm.ComboBoxVar2.Sorted:=true;
  // select Var and test if is a variable
  selectedVar:=storeForm.ComboBoxVar1.Items.IndexOf(Tstore(objet).Var1);
  if (selectedVar=-1) then
     begin
     if TStore(objet).var1='' then storeForm.ComboBoxVar1.ItemIndex:=0
     else storeForm.ComboBoxVar1.Text:=var1;
     end
     else storeForm.ComboBoxVar1.ItemIndex:=selectedVar;
  storeForm.ComboBoxVar2.ItemIndex:=storeForm.ComboBoxVar2.Items.IndexOf(var2);
  storeForm.show;
end;

function TStore.getVarList: TStringList;
begin
  fvarList.clear;
  fvarList.Add(var1);
  fvarList.Add(var2);
  result:=fvarList;
end;

procedure TStore.SetVar(list:TStringList);
begin
  var1:=fvarList[0];
  var2:=fvarList[1];
  textAllias.Text:=var2+'='+var1;
  equation:=var2+':='+var1;
  allias:=textAllias.Text;
end;

procedure TStore.SetVar(index:integer;name:string);
begin
  case index of
       0 : var1:=name;
       1 : var2:=name;
       end;
  textAllias.Text:=var2+'='+var1;
  equation:=var2+':='+var1;
  allias:=textAllias.Text;
end;

{ /TStore }

{ TVIRTUAL }

constructor TVirtual.create( sender:TEvsSimpleGraph;
                             fonctionName:string;
                             symallias:string);
begin
  inherited create(sender,true,true,fonctionName,symallias);
  ffonction:=fonctionName;
end;

function TVirtual.codeBefore:string;
begin
     result:=fequation;
end;

function TVirtual.codeAfter:string;
begin
     result:='';
end;

function TVirtual.isTerminal:boolean;
begin
     result:=false;
end;

function TVirtual.isVirtual:boolean;
begin
  result:=true;
end;

procedure TVirtual.setEquation(equat:string);
begin
     fequation:=fequation+equat;
end;

{ /TVIRTUAL }

{ TCompare }

constructor TCompare.create( sender:TEvsSimpleGraph;
                             fonctionName:string;
                             var1:string;
                             var2:string);
var
  alliasValue   : string;
  opCompare     : string;
begin
  case fonctionName of
     'equals'          : opCompare:='=';
     'notequals'       : opCompare:='<>';
     'greater'         : opCompare:='>';
     'greaterOrEquals' : opCompare:='>=';
     'less'            : opCompare:='<';
     'lessOrEquals'    : opCompare:='<=';
     end;
  alliasValue:=var1+opCompare+var2+' ?';
  inherited create(sender,true,true,fonctionName,alliasValue);
  ffonction:=fonctionName;
  fvar1:=var1;
  fvar2:=var2;
  fequation:='('+fvar1+' '+getOperateur+' '+fvar2+')';
  fvarList:=TStringList.Create();
  fvarList.Add(fvar1);
  fvarList.Add(fvar2);
end;

function TCompare.isTerminal:boolean;
begin
     result:=false;
end;

function TCompare.isVirtual:boolean;
begin
  result:=false;
end;

procedure TCompare.setEquation(equat:string);
begin
     fequation:=equat;
end;

function TCompare.getOperateur:string;
begin
    case ffonction of
       'equals'          : result:='=';
       'notequals'       : result:='<>';
       'greater'         : result:='>';
       'greaterOrEquals' : result:='>=';
       'less'            : result:='<';
       'lessOrEquals'    : result:='<=';
       end;
end;

procedure TCompare.doubleClick(objet:TEvsGraphObject);
var
  i            : integer;
  selectedVar  : integer;
begin
  compareForm.Left:=objet.BoundsRect.Left;
  compareForm.Top:=objet.BoundsRect.top;
  compareForm.fsymbole:=self;
  CompareForm.imageOperateur.Picture.LoadFromFile(ExtractFilePath(paramstr(0))+'/images/'+ffonction+'.png');
  // Variable List
  CompareForm.ComboBoxVar1.Clear;
  CompareForm.ComboBoxVar2.Clear;
  for i:=0 to varList.Count-1 do
     if varList.Items[i].typeVar<>'BIT' then
        begin
        CompareForm.ComboBoxVar1.Items.Add(varList.Items[i].nameVar);
        CompareForm.ComboBoxVar2.Items.Add(varList.Items[i].nameVar);
        end;
  if CompareForm.CheckBoxSystemVar.checked then
     begin
     for i:=1 to form1.SystemGrid.RowCount-1 do
       if (form1.SystemGrid.Cells[1,i]<>'BIT') and
          (form1.SystemGrid.Cells[0,i]<>'') then
          begin
          CompareForm.ComboBoxVar1.Items.Add(form1.SystemGrid.Cells[0,i]);
          CompareForm.ComboBoxVar2.Items.Add(form1.SystemGrid.Cells[0,i]);
          end;
     end;
  CompareForm.ComboBoxVar1.Sorted:=true;
  CompareForm.ComboBoxVar2.Sorted:=true;
  // select Var and test if is a variable
  selectedVar:=CompareForm.ComboBoxVar1.Items.IndexOf(TCompare(objet).Var1);
  if (selectedVar=-1) then
     begin
     if TCompare(objet).var1='' then CompareForm.ComboBoxVar1.ItemIndex:=0
     else CompareForm.ComboBoxVar1.Text:=var1;
     end
     else CompareForm.ComboBoxVar1.ItemIndex:=selectedVar;
  selectedVar:=CompareForm.ComboBoxVar2.Items.IndexOf(TCompare(objet).Var2);
  if (selectedVar=-1) then
     begin
     if TCompare(objet).var2='' then CompareForm.ComboBoxVar2.ItemIndex:=0
     else CompareForm.ComboBoxVar2.Text:=var2;
     end
     else CompareForm.ComboBoxVar2.ItemIndex:=selectedVar;
  compareForm.show;
end;

function TCompare.getVarList: TStringList;
begin
  fvarList.clear;
  fvarList.Add(var1);
  fvarList.Add(var2);
  result:=fvarList;
end;

procedure TCompare.SetVar(list:TStringList);
begin
  var1:=fvarList[0];
  var2:=fvarList[1];
  textAllias.Text:=var1+getOperateur+var2+' ?';
  equation:='('+var1+getOperateur+var2+')';
  allias:=textAllias.text;
end;

procedure TCompare.SetVar(index:integer;name:string);
begin
  case index of
       0 : var1:=name;
       1 : var2:=name;
       end;
  textAllias.Text:=var1+getOperateur+var2+' ?';
  equation:='('+var1+getOperateur+var2+')';
  allias:=textAllias.Text;
end;

{ TMath }

constructor TMath.create( sender:TEvsSimpleGraph;
                             fonctionName:string;
                             var1:string;
                             var2:string;
                             var3:string);
var
  alliasValue   : string;
  operation     : string;
begin
  case fonctionName of
     'add'          : operation:='+';
     'sub'          : operation:='-';
     'div'          : operation:='div';
     'mult'         : operation:='*';
     end;
  alliasValue:=var3+'='+var1+operation+var2;
  inherited create(sender,true,false,fonctionName,alliasValue);
  ffonction:=fonctionName;
  fvar1:=var1;
  fvar2:=var2;
  fvar3:=var3;
  fequation:=fvar3+':='+fvar1+' '+getOperateur+' '+fvar2+';';
  fvarList:=TStringList.Create();
  fvarList.Add(fvar1);
  fvarList.Add(fvar2);
  fvarList.Add(fvar3);
end;

function TMath.isTerminal:boolean;
begin
     result:=true;
end;

function TMath.isVirtual:boolean;
begin
  result:=false;
end;

procedure TMath.setEquation(equat:string);
begin
     fequation:=equat;
end;

function TMath.getOperateur:string;
begin
    case ffonction of
       'add'          : result:='+';
       'sub'          : result:='-';
       'div'          : result:='div';
       'mult'         : result:='*';
       end;
end;

procedure TMath.doubleClick(objet:TEvsGraphObject);
var
  i            : integer;
  selectedVar  : integer;
begin
  mathForm.Left:=objet.BoundsRect.Left;
  mathForm.Top:=objet.BoundsRect.top;
  mathForm.fsymbole:=self;
  mathForm.imageOperateur.Picture.LoadFromFile(ExtractFilePath(paramstr(0))+'/images/'+ffonction+'.png');
  // Variable List
  mathForm.ComboBoxVar1.Clear;
  mathForm.ComboBoxVar2.Clear;
  for i:=0 to varList.Count-1 do
     if varList.Items[i].typeVar<>'BIT' then
        begin
        mathForm.ComboBoxVar1.Items.Add(varList.Items[i].nameVar);
        mathForm.ComboBoxVar2.Items.Add(varList.Items[i].nameVar);
        mathForm.ComboBoxVar3.Items.Add(varList.Items[i].nameVar);
        end;
  if mathForm.CheckBoxSystemVar.checked then
     begin
     for i:=1 to form1.SystemGrid.RowCount-1 do
       if (form1.SystemGrid.Cells[1,i]<>'BIT') and
          (form1.SystemGrid.Cells[0,i]<>'') then
          begin
          mathForm.ComboBoxVar1.Items.Add(form1.SystemGrid.Cells[0,i]);
          mathForm.ComboBoxVar2.Items.Add(form1.SystemGrid.Cells[0,i]);
          end;
     end;
  mathForm.ComboBoxVar1.Sorted:=true;
  mathForm.ComboBoxVar2.Sorted:=true;
  mathForm.ComboBoxVar3.Sorted:=true;
  // select Var and test if is a variable
  selectedVar:=mathForm.ComboBoxVar1.Items.IndexOf(TMath(objet).Var1);
  if (selectedVar=-1) then
     begin
     if TMath(objet).var1='' then mathForm.ComboBoxVar1.ItemIndex:=0
     else mathForm.ComboBoxVar1.Text:=var1;
     end
     else mathForm.ComboBoxVar1.ItemIndex:=selectedVar;
  selectedVar:=mathForm.ComboBoxVar2.Items.IndexOf(TMath(objet).Var2);
  if (selectedVar=-1) then
     begin
     if TMath(objet).var2='' then mathForm.ComboBoxVar2.ItemIndex:=0
     else mathForm.ComboBoxVar2.Text:=var2;
     end
     else mathForm.ComboBoxVar2.ItemIndex:=selectedVar;
  mathForm.show;
end;

function TMath.codeBefore:string;
begin
result:='if ';
end;

function TMath.codeAfter:string;
begin
result:=' then '+equation;
end;

function TMath.getVarList: TStringList;
begin
  fvarList.clear;
  fvarList.Add(var1);
  fvarList.Add(var2);
  fvarList.Add(fvar3);
  result:=fvarList;
end;

procedure TMath.SetVar(list:TStringList);
begin
  var1:=fvarList[0];
  var2:=fvarList[1];
  var3:=fvarList[2];
  textAllias.Text:=var3+'='+var1+getOperateur+var2;
  equation:='('+var3+':='+var1+getOperateur+var2+')';
  allias:=textAllias.text;
end;

procedure TMath.SetVar(index:integer;name:string);
begin
  case index of
     0 : var1:=name;
     1 : var2:=name;
     2 : var3:=name;
     end;
  textAllias.Text:=var3+'='+var1+getOperateur+var2;
  equation:='('+var3+':='+var1+getOperateur+var2+')';
  allias:=textAllias.text;
end;

{ /TMath }

{ TTimerObject }

constructor TTimerObject.Create(sender:TEvsSimpleGraph;fonctionName,alliasValue:string;presetValue:word);
begin
  inherited create(sender,true,false,fonctionName,alliasValue);
  fpresetValue:=presetValue;
  fcurrentValue:=0;
  ftimerEnabled:=false;
  Hint:=alliasValue+' PRESET='+inttostr(presetValue);
  fvarList:=TStringList.Create(false);
end;

function TTimerObject.isTerminal:boolean;
begin
  result:=true;
end;

function TTimerObject.isVirtual:boolean;
begin
  result:=false;
end;

function TTimerObject.codeBefore:string;
begin
result:='if ';
end;

function TTimerObject.codeAfter:string;
begin
result:=' then '+allias+'.timerEnabled:=true else '+allias+'.reset;';
end;

function TTimerObject.getVarList: TStringList;
begin
  fvarList.clear;
  result:=fvarList;
end;

procedure TTimerObject.doubleClick(objet:TEvsGraphObject);
begin
with timerForm do
  begin
  Left:=grapheCurrent.GraphToClient(objet.BoundsRect.Left,objet.BoundsRect.Top).X;
  Top:=grapheCurrent.GraphToClient(objet.BoundsRect.Left,objet.BoundsRect.Top).Y;
  fsymbole:=self;
  case fonction of
     'Ton'    : caption:='Timer ON';
     'Toff'   : caption:='Timer OFF';
     'TFlash' : caption:='Flash';
     end;
  EditTimerName.Text:=allias;
  EditPresetValue.text:=inttostr(preset);
  EditTimerName.SelectAll;
  Show;
  end;
end;

procedure TTimerObject.highLight(etat:boolean);
begin
  if etat then
     brush.Color:=RGBToColor(onColorR,onColorV,onColorB)
  else
     brush.Color:=fSaveBrushColor;
end;

procedure TTimerObject.unhighLight;
begin
     brush.Color:=fSaveBrushColor;
end;

{ /TTimerObject }

{ TTon }

function TTon.codeAfter:string;
begin
result:=' then '+allias+'.timerEnabled:=true else begin '+allias+'.timerEnabled:=false; '+allias+'.reset; end;';
end;

{ TToff }

{ TTOff }

function TTOff.codeAfter:string;
begin
result:= ' then '+allias+'.timerEnabled:=true else '+
         allias+'.timerEnabled:=false;';

end;

{ /TTOff }

{ TFlash }

constructor TFlash.Create(sender:TEvsSimpleGraph;fonctionName,alliasValue:string;presetValueON,presetValueOFF:word);
begin
  inherited create(sender,fonctionName,alliasValue,presetValueON);
  fpresetON:=presetValueON;
  fpresetOFF:=presetValueOFF;
end;

function TFlash.codeAfter:string;
begin
result:= ' then '+allias+'.timerEnabled:=true else  begin '+
         allias+'.timerEnabled:=false; '+allias+'.state:=false; end;';

end;

procedure TFlash.doubleClick(objet:TEvsGraphObject);
begin
with flashForm do
  begin
  Left:=grapheCurrent.GraphToClient(objet.BoundsRect.Left,objet.BoundsRect.Top).X;
  Top:=grapheCurrent.GraphToClient(objet.BoundsRect.Left,objet.BoundsRect.Top).Y;
  fsymbole:=self;
  Caption:='Flash';
  EditTimerName.Text:=allias;
  EditPresetValueOn.text:=inttostr(fpresetON);
  EditPresetValueOff.text:=inttostr(fpresetOFF);
  EditTimerName.SelectAll;
  Show;
  end;
end;

end.

