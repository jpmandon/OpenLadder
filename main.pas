unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, usimplegraph,
  ExtCtrls, StdCtrls, Buttons, Menus, LadderGraphUnit, LadderSymbol,
  Types,  LCLType, ActnList, Grids,projectunit,
  unitnewprojectform, xmlunit,lad2Pas,fgl,VariableUnit,LazFileUtils,
  Generics.Collections,simulatorUnit,character,unitAboutForm;

type

  { TLadderGraphList }

  TLadderGraphList = class(specialize TFPGObjectList<TLadderGraph>)
       constructor Create(aFreeObjects: Boolean);
    end;

  { TIOList }

  TIOList = class(specialize TFPGObjectList<TIOPlc>)
       constructor Create(aFreeObjects: Boolean);
    end;

  { TVarList }

  TVarList = class(specialize TFPGObjectList<TVariable>)
       constructor Create(aFreeObjects: Boolean);
    end;

  { TSystemList }

  TSystemList = specialize TDictionary<string,string>;

  { TTimerList }

  TTimerList = class(specialize TFPGObjectList<TTimerVar>)
       constructor Create(aFreeObjects: Boolean);
    end;


type

  { TForm1 }

  TForm1 = class(TForm)
    addButton: TSpeedButton;
    coilFrontPbutton: TSpeedButton;
    coilFrontNbutton: TSpeedButton;
    divButton: TSpeedButton;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    itemFindRef: TMenuItem;
    LabelMult1: TLabel;
    LabelMult2: TLabel;
    LabelMult3: TLabel;
    aboutItem: TMenuItem;
    MenuItemSymbolToDataWatch: TMenuItem;
    MenuItemSetValue: TMenuItem;
    MenuItemRemoveVar: TMenuItem;
    MenuItemStartSim: TMenuItem;
    MenuItemStopSim: TMenuItem;
    MenuItemRemove: TMenuItem;
    MenuItemMoveUp: TMenuItem;
    MenuItemMoveDown: TMenuItem;
    MenuItemSetOn: TMenuItem;
    MenuItemPulseOff: TMenuItem;
    MenuItemPulseOn: TMenuItem;
    MenuItemSetOff: TMenuItem;
    MenuItemAddToDataWatch: TMenuItem;
    MenuItemStart: TMenuItem;
    MenuItemStop: TMenuItem;
    multButton: TSpeedButton;
    LabelDiv: TLabel;
    LabelMult: TLabel;
    PopupMenuDataWatchBit: TPopupMenu;
    PopupMenuCrossRef: TPopupMenu;
    dataWatchGrid: TStringGrid;
    compileIndicator: TShape;
    TimerGrid: TStringGrid;
    TabSheetTimer: TTabSheet;
    FlashButton: TSpeedButton;
    TimerOnButton: TSpeedButton;
    simulatorRunIndicator: TShape;
    subButton: TSpeedButton;
    itemCopySymbol: TMenuItem;
    itemPasteSymbol: TMenuItem;
    itemPaste: TMenuItem;
    itemCopy: TMenuItem;
    itemSimulate: TMenuItem;
    LabelAdd: TLabel;
    LabelSub: TLabel;
    retractVarButton: TShape;
    expandVarButton: TShape;
    crossRefGrid: TStringGrid;
    TabSheetTime: TTabSheet;
    TabSheetDataWatch: TTabSheet;
    TabSheetMath: TTabSheet;
    TabSheetCrossRef: TTabSheet;
    TimerOffButton: TSpeedButton;
    TimerPulse: TTimer;
    TimerSimulator: TTimer;
    TimerIOplcGrid: TTimer;
    TimerVarGrid: TTimer;
    // Variables
    VariablesPageControl: TPageControl;

    titreVariables: TShape;
    LabelTitreVariables: TLabel;

    tabSheetSystem: TTabSheet;
    SystemGrid: TStringGrid;
    TabSheetVar: TTabSheet;
    VARGrid: TStringGrid;
    TabSheetIO: TTabSheet;
    IOplcGrid: TStringGrid;

    // main menu
    MainMenu: TMainMenu;

    ItelmProject: TMenuItem;
    itemNew: TMenuItem;
    itemOpen: TMenuItem;
    itemSave: TMenuItem;
    itemSaveAs: TMenuItem;
    itemExit: TMenuItem;

    itemPLC: TMenuItem;
    itemCompile: TMenuItem;

    // popup menu
    PopupMenuGraphe: TPopupMenu;
    itemAddCommentOnGraph: TMenuItem;

    PopupLadderTabSheet: TPopupMenu;
    itemLadderClose: TMenuItem;

    PopupTitreBlock: TPopupMenu;
    itemAddBlock: TMenuItem;

    PopupBlock: TPopupMenu;
    itemOpenBlock: TMenuItem;
    itemRenameBlock: TMenuItem;

    PopupMenuSymbole: TPopupMenu;
    itemDeleteSymbol: TMenuItem;

    // Symbols
    contactTools: TPageControl;
    // Basic
    tabsheetBasic: TTabSheet;
    powerRail: TSpeedButton;
    contactNObutton: TSpeedButton;
    contactNCbutton: TSpeedButton;
    coilNObutton: TSpeedButton;
    coilSETbutton: TSpeedButton;
    coilRESETbutton: TSpeedButton;
    CommentButton: TButton;
    CommentLabel: TLabel;
    // Compare
    TabSheetCompare: TTabSheet;
    equalsButton: TSpeedButton;
    LabelEquals: TLabel;
    notEqualsButton: TSpeedButton;
    LabelnotEquals: TLabel;
    greaterButton: TSpeedButton;
    greaterLabel: TLabel;
    greaterEqualsButton: TSpeedButton;
    greaterEqualsLabel: TLabel;
    lesserButton: TSpeedButton;
    lesserLabel: TLabel;
    lesserEqualsButton: TSpeedButton;
    lesserEqualsLabel: TLabel;
    // Store
    TabSheetStore: TTabSheet;
    storeButton: TSpeedButton;
    storeLabel: TLabel;

    // Graphe
    ladderSurface: TPageControl;

    titreProjectTree: TShape;
    LabelTitreProjectTree: TLabel;
    projectTree: TTreeView;

    // trait de separation projet/ladder
    traitProjectTree: TShape;
    traitHorizontalHaut: TShape;


    // Graphe events
    procedure addButtonClick(Sender: TObject);
    procedure coilFrontNbuttonClick(Sender: TObject);
    procedure coilFrontPbuttonClick(Sender: TObject);
    procedure crossRefGridDblClick(Sender: TObject);
    procedure dataWatchGridContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure dataWatchGridPrepareCanvas(Sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure divButtonClick(Sender: TObject);
    procedure FlashButtonClick(Sender: TObject);
    procedure IOplcGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure aboutItemClick(Sender: TObject);
    procedure MenuItemMoveDownClick(Sender: TObject);
    procedure MenuItemMoveUpClick(Sender: TObject);
    procedure MenuItemPulseOnClick(Sender: TObject);
    procedure MenuItemRemoveClick(Sender: TObject);
    procedure MenuItemRemoveVarClick(Sender: TObject);
    procedure MenuItemSetOffClick(Sender: TObject);
    procedure MenuItemSetOnClick(Sender: TObject);
    procedure MenuItemSetValueClick(Sender: TObject);
    procedure MenuItemStartSimClick(Sender: TObject);
    procedure MenuItemStopSimClick(Sender: TObject);
    procedure MenuItemSymbolToDataWatchClick(Sender: TObject);

    // Vartabsheet buttons
    procedure reDimVarTabSheetLarge;
    procedure reDimVarTabSheetSmall;
    procedure expandVarButtonClick(Sender: TObject);
    procedure retractVarButtonClick(Sender: TObject);

    procedure CommentButtonClick(Sender: TObject);
    procedure equalsButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure greaterButtonClick(Sender: TObject);
    procedure greaterEqualsButtonClick(Sender: TObject);
    procedure IOplcGridContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure IOplcGridDblClick(Sender: TObject);
    procedure IOplcGridEditingDone(Sender: TObject);
    procedure IOplcGridHeaderClick(Sender: TObject; IsColumn: Boolean;
      Index: Integer);
    procedure itemCompileClick(Sender: TObject);
    procedure itemCopySymbolClick(Sender: TObject);
    procedure itemDeleteSymbolClick(Sender: TObject);
    procedure itemExitClick(Sender: TObject);
    procedure itemFindRefClick(Sender: TObject);
    procedure itemLadderCloseClick(Sender: TObject);
    procedure itemNewClick(Sender: TObject);
    procedure itemOpenClick(Sender: TObject);
    procedure itemPasteSymbolClick(Sender: TObject);
    procedure itemSaveAsClick(Sender: TObject);
    procedure itemSaveClick(Sender: TObject);
    procedure itemSimulateClick(Sender: TObject);
    procedure ladderSurfaceChange(Sender: TObject);
    procedure ladderSurfaceCloseTabClicked(Sender: TObject);
    procedure ladderSurfaceContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure lesserButtonClick(Sender: TObject);
    procedure lesserEqualsButtonClick(Sender: TObject);
    procedure itemAddCommentOnGraphClick(Sender: TObject);
    procedure MenuItemAddToDataWatchClick(Sender: TObject);
    procedure MenuItemStartClick(Sender: TObject);
    procedure MenuItemStopClick(Sender: TObject);
    procedure multButtonClick(Sender: TObject);
    procedure notEqualsButtonClick(Sender: TObject);


    // ProjectTree events
    function getStringFromLevel(treePath:string;level:integer):string;
    function getLevelFromString(treePath:string;levelString:string):integer;
    procedure projectTreeContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure itemAddBlockClick(Sender: TObject);
    procedure itemOpenBlockClick(Sender: TObject);
    procedure itemRenameBlockClick(Sender: TObject);
    procedure projectTreeEditingEnd(Sender: TObject; Node: TTreeNode;
      Cancel: Boolean);

    procedure coilNObuttonClick(Sender: TObject);
    procedure coilRESETbuttonClick(Sender: TObject);
    procedure coilSETbuttonClick(Sender: TObject);
    procedure contactNCbuttonClick(Sender: TObject);
    procedure contactNObuttonClick(Sender: TObject);
    procedure powerRailClick(Sender: TObject);

    procedure storeButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure saveClick(Sender: TObject);
    procedure subButtonClick(Sender: TObject);
    procedure SystemGridContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure SystemGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure SystemGridHeaderClick(Sender: TObject; IsColumn: Boolean;
      Index: Integer);
    procedure TimerIOplcGridTimer(Sender: TObject);
    procedure TimerOffButtonClick(Sender: TObject);
    procedure TimerOnButtonClick(Sender: TObject);
    procedure TimerPulseTimer(Sender: TObject);
    procedure TimerSimulatorTimer(Sender: TObject);
    procedure TimerVarGridTimer(Sender: TObject);
    procedure traitProjectTreeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure traitProjectTreeMouseEnter(Sender: TObject);
    procedure traitProjectTreeMouseLeave(Sender: TObject);
    procedure traitProjectTreeMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure traitProjectTreeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    procedure error(message:string);
    procedure addNewBloc( blocName : string );
    procedure openBlock(blocName:string);
    procedure traitVariablesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure traitVariablesMouseEnter(Sender: TObject);
    procedure traitVariablesMouseLeave(Sender: TObject);
    procedure traitVariablesMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure traitVariablesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure VARGridContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure VARGridDblClick(Sender: TObject);
    procedure VARGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure VARGridEditingDone(Sender: TObject);
    procedure VARGridHeaderClick(Sender: TObject; IsColumn: Boolean;
      Index: Integer);
    procedure VariablesPageControlChange(Sender: TObject);

    { UTILITY }
    procedure lockMenu;
    procedure unLockMenu;

  private

  public
    traitProjectTreeSelected      : boolean;
    traitProjectTreeMouseSelected : boolean;
    traitVariablesSelected        : boolean;
    traitVariablesMouseselected   : boolean;
    columnGPIO                    : TGridColumn;
    columnTypeGPIO                : TGridColumn;
    projectName                   : string;
    projectPath                   : string;
    projectPLC                    : string;
    selectedTreeStr               : string;
    VarCol,VarRow                 : integer;
    IOPlcCol,IOPlcRow             : integer;

    // form project new
    askForNew                     : boolean;
    projectCurrent                : TProject;

    // project functions
    procedure newProject;




  end;

const
  widthTabVar=122;
var
  Form1            : TForm1;
  ladderGraphList  : TLadderGraphList;
  ioPlcList        : TIOList;
  varList          : TVarList;
  systemVarList    : TSystemList;
  timerList        : TTimerList;
  crossRefList     : TSymbolList;
  blocCrossRefList : TStringList;
  classCrossRefList: TStringList;
  copiedSymbolList : TSymbolList;
  grapheCurrent    : TLadderGraph;
  OldNodeName      : string;
  copieGraphe      : TLadderGraph;
  ladToPass        : TladToPas;
  popUpOrigin      : TTreeNode;
  oldBlocName      : string;
  currentEditedCol : integer=-1;
  currentEditedRow : integer=-1;

  columnVar        : TGridColumn;
  offsetIOGrid     : Integer;
  FirstScanIOGrid  : boolean;

  clipboardFull    : boolean;
  // simulator
  simulator            : TSimulator;
  dataWatchVarSelected : string;
  dataWatchInstruction : string='';

  graphError           : boolean;

implementation

{$R *.lfm}

{ TLadderGraphList }

constructor TLadderGraphList.Create(aFreeObjects: Boolean);
begin
  inherited Create(aFreeObjects);
end;

{ TIOPlc }

constructor TIOList.Create(aFreeObjects: Boolean);
begin
  inherited Create(aFreeObjects);
end;

{ TVariable }

constructor TVarList.Create(aFreeObjects: Boolean);
begin
  inherited Create(aFreeObjects);
end;

{ TTimerVar }

constructor TTimerList.Create(aFreeObjects: Boolean);
begin
  inherited Create(aFreeObjects);
end;


{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  inherited;
  ladderGraphList:=TladderGraphList.Create(false);
  { IO PLC List and Combobox }
  ioPlcList:=TIOList.Create(false);
  columnTypeGPIO:=IOplcGrid.Columns[2];
  columnTypeGPIO.ButtonStyle:=cbsPickList;
  columnTypeGPIO.PickList.Clear;
  columnTypeGPIO.PickList.Add('INPUT');
  columnTypeGPIO.PickList.Add('OUTPUT');
  columnTypeGPIO.PickList.Add('ANALOG');

  { Var List and Combobox }
  varList:=TVarList.Create(false);
  varList.clear;
  columnVar:=VARGrid.Columns[1];
  columnVar.ButtonStyle:=cbsPickList;
  columnVar.PickList.Clear;
  columnVar.PickList.Add('BIT');
  columnVar.PickList.Add('PULSE');
  columnVar.PickList.Add('INT');
  columnVar.PickList.Add('DINT');
  columnVar.PickList.Add('WORD');
  columnVar.PickList.Add('DWORD');

  { system Var List }
  systemVarList:=TSystemList.create;

  { timer list }
  timerList:=TTimerList.create(false);

  { cross ref List }
  crossRefList:=TSymbolList.Create(false);
  blocCrossRefList:=TStringList.Create;
  classCrossRefList:=TStringList.Create;

  //offsetIOGrid:=80;
  FirstScanIOGrid:=true;

  // defaut grid selected
  VariablesPageControl.ActivePage:=VariablesPageControl.Pages[0];
  VariablesPageControl.Tag:=0;
  retractVarButton.Tag:=1;
  reDimVarTabSheetSmall;

  IOplcGrid.Options:=[goFixedHorzLine,goFixedVertLine,goHorzLine,goVertLine];
  VARGrid.Options:=[goFixedHorzLine,goFixedVertLine,goHorzLine,goVertLine];
  compileIndicator.Brush.Color:=clRed;
  form1.simulatorRunIndicator.Brush.Color:=clRed;
end;

procedure TForm1.saveClick(Sender: TObject);
begin
  projectCurrent.saveProject;
end;



{ move manager PROJECTTREE}

procedure TForm1.traitProjectTreeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     traitProjectTreeMouseselected:=true;
end;

procedure TForm1.traitProjectTreeMouseEnter(Sender: TObject);
begin
  traitProjectTree.Cursor:=crSizeWE;
  traitProjectTreeSelected:=true;
end;

procedure TForm1.traitProjectTreeMouseLeave(Sender: TObject);
begin
  traitProjectTree.Cursor:=crDefault;
  traitProjectTreeSelected:=false;
end;

procedure TForm1.traitProjectTreeMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if traitProjectTreeSelected and traitProjectTreeMouseSelected then
     begin
     projectTree.Width:=mouse.CursorPos.x;

     if grapheCurrent<>nil then
        begin
        ladderSurface.Width:=form1.width-projectTree.Width-VariablesPageControl.Width ;
        grapheCurrent.expandGraphOnPanel;
        end;
     Application.ProcessMessages;
     end;
end;

procedure TForm1.traitProjectTreeMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   traitProjectTreeMouseSelected:=false;
end;

{ move manager VARIABLES}

procedure TForm1.traitVariablesMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   //traitVariablesMouseselected:=true;
end;

procedure TForm1.traitVariablesMouseEnter(Sender: TObject);
begin
  //traitVariables.Cursor:=crSizeWE;
  //traitVariablesselected:=true;
end;

procedure TForm1.traitVariablesMouseLeave(Sender: TObject);
begin
  //traitVariables.Cursor:=crDefault;
  //traitVariablesselected:=false;
end;

procedure TForm1.traitVariablesMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  GridWidth : integer;
begin
  {
  if TabSheetIO.Focused then
     GridWidth:= IOplcGrid.ColWidths[0]+
                       IOplcGrid.ColWidths[1]+
                       IOplcGrid.ColWidths[2]+
                       IOplcGrid.ColWidths[3];

  if TabSheetVar.Focused then
     GridWidth:= VARGrid.ColWidths[0]+
                       VARGrid.ColWidths[1]+
                       VARGrid.ColWidths[2];
  if tabSheetSystem.Focused then
    GridWidth:= SystemGrid.ColWidths[0]+
                      SystemGrid.ColWidths[1]+
                      SystemGrid.ColWidths[2];
  if TabSheetCrossRef.Focused then
    GridWidth:= crossRefGrid.ColWidths[0]+
                      crossRefGrid.ColWidths[1]+
                      crossRefGrid.ColWidths[2];
  if TabSheetCrossRef.showing then
     begin
     GridWidth:= crossRefGrid.ColWidths[0]+
                       crossRefGrid.ColWidths[1];
     end;
  if traitVariablesSelected and traitVariablesMouseselected then
     if (VariablesPageControl.width<=GridWidth) or
        (form1.width-mouse.CursorPos.x<GridWidth) then
           if mouse.CursorPos.x<form1.Width-18 then
     begin
     traitVariables.Left:=mouse.CursorPos.x;
     ladderSurface.Width:=mouse.CursorPos.x-projectTree.width ;
     if grapheCurrent<>nil then
        grapheCurrent.expandGraphOnPanel;
     // state of expand and retract Buttons
     expandVarButton.Tag:=0;
     retractVarButton.Tag:=0;
     Application.ProcessMessages;
     end;
     }
end;

procedure TForm1.traitVariablesMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //traitVariablesMouseselected:=false;
end;

procedure TForm1.reDimVarTabSheetLarge;
var
  GridWidth : integer;
begin
  if VariablesPageControl.ActivePage.Caption='IO PLC' then
     begin
     GridWidth:= IOplcGrid.ColWidths[0]+
                       IOplcGrid.ColWidths[1]+
                       IOplcGrid.ColWidths[2]+
                       IOplcGrid.ColWidths[3];
     GridWidth:=GridWidth+widthTabVar;
     end;
  if VariablesPageControl.ActivePage.Caption='Variable' then
     begin
       GridWidth:= VARGrid.ColWidths[0]+
                         VARGrid.ColWidths[1]+
                         VARGrid.ColWidths[2];
       GridWidth:=GridWidth+widthTabVar;
     end;
  if VariablesPageControl.ActivePage.Caption='System' then
     begin
     GridWidth:= SystemGrid.ColWidths[0]+
                      SystemGrid.ColWidths[1]+
                      SystemGrid.ColWidths[2];
     GridWidth:=GridWidth+widthTabVar;
     end;
  if VariablesPageControl.ActivePage.Caption='TMR/CNT' then
     begin
     GridWidth:= TimerGrid.ColWidths[0];
     GridWidth:=GridWidth+widthTabVar;
     end;
  if VariablesPageControl.ActivePage.Caption='CrossRef' then
     begin
     GridWidth:= crossRefGrid.ColWidths[0]+
                       crossRefGrid.ColWidths[1]+
                       crossRefGrid.ColWidths[2];
     GridWidth:=GridWidth+widthTabVar;
     end;
  if VariablesPageControl.ActivePage.Caption='Data Watch' then
     begin
     GridWidth:= dataWatchGrid.ColWidths[0]+
                       dataWatchGrid.ColWidths[1];
     GridWidth:=GridWidth+widthTabVar;
     end;
  VariablesPageControl.Width:=GridWidth;
  //traitVariables.left:=form1.Width-GridWidth;
  if grapheCurrent<>nil then
        grapheCurrent.expandGraphOnPanel;
end;

procedure TForm1.reDimVarTabSheetSmall;
var
  GridWidth : integer;
begin
  if VariablesPageControl.ActivePage.Caption='IO PLC' then
     begin
     GridWidth:= IOplcGrid.ColWidths[0];
     GridWidth:=GridWidth+widthTabVar;
     end;
  if VariablesPageControl.ActivePage.Caption='Variable' then
     begin
       GridWidth:= VARGrid.ColWidths[0];
       GridWidth:=GridWidth+widthTabVar;
     end;
  if VariablesPageControl.ActivePage.Caption='System' then
     begin
     GridWidth:= SystemGrid.ColWidths[0];
     GridWidth:=GridWidth+widthTabVar;
     end;
  if VariablesPageControl.ActivePage.Caption='TMR/CNT' then
     begin
     GridWidth:= TimerGrid.ColWidths[0];
     GridWidth:=GridWidth+widthTabVar;
     end;
  if VariablesPageControl.ActivePage.Caption='CrossRef' then
     begin
     GridWidth:= crossRefGrid.ColWidths[0];
     GridWidth:=GridWidth+widthTabVar;
     end;
  if VariablesPageControl.ActivePage.Caption='Data Watch' then
     begin
     GridWidth:= dataWatchGrid.ColWidths[0];
     GridWidth:=GridWidth+widthTabVar;
     end;
  VariablesPageControl.Width:=GridWidth;
  //traitVariables.left:=form1.Width-GridWidth;
  if grapheCurrent<>nil then
        grapheCurrent.expandGraphOnPanel;
end;

procedure TForm1.expandVarButtonClick(Sender: TObject);
begin
  reDimVarTabSheetLarge;
  Application.ProcessMessages;
  // store last action on button
  expandVarButton.Tag:=1;
  retractVarButton.Tag:=0;
end;

procedure TForm1.retractVarButtonClick(Sender: TObject);
begin
  reDimVarTabSheetSmall;
  Application.ProcessMessages;
  // store last action on button
  expandVarButton.Tag:=0;
  retractVarButton.Tag:=1;
  grapheCurrent.expandGraphOnPanel;
end;


{ SYMBOL EVENT }

procedure TForm1.contactNObuttonClick(Sender: TObject);
begin
  if ladderGraphList.Count>0 then
  begin
   grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
   TBit.create(grapheCurrent,'contactNO','????????');
  end;
end;

procedure TForm1.contactNCbuttonClick(Sender: TObject);
begin
  if ladderGraphList.Count>0 then
  begin
     grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
     TBit.create(grapheCurrent,'contactNC','');
  end;
end;

procedure TForm1.coilNObuttonClick(Sender: TObject);
begin
    if ladderGraphList.Count>0 then
    begin
     grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
     TCoil.create(grapheCurrent,'coilNO','');
    end;
end;

procedure TForm1.coilSETbuttonClick(Sender: TObject);
begin
    if ladderGraphList.Count>0 then
    begin
     grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
     TCoil.create(grapheCurrent,'coilSET','');
    end;
end;

procedure TForm1.coilRESETbuttonClick(Sender: TObject);
begin
    if ladderGraphList.Count>0 then
    begin
     grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
     TCoil.create(grapheCurrent,'coilRESET','');
    end;
end;

procedure TForm1.CommentButtonClick(Sender: TObject);
begin
 itemAddCommentOnGraphClick(self);
end;

procedure TForm1.coilFrontPbuttonClick(Sender: TObject);
begin
  if ladderGraphList.Count>0 then
    begin
     grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
     TFrontCoil.create(grapheCurrent,'BobineP','');
    end;
end;

procedure TForm1.coilFrontNbuttonClick(Sender: TObject);
begin
  if ladderGraphList.Count>0 then
    begin
     grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
     TFrontCoil.create(grapheCurrent,'BobineN','');
    end;
end;

procedure TForm1.powerRailClick(Sender: TObject);
begin
    if ladderGraphList.Count>0 then
    begin
       grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
       TpowerRail.create(grapheCurrent,'powerRail','');
    end;
end;

procedure TForm1.equalsButtonClick(Sender: TObject);
begin
   if ladderGraphList.Count>0 then
    begin
    grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
    TCompare.create(grapheCurrent,'equals','?????','?????');
    end;
end;



procedure TForm1.notEqualsButtonClick(Sender: TObject);
begin
   if ladderGraphList.Count>0 then
    begin
    grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
    TCompare.create(grapheCurrent,'notequals','?????','?????');
    end;
end;

procedure TForm1.greaterButtonClick(Sender: TObject);
begin
   if ladderGraphList.Count>0 then
    begin
    grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
    TCompare.create(grapheCurrent,'greater','?????','?????');
    end;
end;

procedure TForm1.greaterEqualsButtonClick(Sender: TObject);
begin
   if ladderGraphList.Count>0 then
    begin
    grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
    TCompare.create(grapheCurrent,'greaterOrEquals','?????','?????');
    end;
end;

procedure TForm1.lesserButtonClick(Sender: TObject);
begin
  if ladderGraphList.Count>0 then
   begin
   grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
   TCompare.create(grapheCurrent,'less','?????','?????');
   end;
end;

procedure TForm1.lesserEqualsButtonClick(Sender: TObject);
begin
  if ladderGraphList.Count>0 then
   begin
   grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
   TCompare.create(grapheCurrent,'lessOrEquals','?????','?????');
   end;
end;



procedure TForm1.storeButtonClick(Sender: TObject);
begin
  if ladderGraphList.Count>0 then
   begin
   grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
   TStore.create(grapheCurrent,'store','?????','?????');
   end;
end;

{ MATH SYMBOL }

procedure TForm1.addButtonClick(Sender: TObject);
begin
   if ladderGraphList.Count>0 then
    begin
    grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
    TMath.create(grapheCurrent,'add','?????','?????','?????');
    end;
end;

procedure TForm1.subButtonClick(Sender: TObject);
begin
   if ladderGraphList.Count>0 then
    begin
    grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
    TMath.create(grapheCurrent,'sub','?????','?????','?????');
    end;
end;

procedure TForm1.divButtonClick(Sender: TObject);
begin
   if ladderGraphList.Count>0 then
    begin
    grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
    TMath.create(grapheCurrent,'div','?????','?????','?????');
    end;
end;

procedure TForm1.multButtonClick(Sender: TObject);
begin
   if ladderGraphList.Count>0 then
    begin
    grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
    TMath.create(grapheCurrent,'mult','?????','?????','?????');
    end;
end;

{ /MATH SYMBOL }

{ TIMER SYMBOL }

procedure TForm1.TimerOnButtonClick(Sender: TObject);
begin
   if ladderGraphList.Count>0 then
    begin
    grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
    TTOn.create(grapheCurrent,'Ton','?????',100);
    end;
end;

procedure TForm1.TimerOffButtonClick(Sender: TObject);
begin
   if ladderGraphList.Count>0 then
    begin
    grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
    TToff.create(grapheCurrent,'Toff','?????',100);
    end;
end;

procedure TForm1.FlashButtonClick(Sender: TObject);
begin
   if ladderGraphList.Count>0 then
    begin
    grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
    TFlash.create(grapheCurrent,'TFlash','?????',30,30);
    end;
end;

{ /TIMER SYMBOL }

// Project Tree Events

function TForm1.getStringFromLevel(treePath:string;level:integer):string;
var
  i           : integer;
  pathElement : string;
begin
 i:=0;
 repeat
 pathElement:=copy(treePath,0,pos('/',treePath)-1);
 if i=level then
  begin
  result:=pathElement;
  exit;
  end;
 treePath:=copy(treePath,pos('/',treePath)+1,length(treePath));
 i:=i+1;
 until pos('/',treePath)=0;
 if i=level then result:=treePath
 else result:='';
end;

function TForm1.getLevelFromString(treePath:string;levelString:string):integer;
var
  i           : integer;
  pathElement : string;
begin
 i:=0;
 repeat
 pathElement:=copy(treePath,0,pos('/',treePath)-1);
 if pathElement=levelString then
    begin
    result:=i;
    exit;
    end;
 treePath:=copy(treePath,pos('/',treePath)+1,length(treePath));
 i:=i+1;
 until pos('/',treePath)=0;
 if treePath=levelString then result:=i
 else result:=-1;
end;

procedure TForm1.projectTreeContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  textPath  : string;
begin
  if projectCurrent<>nil then
     begin
     popUpOrigin:=projectTree.GetNodeAt(MousePos.X,MousePos.y);
     if popUpOrigin.Selected then
        begin
         textPath:=popUpOrigin.GetTextPath;
         if getStringFromLevel(textPath,1)='Block' then
            begin
            if popUpOrigin.text='Block' then
               begin
               projectTree.PopupMenu:=PopupTitreBlock;
               exit;
               end
            else
               begin
               selectedTreeStr:=popUpOrigin.text;
               projectTree.PopupMenu:=PopUpBlock;;
               exit;
               end;
            end;
         if getStringFromLevel(textPath,1)<>'Block' then
            begin
            Handled:=true;
            exit;
            end
         end;
     end;
end;

procedure TForm1.error(message:string);
begin
     MessageDlg('erreur',message,mtWarning,[mbOK],'');
end;

// Blocs

procedure TForm1.addNewBloc(blocName : string);
var
  nom : string;
  ladderGraph : TLadderGraph;
begin
  nom:=UpperCase(blocName);
  if nom='' then
     nom:='Block'+inttostr(projectCurrent.fBlocList.count+1);
  ladderGraph:=TLadderGraph.create(self,ladderSurface,nom,true);
  ladderGraph.graphChanged:=true;
  grapheCurrent:=ladderGraph;
  graphecurrent.CommandMode:=cmEdit;
  projectCurrent.addBloc(nom,ladderGraph);
  ladderSurface.ActivePage:=ttabsheet(ladderSurface.Page[ladderGraphList.Count-1]);
end;

procedure TForm1.openBlock(blocName:string);
var
  i          : integer;
  loadObject : TXmlObject;
  blockExist : boolean;
  nameGraph  : string;
begin
     if grapheCurrent<>nil then
        grapheCurrent.unHighLightGraph;
     blockExist:=false;
     for i:=0 to ladderGraphList.Count-1 do
         begin
         nameGraph:=TLadderGraph(ladderGraphList[i]).name;
         if nameGraph=blocName then
            blockExist:=true;
         end;
     if not blockExist then
        begin
         grapheCurrent:=TLadderGraph.create(form1,ladderSurface,blocName,true);
         ladderGraphList.Add(grapheCurrent);
         loadObject:=TXmlObject.create;
         loadObject.loadBlocXML(grapheCurrent,projectCurrent.fpath+projectCurrent.fname+'-data/'+grapheCurrent.name+'.xml');
         FreeAndNil(loadObject);
         grapheCurrent.CommandMode:=cmEdit;
         ladderSurface.TabIndex:=ladderGraphList.Count-1;
        end;
end;

{ popup Menu Graphe }

procedure TForm1.ladderSurfaceContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
   selectedObject : TEvsGraphObject ;
begin
     grapheCurrent:=ladderGraphList[ladderSurface.TabIndex];
     if grapheCurrent.SelectedObjects.count>0 then
       begin
        if grapheCurrent.SelectedObjects.count=1 then
          begin
          selectedObject:=grapheCurrent.SelectedObjects.Items[0];
          if selectedObject.IsNode then
            ladderSurface.PopupMenu:=PopupMenuSymbole;
          end
          else ladderSurface.PopupMenu:=popupMenuGraphe;
       end;
end;

procedure TForm1.itemAddCommentOnGraphClick(Sender: TObject);
begin
  if ladderGraphList.Count>0 then
    begin
       grapheCurrent:=TLadderGraph(ladderGraphList[ladderSurface.ActivePage.TabIndex]);
       TComment.create(grapheCurrent,'comment','Comment');
    end;
end;

procedure TForm1.MenuItemAddToDataWatchClick(Sender: TObject);
var
   i       : integer;
   varName : string;
   found   : boolean;
begin
  // show data Watch tab
  TabSheetDataWatch.Visible:=true;
  // get variable to add to data watch
  varName:='';
  if VariablesPageControl.PageIndex=0 then
    if IOplcGrid.IsCellSelected[VarCol,VarRow] then
     varName:=IOplcGrid.Cells[VarCol,VarRow];
  if VariablesPageControl.PageIndex=1 then
     if VARGrid.IsCellSelected[VarCol,VarRow] then
        varName:=VARGrid.Cells[VarCol,VarRow];
  if VariablesPageControl.PageIndex=2 then
     if SystemGrid.IsCellSelected[VarCol,VarRow] then
        varName:=SystemGrid.Cells[VarCol,VarRow];
  // is the variable already in datawatch grid ?
  found:=false;
  if (varName<>'') then
     for i:=0 to dataWatchGrid.RowCount-1 do
         if dataWatchGrid.Cells[0,i]=varName then
            found:=true;
  // if not add it in the datawatch grid
  if not found then
     begin
     dataWatchGrid.Cells[0,dataWatchGrid.RowCount-1]:=varName;
     dataWatchGrid.RowCount:=dataWatchGrid.RowCount+1;
     end;
end;

procedure TForm1.MenuItemRemoveVarClick(Sender: TObject);
var
   i            : integer;
   col,row      : integer;
   variableName : string;
begin
  if VariablesPageControl.Pages[VariablesPageControl.PageIndex].Caption=
     'Variable' then
     if MessageDlg('','Are you sure ? ',mtWarning,[mbYes,mbNo],'')=mrYes then
        begin
         col:=VARGrid.Col;
         row:=VARGrid.Row;
         variableName:=VARGrid.Cells[col,row];
         for i:=0 to varList.Count-1 do
             if varList[i].nameVar=variableName then
                begin
                varList.Delete(i);
                VARGrid.DeleteRow(row);
                exit;
                end;
         end;
    if VariablesPageControl.Pages[VariablesPageControl.PageIndex].Caption=
     'IO PLC' then
     if MessageDlg('','Are you sure ? ',mtWarning,[mbYes,mbNo],'')=mrYes then
        begin
         col:=IOplcGrid.Col;
         row:=IOplcGrid.Row;
         variableName:=IOplcGrid.Cells[col,row];
         for i:=0 to ioPlcList.Count-1 do
             if ioPlcList[i].nameVar=variableName then
                begin
                ioPlcList.Delete(i);
                IOplcGrid.DeleteRow(row);
                exit;
                end;
         end;
end;

{ menu simulate }

var
   indexCurrentGraph   : integer;

procedure TForm1.MenuItemStartClick(Sender: TObject);
begin
  simulator:=TSimulator.create;
  simulator.startSimulator;
  indexCurrentGraph:=ladderGraphList.IndexOf(grapheCurrent);
  TimerSimulator.Enabled:=true;
  MenuItemStartSim.enabled:=false;
  MenuItemStopSim.enabled:=true;
  VariablesPageControl.ActivePage:=VariablesPageControl.Pages[4];
  VariablesPageControl.ActivePage:=VariablesPageControl.Pages[5];
  lockMenu;
end;

procedure TForm1.MenuItemStopClick(Sender: TObject);
var
   i : integer;
begin
  if simulator<>nil then
     begin
      TimerSimulator.enabled:=false;
      simulator.stopSimulator;
      FreeAndNil(simulator);
      MenuItemStopSim.enabled:=false;
      MenuItemStartSim.enabled:=true;
      for i:=1 to dataWatchGrid.rowcount-1 do
          dataWatchGrid.Cells[1,i]:='';
      grapheCurrent.unHighLightGraph;
      unLockMenu;
      VariablesPageControl.ActivePage:=VariablesPageControl.Pages[4];
      VariablesPageControl.ActivePage:=VariablesPageControl.Pages[5];
     end;
end;

procedure TForm1.TimerSimulatorTimer(Sender: TObject);
begin
  if dataWatchInstruction<>'' then
     begin
     simulator.sendSetRequest;
     dataWatchInstruction:='';
     end;
  if indexCurrentGraph<>ladderGraphList.IndexOf(grapheCurrent) then
     begin
     simulator.buildRequestList;
     indexCurrentGraph:=ladderGraphList.IndexOf(grapheCurrent);
     end;
  simulator.sendRequest;

end;

{ Popup Menu SYMBOLES }

procedure TForm1.itemDeleteSymbolClick(Sender: TObject);

begin
     grapheCurrent.deleteSymbol;
end;

procedure TForm1.itemCopySymbolClick(Sender: TObject);
var
   i : integer;
   xmlObject : TXmlObject;
begin
  if grapheCurrent.SelectedObjects.Count>0 then
    begin
    xmlObject:=TXmlObject.create;
    xmlObject.saveClipboardXML(grapheCurrent);
    FreeAndNil(xmlObject);
    clipboardFull:=true;
    end;
end;

procedure TForm1.itemPasteSymbolClick(Sender: TObject);
var
   xmlObject : TXmlObject;
begin
  if FileExists(projectCurrent.fpath+projectCurrent.fname+'-data/'+'clipboard.xml') then
    begin
    xmlObject:=TXmlObject.create;
    xmlObject.loadClipboardXML( grapheCurrent,
                                grapheCurrent.CursorPos.x,
                                grapheCurrent.CursorPos.y);
    FreeAndNil(xmlObject);
    grapheCurrent.CommandMode:=cmEdit;
    end;
end;

procedure TForm1.MenuItemSymbolToDataWatchClick(Sender: TObject);
begin
  if dataWatchGrid.Cols[0].IndexOf(TSymbol(grapheCurrent.SelectedObjects[0]).allias)=-1 then
     begin
     dataWatchGrid.Cells[0,dataWatchGrid.ColCount-1]:=TSymbol(grapheCurrent.SelectedObjects[0]).allias;
     dataWatchGrid.RowCount:=dataWatchGrid.RowCount+1;
     end;
end;

{ popup Menu Bloc }

procedure TForm1.itemAddBlockClick(Sender: TObject);
begin
  addNewBloc('');
end;

procedure TForm1.itemOpenBlockClick(Sender: TObject);
begin
  openBlock(selectedTreeStr);
end;

procedure TForm1.itemRenameBlockClick(Sender: TObject);
begin
  oldBlocName:=popUpOrigin.text;
  popUpOrigin.EditText;
end;

procedure TForm1.projectTreeEditingEnd(Sender: TObject; Node: TTreeNode;
  Cancel: Boolean);
var
   i : integer;
begin
  if popUpOrigin.text<>oldBlocName then
     begin
     projectCurrent.fBlocList[projectCurrent.fBlocList.IndexOf(oldBlocName)]:=popUpOrigin.text;
     if FileExists(projectcurrent.fpath+projectCurrent.fname+'-data/'+oldBlocName+'.xml') then
        RenameFile(projectcurrent.fpath+projectCurrent.fname+'-data/'+oldBlocName+'.xml',
                   projectcurrent.fpath+projectCurrent.fname+'-data/'+popUpOrigin.text+'.xml');
     for i:=0 to ladderSurface.PageCount-1 do;
         if ladderSurface.Page[i].Caption=oldBlocName then
           ladderSurface.Page[i].Caption:=popUpOrigin.Text;
     projectCurrent.saveProject;
     end;
end;

// Main Menu

// Project Menu

procedure TForm1.itemNewClick(Sender: TObject);
var
  changedGraph : boolean=false;
  i            : integer;
begin
   askForNew:=false;
   if projectCurrent<>nil then
      begin
       for i:=0 to ladderGraphList.Count-1 do
           if TLadderGraph(ladderGraphList[i]).graphChanged then changedGraph:=true;
       if changedGraph then
          if MessageDlg('','Save current project ? ',mtWarning,[mbYes,mbNo],'')=mrYes then
                 projectCurrent.saveProject;
       FreeAndNil(projectCurrent);
       i:=0;
       while i<LadderGraphList.Count do
              LadderGraphList.Delete(0);
      end;
   // clear crossref,datawatch and TMR grids
   for i:=crossRefGrid.RowCount-2 downto 1 do
       crossRefGrid.DeleteRow(i);
   crossRefGrid.Rows[1].Clear;
   for i:=dataWatchGrid.RowCount-2 downto 1 do
       dataWatchGrid.DeleteRow(i);
   dataWatchGrid.Rows[1].Clear;
   for i:=TimerGrid.RowCount-2 downto 1 do
       TimerGrid.DeleteRow(i);
   TimerGrid.Rows[1].Clear;

   ioPlcList.clear;
   varList.clear;
   timerList.clear;

   ladderGraphList.clear;
   ladderSurface.clear;
   newProjectForm.show;
   MenuItemStart.enabled:=true;
   MenuItemStartSim.enabled:=true;
   itemCompile.enabled:=true;
end;



procedure TForm1.itemExitClick(Sender: TObject);
begin
     form1.close;
end;

procedure TForm1.itemLadderCloseClick(Sender: TObject);
begin

end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  i       : integer;
  modified : boolean;
begin
     modified:=false;
     for i:=0 to ladderGraphList.Count-1 do
         if ladderGraphList[i].graphChanged then
            modified:=true;
     if modified then
        if MessageDlg('','Save current project ? ',mtWarning,[mbYes,mbNo],'')=mrYes then
               projectCurrent.saveProject;
     if simulator<>nil then simulator.stopSimulator;
end;

procedure TForm1.itemOpenClick(Sender: TObject);
var
  i                 : integer;
  selectProject     : TOpenDialog;
  selectedName      : string;
  selectedPath      : string;
  plc               : string;
  changedGraph      : boolean=false;
begin
      for i:=0 to ladderGraphList.Count-1 do
        if TLadderGraph(ladderGraphList[i]).graphChanged then changedGraph:=true;
      if changedGraph then
         if MessageDlg('','Save current project ? ',mtWarning,[mbYes,mbNo],'')=mrYes then
                projectCurrent.saveProject;
     selectProject:=TOpenDialog.Create(self);
     selectProject.filter:='Project files(*.prj)|*.prj';
     if SelectProject.Execute then
        begin
        selectedName:=selectProject.FileName;
        selectedPath:=ExtractFilePath(selectedName);
        selectedName:=ExtractFileName(selectedName);
        selectedName:=copy(selectedName,0,pos('.',selectedName)-1);
        if projectCurrent<>nil then
           begin
           i:=0;
           while i<LadderGraphList.Count do
               LadderGraphList.Delete(0);
           ladderGraphList.Clear;
           FreeAndNil(projectCurrent);
           end;
        ladderSurface.Clear;
        IOplcGrid.Options:= [goFixedHorzLine,goFixedVertLine,goHorzLine,
                             goVertLine,goDontScrollPartCell,goEditing];
        VARGrid.Options  := [goFixedHorzLine,goFixedVertLine,goHorzLine,
                             goVertLine,goDontScrollPartCell,goEditing];
        expandVarButton.visible:=True;
        retractVarButton.Visible:=True;
        VariablesPageControl.Visible:=True;
        Application.ProcessMessages;
        plc:='';
        projectCurrent:=TProject.create(selectedName,selectedPath,plc,projectTree);
        projectCurrent.loadProject;
        if projectCurrent.fBlocList.count>0 then
           begin
           openBlock(projectCurrent.fBlocList[0]);
           grapheCurrent.graphChanged:=false;
           grapheCurrent.CommandMode:=cmEdit;
           end;
        while crossRefGrid.RowCount>2 do
            crossRefGrid.DeleteRow(crossRefGrid.RowCount-1);
        crossRefGrid.Rows[1].Clear;
        while dataWatchGrid.RowCount>2 do
            dataWatchGrid.DeleteRow(dataWatchGrid.RowCount-1);
        dataWatchGrid.Rows[1].Clear;
        end;
     FreeAndNil(selectProject);
     MenuItemStart.enabled:=true;
     MenuItemStartSim.enabled:=true;
     itemCompile.enabled:=true;
end;

procedure TForm1.itemSaveAsClick(Sender: TObject);
var
   i              : integer;
   selectProject  : TSaveDialog;
   selectedName   : string;
   selectedPath   : string;
   oldPath        : string;
   OldName        : string;
begin
if projectCurrent<>nil then
   begin
   selectProject:=TSaveDialog.Create(self);
   selectProject.InitialDir:=projectCurrent.fpath;
   selectProject.filter:='Project files(*.prj)|*.prj';
   if SelectProject.Execute then
      begin
      selectedName:=selectProject.FileName;
      selectedPath:=ExtractFilePath(selectedName);
      selectedName:=ExtractFileNameOnly(ExtractFileNameWithoutExt(selectedName));
      oldPath:=projectCurrent.fpath;
      oldName:=projectCurrent.fname;
      projectCurrent.ReplaceProject(oldPath,oldName,selectedPath,selectedName);
      projectCurrent.fname:=selectedName;
      projectCurrent.fpath:=selectedPath;
      projectCurrent.updateProjectTree;
      FreeAndNil(selectProject);
      end
      else error('Nothing saved');
   end;
end;

procedure TForm1.itemSaveClick(Sender: TObject);
begin
  if projectCurrent<>nil then
     projectCurrent.saveProject;
end;

procedure TForm1.itemSimulateClick(Sender: TObject);
begin

end;

procedure TForm1.ladderSurfaceChange(Sender: TObject);
begin
  grapheCurrent.unHighLightGraph;
  grapheCurrent:=ladderGraphList[ladderSurface.ActivePageIndex];
end;

procedure TForm1.ladderSurfaceCloseTabClicked(Sender: TObject);
var
   i           : integer;
   index       : integer=-1;
   graphToFind : TLadderGraph;
   xmlDocument : TXmlObject;
   graphExist  : boolean;
begin
     for i:=0 to ladderGraphList.Count-1 do
     if TLadderGraph(ladderGraphList[i]).graphTabSheet=sender then
           begin
           index:=i;
           graphToFind:=TLadderGraph(ladderGraphList[i]);
           end;
     graphExist:=FileExists(projectCurrent.fpath+projectCurrent.fname+'-data/'+grapheCurrent.name+'.xml');
     if index<>-1 then
        begin
        if (graphToFind.graphChanged) or (not graphExist) then
           begin
           case MessageDlg('Save Logic Bloc','Save '+graphToFind.name+' ?',mtWarning,[mbYes,mbNo,mbCancel],'') of
           mrYes : begin
                   xmlDocument:=TXmlObject.create;
                   xmlDocument.saveBlockXML(graphToFind.name,graphToFind);
                   FreeAndNil(xmlDocument);
                   graphToFind.graphChanged:=false;
                   end;
           mrNo  : begin
                   if (not graphExist) and (not FileExists(projectCurrent.fpath+projectCurrent.fname+'-data/'+grapheCurrent.name+'.xml')) then
                      projectCurrent.fBlocList.Delete(projectCurrent.fBlocList.IndexOf(graphToFind.name));
                   xmlDocument:=TXmlObject.create;
                   xmlDocument.saveProjectXML;
                   FreeAndNil(xmlDocument);
                   end;

              end;
           end;
        ladderGraphList.Remove(graphToFind);
        sender.free;
        graphToFind.free;
        if ladderGraphList.Count>0 then
           grapheCurrent:=ladderGraphList[ladderSurface.ActivePageIndex];
        end;
end;

procedure TForm1.newProject;
var
   i : integer;
begin
  ioPlcList.Clear;
  varList.Clear;

  ladderSurface.clear;
  projectTree.visible:=true;
  projectCurrent:=TProject.create(projectName,projectPath,projectPLC,projectTree);
  addNewBloc('MAIN');
  projectCurrent.loadConfig;
  IOplcGrid.RowCount:=2;
  for i:=0 to IOplcGrid.ColCount-1 do
      IOplcGrid.Cells[i,1]:='';
  VARGrid.RowCount:=2;
  for i:=0 to VARGrid.ColCount-1 do
      VARGrid.Cells[i,1]:='';
end;

// PLC Menu

procedure TForm1.itemCompileClick(Sender: TObject);
var
  i                : integer;
  saveFile         : TXmlObject;
  loadFile         : TXmlObject;
  workGraph        : TLadderGraph;
  errGraph         : TGraphError;
  nbGraph          : integer;
  graphPathName    : string;

begin
graphError:=false;
// save all opened graph
 for i:=0 to ladderGraphList.count-1 do
     begin
     saveFile:=TXmlObject.create;
     saveFile.saveBlockXML(ladderGraphList[i].name,ladderGraphList[i]);
     ladderGraphList[i].graphChanged:=false;
     FreeandNil(saveFile);
     end;

// generate code for all graph
 for nbGraph:=0 to projectCurrent.fBlocList.Count-1 do
     begin
      // create a copy of graph
       workGraph:=TLadderGraph.create(form1,laddersurface,projectCurrent.fBlocList[nbGraph]+'1',false);
       loadFile:=TXmlObject.create;
       graphPathName:=projectCurrent.fpath+projectCurrent.fname+'-data/'+projectCurrent.fBlocList[nbGraph]+'.xml';
       loadFile.loadBlocXML(workGraph,graphPathName);
       freeandnil(loadFile);

       // check errors in graph
       errGraph:=workGraph.checkGraph;
       if errGraph<>errNone then
       case errGraph of
            errSingle: begin
                       error('At Least one symbol is not connected');
                       ladderSurface.Pages[ladderSurface.PageCount-1].Free;
                       freeandnil(workGraph);
                       graphError:=true;
                       exit;
                       end;
            errNoVar:  begin
                       error('variable '+workGraph.SymbolError+' in graph '+projectCurrent.fBlocList[nbGraph]+' is not defined');
                       ladderSurface.Pages[ladderSurface.PageCount-1].Free;
                       freeandnil(workGraph);
                       graphError:=true;
                       exit;
                       end;

            end;

       // create a graph to define logic
       copieGraphe:=TLadderGraph.create(form1,laddersurface,projectCurrent.fBlocList[nbGraph]+'2',false);
       // create and call lad2pas object
       if ladToPass<>nil then FreeAndNil(ladToPass);
       ladToPass:=TladToPas.create(workGraph,copieGraphe);
       ladToPass.startConvert(projectCurrent.fBlocList[nbGraph]);

       // destroy tab and graphes
       i:=0;
       while i<ladderSurface.PageCount do
       begin
       if (ladderSurface.Pages[i].Caption=
                projectCurrent.fBlocList[nbGraph]+'1') then
                  begin
                  ladderSurface.Pages[i].Free;
                  freeandnil(workGraph);
                  end;
       if (ladderSurface.Pages[i].Caption=
                projectCurrent.fBlocList[nbGraph]+'2') then
                  begin
                  ladderSurface.Pages[i].Free;
                  freeandnil(copieGraphe);
                  end;

       i:=i+1;
       end;

      end;
 // build varunit
 projectCurrent.buildVarUnit;
 if simulator=nil then
    projectCurrent.binaryBuildTarget;
 compileIndicator.Brush.Color:=clLime;
end;

{ IO PLC GRID Event }

procedure TForm1.IOplcGridEditingDone(Sender: TObject);
var
  i,j          : integer;
  ARow,ACol    : integer;
  variable     : string;
  character    : char;
  oldNameVar   : string;
  newNameVar   : string;
begin
  ARow:=IOplcGrid.row;
  ACol:=IOplcGrid.col;
  variable:=IOplcGrid.Cells[0,ARow];
  // check variable name
  if length(variable)>0 then
     begin
      character:=IOplcGrid.Cells[0,ARow][1];
      if not( character in ['A'..'Z']) and
         not( character in ['a'..'z']) then
              begin
              error('Variable name must start with a letter');
              if ioPlcList.Count>=Arow-1 then
                 IOplcGrid.Cells[0,ARow]:=ioPlcList[ARow-1].nameVar
                 else
                 IOplcGrid.Cells[0,ARow]:='';
              exit;
              end;
     end;
  // check if name, GPIO and type is defined
  if (IOplcGrid.Cells[0,ARow]<>'') and
     (IOplcGrid.Cells[1,ARow]<>'') and
     (IOplcGrid.Cells[2,ARow]<>'')
     then
     begin

     // check if io name already used
          for i:=0 to ioPlcList.Count-1 do
              if (ioPlcList[i].nameVar=IOplcGrid.Cells[0,Arow]) and
                 (i<>IOplcGrid.row-1) then
                     begin
                     IOplcGrid.Cells[0,ARow]:=ioPlcList[ARow-1].nameVar;
                     error('this IO plc name is already used for '+IOplcGrid.cells[1,i+1]);
                     IOPlcCol:=0;
                     IOPlcRow:=ARow;
                     TimerIOplcGrid.Enabled:=true;
                     exit;
                     end;
          for i:=0 to VARList.Count-1 do
              if (VARList[i].nameVar=IOplcGrid.Cells[0,Arow]) and
                 (i<>VARGrid.row-1) then
                     begin
                     for j:=0 to varList.Count-1 do
                         writeln(varList[j].nameVar);
                     IOplcGrid.Cells[0,ARow]:='';
                     error('this variable name is already used in VAR');
                     VarCol:=0;
                     VarRow:=ARow;
                     TimerVarGrid.Enabled:=true;
                     exit;
                     end;

     // check if GPIO is already affected
         for i:=0 to ioPlcList.Count-1 do
             if (ioPlcList[i].gpio=IOplcGrid.Cells[1,Arow]) and
                (i<>IOplcGrid.row-1) then
                     begin
                     try
                       IOplcGrid.Cells[1,ARow]:=ioPlcList.Items[Arow-1].gpio;
                     except
                       IOplcGrid.Cells[1,Arow]:='';
                     end;
                     error('this GPIO is already affected to '+IOplcGrid.cells[0,i+1]);
                     IOplcGrid.row:=IOplcGrid.RowCount-1;
                     IOplcGrid.col:=0;
                     //IOplcGrid.SetFocus;
                     exit;
                     end;

     // check valid GPIO
     if IOplcGrid.Columns[1].PickList.IndexOf(IOplcGrid.Cells[1,Arow])=-1 then
            begin
            error(IOplcGrid.cells[1,ARow]+' is not a valid GPIO');
            IOplcGrid.Cells[1,ARow]:='';
            exit;
            end;
     // check valid type
     if not(IOplcGrid.Cells[2,Arow]='INPUT') and
              not(IOplcGrid.Cells[2,Arow]='OUTPUT') and
              not(IOplcGrid.Cells[2,Arow]='ANALOG') then
                 begin
                 error(IOplcGrid.Cells[2,Arow]+' is not a valid type');
                 IOplcGrid.Cells[2,ARow]:=IOplcGrid.Columns[ACol].PickList.Strings[0];
                 exit;
                 end;
     end;

    if (IOplcGrid.Cells[0,ARow]<>'') and
       (IOplcGrid.Cells[1,ARow]<>'') and
       (IOplcGrid.Cells[2,ARow]<>'')
       then
          begin
         // New ioPLC
         if ARow>ioPlcList.Count then
           begin
           ioPlcList.Add(TIOPlc.create( IOplcGrid.Cells[0,ARow],
                                        IOplcGrid.Cells[2,ARow],
                                        IOplcGrid.Cells[1,ARow],
                                        IOplcGrid.Cells[3,ARow]));
           IOplcGrid.RowCount:=IOplcGrid.RowCount+1;
           projectCurrent.updateProjectTree;
           IOPlcCol:=0;
           IOPlcRow:=ARow+1;
           TimerIOplcGrid.Enabled:=true;
           end
           else          // existing ioPLC
           begin
           if (ioPlcList[ARow-1].nameVar<>IOplcGrid.Cells[0,ARow]) or
              (ioPlcList[ARow-1].gpio   <>IOplcGrid.Cells[1,ARow]) or
              (ioPlcList[ARow-1].typeVar<>IOplcGrid.Cells[2,ARow]) or
              (ioPlcList[ARow-1].comment<>IOplcGrid.Cells[3,ARow]) then
              begin
               oldNameVar:=ioPlcList[ARow-1].nameVar;
               newNameVar:=IOplcGrid.Cells[0,ARow];
               ioPlcList[ARow-1].nameVar:=IOplcGrid.Cells[0,ARow];
               ioPlcList[ARow-1].gpio   :=IOplcGrid.Cells[1,ARow];
               ioPlcList[ARow-1].typeVar:=IOplcGrid.Cells[2,ARow];
               ioPlcList[ARow-1].comment:=IOplcGrid.Cells[3,ARow];
               IOPlcCol:=0;
               IOPlcRow:=ARow;
               TimerIOplcGrid.Enabled:=true;
              end;
           projectCurrent.updateProjectTree;
           projectCurrent.RenameVar(oldNameVar,newNameVar);
           end;
          end;

end;

procedure TForm1.IOplcGridHeaderClick(Sender: TObject; IsColumn: Boolean;
  Index: Integer);
var
  i : integer;
begin
 if IOplcGrid.SortOrder=soDescending then
    IOplcGrid.SortOrder:=soAscending else
    IOplcGrid.SortOrder:=soDescending;
 IOplcGrid.SortColRow(IsColumn,index,1,IOplcGrid.RowCount-2);
 ioPlcList.clear;
 for i:=0 to IOplcGrid.RowCount-3 do
     begin
     ioPlcList.add(TIOPlc.create( IOplcGrid.Cells[0,i+1],
                                  IOplcGrid.Cells[2,i+1],
                                  IOplcGrid.Cells[1,i+1],
                                  IOplcGrid.Cells[3,i+1]));
     end;
end;

procedure TForm1.TimerIOplcGridTimer(Sender: TObject);
begin
 begin
   IOplcGrid.Row:=IOPlcRow;
   IOplcGrid.Col:=IOPlcCol;
   IOplcGrid.EditorMode:=true;
   TimerIOplcGrid.Enabled:=false;
 end;
end;



procedure TForm1.IOplcGridDblClick(Sender: TObject);
begin
  IOplcGrid.EditorMode:=true;
end;

procedure TForm1.IOplcGridContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
   currentIOPlcCol : integer;
   currentIOPlcRow : integer;
begin
  if projectCurrent<>nil then
     begin
     IOplcGrid.MouseToCell(MousePos.X,MousePos.y,currentIOPlcCol,currentIOPlcRow);
     if (currentIOPlcCol=0) and
        (IOPlcGrid.IsCellSelected[currentIOPlcCol,currentIOPlcRow]) and
        (IOplcGrid.Cells[currentIOPlcCol,currentIOPlcRow]<>'') then
            begin
             MenuItemAddToDataWatch.visible:=true;
             IOplcGrid.PopupMenu:=PopupMenuCrossRef;
             MenuItemRemoveVar.Visible:=true;
             VarCol:=currentIOPlcCol;
             VarRow:=currentIOPlcRow;
            end
            else
            Handled:=true;
     end;
end;

{ VAR GRID Event }

procedure TForm1.VARGridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  rect : TRect;
begin
  with Sender as TSTringGrid do
   begin
   if (IsCellSelected[aCol,aRow]) and
      (Cells[aCol,aRow]<>'') then
     begin
     canvas.Brush.Color:=RGBToColor($4A,$90,$D9);
     rect:=CellRect(aCol,aRow);
     Canvas.FillRect(rect);
     Canvas.Font.Color:=clWhite;
     Canvas.TextOut(rect.Left+2,rect.Top+2,cells[acol,arow]);
     end;

     if col=1 then
        if editor.visible and (editor.Caption='') then
           editor.caption:=columnVar.PickList[0];

   end;
end;

procedure TForm1.VARGridEditingDone(Sender: TObject);
var
  i            : integer;
  ARow,ACol    : integer;
  character    : char;
  variable     : string;
  oldNameVar   : string;
  newNameVar   : string;
begin
  ARow:=VARGrid.row;
  ACol:=VARGrid.col;
  variable:=VARGrid.Cells[0,ARow];
  // check variable name
  if length(variable)>0 then
     begin
      character:=variable[1];
      if not( character in ['A'..'Z']) and
         not( character in ['a'..'z']) then
              begin
              error('Variable name must start with a letter');
              if varList.Count>=Arow-1 then
                 VARGrid.Cells[0,ARow]:=varList[ARow-1].nameVar
                 else
                 VARGrid.Cells[0,ARow]:='';
              exit;
              end;
      if pos(variable,' ')<>0 then
         begin
         error('Variable name can not contain space(s)');
          if varList.Count>=Arow-1 then
             VARGrid.Cells[0,ARow]:=varList[ARow-1].nameVar
             else
             VARGrid.Cells[0,ARow]:='';
          exit;
         end;
     end;
  // check if name and type is defined
  if (VARGrid.Cells[0,ARow]<>'') and
     (VARGrid.Cells[1,ARow]<>'')
     then
     begin

     // check if var name already defined
          for i:=0 to VARList.Count-1 do
              if (VARList[i].nameVar=VARGrid.Cells[0,Arow]) and
                 (i<>VARGrid.row-1) then
                     begin
                     VARGrid.Cells[0,ARow]:='';
                     error('this variable name is already used in VAR');
                     VarCol:=0;
                     VarRow:=ARow;
                     TimerVarGrid.Enabled:=true;
                     exit;
                     end;
          for i:=0 to ioPlcList.Count-1 do
              if (ioPlcList[i].nameVar=VARGrid.Cells[0,Arow]) and
                 (i<>VARGrid.row-1) then
                     begin
                     VARGrid.Cells[0,ARow]:='';
                     error('this variable name is already used for '+IOplcGrid.cells[1,i+1]);
                     VarCol:=0;
                     VarRow:=ARow;
                     TimerVarGrid.Enabled:=true;
                     exit;
                     end;
     // check valid type
     if VARGrid.Columns[1].PickList.IndexOf(VARGrid.Cells[1,ARow])=-1 then
                 begin
                 error(VARGrid.Cells[1,Arow]+' is not a valid type');
                 VARGrid.Cells[1,ARow]:=VARGrid.Columns[ACol].PickList.Strings[0];
                 VarCol:=0;
                 VarRow:=ARow;
                 TimerVarGrid.Enabled:=true;
                 exit;
                 end;
     end;
  if (VARGrid.Cells[0,ARow]<>'') and
       (VARGrid.Cells[1,ARow]<>'')
       then
       begin
       // New VAR
       if ARow>varList.Count then
         begin
         varList.Add(TVariable.create( VARGrid.Cells[0,ARow],
                                       VARGrid.Cells[1,ARow],
                                       VARGrid.Cells[2,ARow]));
         VARGrid.RowCount:=VARGrid.RowCount+1;
         VARGrid.Cells[1,VARGrid.RowCount-1]:=VARGrid.Columns[1].PickList.Strings[0];
         projectCurrent.updateProjectTree;
         VarRow:=VARGrid.RowCount-1;
         VarCol:=0;
         TimerVarGrid.enabled:=true;
         end
         else          // existing VAR
         begin
         if (varList[ARow-1].nameVar<>VarGrid.Cells[0,ARow]) or
            (varList[ARow-1].typeVar<>VarGrid.Cells[1,ARow]) or
            (varList[ARow-1].comment<>VarGrid.Cells[2,ARow]) then
            begin

            oldNameVar:=varList[ARow-1].nameVar;
            newNameVar:=VARGrid.Cells[0,ARow];
             varList[ARow-1].nameVar:=VarGrid.Cells[0,ARow];

             varList[ARow-1].typeVar:=VarGrid.Cells[1,ARow];
             varList[ARow-1].comment:=VarGrid.Cells[2,ARow];
             VarRow:=VARGrid.RowCount-1;
             VarCol:=0;
             TimerVarGrid.enabled:=true;
            end;
         //if grapheCurrent<>nil then grapheCurrent.SetFocus;
         projectCurrent.updateProjectTree;
         projectCurrent.RenameVar(oldNameVar,newNameVar);
         end;
       end;
end;

procedure TForm1.VARGridHeaderClick(Sender: TObject; IsColumn: Boolean;
  Index: Integer);
var
  i : integer;
begin
 if VARGrid.SortOrder=soDescending then
    VARGrid.SortOrder:=soAscending else
    VARGrid.SortOrder:=soDescending;
 VARGrid.SortColRow(IsColumn,index,1,VARGrid.RowCount-2);
 varList.clear;
 for i:=0 to VARGrid.RowCount-3 do
     begin
     varList.add(TVariable.create( VARGrid.Cells[0,i+1],
                                   VARGrid.Cells[1,i+1],
                                   VARGrid.Cells[2,i+1]));
     end;

end;

procedure TForm1.VariablesPageControlChange(Sender: TObject);
begin
  if VariablesPageControl.PageIndex<>VariablesPageControl.Tag then
     begin
     if expandVarButton.tag=1 then
        reDimVarTabSheetLarge;
     if retractVarButton.Tag=1 then
        reDimVarTabSheetSmall;
     VariablesPageControl.Tag:=VariablesPageControl.PageIndex;
     end;
end;

procedure TForm1.TimerVarGridTimer(Sender: TObject);
begin
  VARGrid.Row:=VarRow;
  VARGrid.Col:=VarCol;
  VARGrid.EditorMode:=true;
  TimerVarGrid.Enabled:=false;
end;

procedure TForm1.VARGridDblClick(Sender: TObject);
begin
  VARGrid.EditorMode:=true;
end;

procedure TForm1.VARGridContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
   currentIOPlcCol : integer;
   currentIOPlcRow : integer;
begin
  if projectCurrent<>nil then
     begin
     VarGrid.MouseToCell(MousePos.X,MousePos.y,currentIOPlcCol,currentIOPlcRow);
     if (currentIOPlcCol=0) and
        (VarGrid.IsCellSelected[currentIOPlcCol,currentIOPlcRow]) and
        (VarGrid.Cells[currentIOPlcCol,currentIOPlcRow]<>'') then
            begin
             MenuItemAddToDataWatch.visible:=true;
             VarGrid.PopupMenu:=PopupMenuCrossRef;
             MenuItemRemoveVar.Visible:=true;
             VarCol:=currentIOPlcCol;
             VarRow:=currentIOPlcRow;
            end
            else
            Handled:=true;
     end;
end;

{ System GRID Event }

procedure TForm1.SystemGridHeaderClick(Sender: TObject; IsColumn: Boolean;
  Index: Integer);
begin
 if SystemGrid.SortOrder=soDescending then
    SystemGrid.SortOrder:=soAscending else
    SystemGrid.SortOrder:=soDescending;
 SystemGrid.SortColRow(IsColumn,index,1,SystemGrid.RowCount-1);
end;


procedure TForm1.SystemGridContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
   currentIOPlcCol : integer;
   currentIOPlcRow : integer;
begin
  if projectCurrent<>nil then
     begin
     SystemGrid.MouseToCell(MousePos.X,MousePos.y,currentIOPlcCol,currentIOPlcRow);
     if (currentIOPlcCol=0) and
        (SystemGrid.IsCellSelected[currentIOPlcCol,currentIOPlcRow]) and
        (SystemGrid.Cells[currentIOPlcCol,currentIOPlcRow]<>'') then
            begin
             MenuItemAddToDataWatch.visible:=true;
             SystemGrid.PopupMenu:=PopupMenuCrossRef;
             MenuItemRemoveVar.Visible:=false;
             VarCol:=currentIOPlcCol;
             VarRow:=currentIOPlcRow;
            end
            else
            Handled:=true;
     end;
end;

procedure TForm1.SystemGridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  rect : TRect;
begin
  with Sender as TSTringGrid do
   begin
   if (IsCellSelected[aCol,aRow]) and
      (Cells[aCol,aRow]<>'') then
     begin
     canvas.Brush.Color:=RGBToColor($4A,$90,$D9);
     rect:=CellRect(aCol,aRow);
     Canvas.FillRect(rect);
     Canvas.Font.Color:=clWhite;
     Canvas.TextOut(rect.Left+2,rect.Top+2,cells[acol,arow]);
     end;
   end;
end;

{ CROSS REFERENCES }

procedure TForm1.itemFindRefClick(Sender: TObject);
var
  i             : integer;
  nbgraph       : integer;
  nbCrossRef    : integer;
  varName       : string;
  graphPathName : string;
  saveFile      : TXmlObject;
  loadFile      : TXmlObject;
  workGraph     : TLadderGraph;
begin
  FreeAndNil(crossRefList);
  crossRefList:=TSymbolList.Create(false);
  blocCrossRefList.clear;
  classCrossRefList.clear;
  if VariablesPageControl.ActivePage.Caption='IO PLC' then
     varName:=IOplcGrid.Cells[VarCol,VarRow];
  if VariablesPageControl.ActivePage.Caption='Variable' then
     varName:=VARGrid.Cells[VarCol,VarRow];
  if VariablesPageControl.ActivePage.Caption='System' then
     varName:=SystemGrid.Cells[VarCol,VarRow];

  // save all opened graph
   for i:=0 to ladderGraphList.count-1 do
       begin
       saveFile:=TXmlObject.create;
       saveFile.saveBlockXML(ladderGraphList[i].name,ladderGraphList[i]);
       ladderGraphList[i].graphChanged:=false;
       FreeandNil(saveFile);
       end;

   // find crossref in all graph
    for nbGraph:=0 to projectCurrent.fBlocList.Count-1 do
        begin
         // create a copy of graph
          workGraph:=TLadderGraph.create(form1,laddersurface,projectCurrent.fBlocList[nbGraph]+'1',false);
          loadFile:=TXmlObject.create;
          graphPathName:=projectCurrent.fpath+projectCurrent.fname+'-data/'+projectCurrent.fBlocList[nbGraph]+'.xml';
          loadFile.loadBlocXML(workGraph,graphPathName);
          freeandnil(loadFile);

         // check references in graph
          nbCrossRef:=crossRefList.count;
          workGraph.findInGraph(varName);
          nbCrossRef:=crossRefList.count-nbCrossRef;
          for i:=0 to nbCrossRef-1 do
              begin
              blocCrossRefList.add(projectCurrent.fBlocList[nbGraph]);
              end;

         // destroy tab and graphes
         i:=0;
         while i<ladderSurface.PageCount do
         begin
         if (ladderSurface.Pages[i].Caption=
                  projectCurrent.fBlocList[nbGraph]+'1') then
                    begin
                    ladderSurface.Pages[i].Free;
                    freeandnil(workGraph);
                    end;
          i:=i+1;
          end;
        end;
    // update crossref grid
    crossRefGrid.Clear;
    crossRefGrid.RowCount:=2;
    for i:=0 to crossRefList.count-1 do
        begin
        crossRefGrid.Cells[0,i+1]:=varName;
        crossRefGrid.Cells[1,i+1]:=copy(classCrossRefList[i],2,length(classCrossRefList[i]));
        crossRefGrid.Cells[2,i+1]:=blocCrossRefList[i];
        crossRefGrid.RowCount:=crossRefGrid.RowCount+1;
        end;
    FreeAndNil(workGraph);
    VariablesPageControl.ActivePage:=VariablesPageControl.Pages[4];
end;

procedure TForm1.crossRefGridDblClick(Sender: TObject);
var
  Arow         : integer;
  i,j          : integer;
  variable     : string;
  grapheName   : string;
  found        : boolean;
begin
 if grapheCurrent<>nil then
    begin
     // remove highlighted color
     grapheCurrent.unHighLightGraph;

     Arow:=crossRefGrid.Row;
     variable:=crossRefGrid.Cells[0,Arow];
     if variable<>'' then
        begin
         grapheName:=crossRefGrid.Cells[2,Arow];
         // check if selected var is in an opened graph
         found:=false;
         for i:=0 to ladderGraphList.Count-1 do
             if ladderGraphList[i].name=grapheName then
                for j:=0 to ladderSurface.PageCount-1 do
                    if ladderSurface.Pages[j].Caption=grapheName then
                       begin
                       ladderSurface.ActivePage:=ladderSurface.Pages[j];
                       grapheCurrent:=ladderGraphList[j];
                       found:=true;
                       end;
         // else open the graph
         if not found then
                begin
                openBlock(grapheName);
                ladderSurface.ActivePage:=ladderSurface.Pages[ladderGraphList.Count-1];
                grapheCurrent:=ladderGraphList[ladderGraphList.count-1];
                end;
         for i:=0 to grapheCurrent.ObjectsCount-1 do
             if (grapheCurrent.Objects[i] is TSymbol) and
             not(grapheCurrent.Objects[i] is TPowerRail) then
             begin
              if (TSymbol(grapheCurrent.Objects[i]).getVarList.IndexOf(variable)<>-1)
              then
              TSymbol(grapheCurrent.Objects[i]).highLightblue;
             end;
        end;
    end;
end;

{ DATA WATCH }

var
  currentDataWatchCol,
  currentDataWatchRow    : integer;

procedure TForm1.dataWatchGridContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  i : integer;
  col,row : integer;
  bitType : boolean=false;
  intType : boolean=false;
begin
dataWatchGrid.MouseToCell(MousePos.X,MousePos.y,col,row);
currentDataWatchCol:=col;
currentDataWatchRow:=row;
dataWatchVarSelected:=dataWatchGrid.Cells[0,row];
if dataWatchGrid.Row=currentDataWatchRow then
  begin
  if dataWatchVarSelected<>'' then

        if TimerSimulator.Enabled then
        begin
        if (IOplcGrid.Cols[0].IndexOf(dataWatchVarSelected)<>-1) then
           if (IOplcGrid.Cells[2,IOplcGrid.Cols[0].IndexOf(dataWatchVarSelected)]='INPUT') or
              (IOplcGrid.Cells[2,IOplcGrid.Cols[0].IndexOf(dataWatchVarSelected)]='OUTPUT')
              then
              bitType:=true;
        if (VARGrid.Cols[0].IndexOf(dataWatchVarSelected)<>-1) then
           if (VARGrid.Cells[1,VARGrid.Cols[0].IndexOf(dataWatchVarSelected)]='BIT') then
              bitType:=true;
        if bitType then
           begin
           MenuItemSetOn.enabled:=true;
           MenuItemSetOff.enabled:=true;
           MenuItemPulseOn.enabled:=true;
           MenuItemPulseOff.enabled:=true;
           MenuItemSetValue.enabled:=false;
           dataWatchGrid.PopupMenu:=PopupMenuDataWatchBit;
           handled:=false;
           exit;
           end
           else
           begin
           MenuItemSetOn.enabled:=false;
           MenuItemSetOff.enabled:=false;
           MenuItemPulseOn.enabled:=false;
           MenuItemPulseOff.enabled:=false;
           MenuItemSetValue.enabled:=true;
           dataWatchGrid.PopupMenu:=PopupMenuDataWatchBit;
           handled:=false;
           exit;
           end;
        end
        else
        begin
        MenuItemSetOn.enabled:=false;
        MenuItemSetOff.enabled:=false;
        MenuItemPulseOn.enabled:=false;
        MenuItemPulseOff.enabled:=false;
        MenuItemSetValue.enabled:=false;
        dataWatchGrid.PopupMenu:=PopupMenuDataWatchBit;
        handled:=false;
        exit;
        end;
  end
  else handled:=true; // remove pop up menu
end;

procedure TForm1.dataWatchGridPrepareCanvas(Sender: TObject; aCol,
  aRow: Integer; aState: TGridDrawState);
var
  currentcol,currentrow : integer;
begin
   if not(sender is TStringGrid) then exit;
   dataWatchGrid.MouseToCell(Mouse.CursorPos.x,Mouse.CursorPos.y,currentcol,currentrow);
   if (currentrow=arow) then
         dataWatchGrid.Brush.Color:=clLtGray
   else  dataWatchGrid.Brush.Color:=clWhite;
   if dataWatchGrid.Cells[acol,arow]='On' then
       (sender as TStringGrid).Font.Color:=clRed
  else (sender as TStringGrid).Font.Color:=clBlack;
end;

procedure TForm1.MenuItemSetOnClick(Sender: TObject);
begin
 if simulator<>nil then
    begin
    dataWatchInstruction:=dataWatchVarSelected+'=true';
    simulator.sendSetRequest;
    end;
end;

procedure TForm1.MenuItemSetValueClick(Sender: TObject);
var
  value : string;
begin
  value:=InputBox( 'Set '+
                   dataWatchGrid.Cells[dataWatchGrid.Col,dataWatchGrid.Row]+
                   ' Value','new value','');
  if isnumber(UTF8ToUnicodeString(value),1) then
     begin
     if simulator<>nil then
         begin
         dataWatchInstruction:= '@'+
                                dataWatchGrid.Cells[dataWatchGrid.Col,dataWatchGrid.Row]+
                                '='+value;
         simulator.sendSetRequest;
         end;
     end;
end;

procedure TForm1.MenuItemStartSimClick(Sender: TObject);
begin
  MenuItemStartClick(Sender);
end;

procedure TForm1.MenuItemStopSimClick(Sender: TObject);
begin
  MenuItemStopClick(Sender);
end;

procedure TForm1.MenuItemSetOffClick(Sender: TObject);
begin
 if simulator<>nil then
    begin
    dataWatchInstruction:=dataWatchVarSelected+'=false';
    simulator.sendSetRequest;
    end;
end;

var
  timerPulseFlag : boolean;

procedure TForm1.MenuItemPulseOnClick(Sender: TObject);
begin
 if simulator<>nil then
    begin
      dataWatchInstruction:=dataWatchVarSelected+'=true';
      simulator.sendSetRequest;
      timerPulseFlag:=false;
      timerPulse.Enabled:=true;
      repeat
      Application.ProcessMessages;
      until timerPulseFlag=true;
      dataWatchInstruction:=dataWatchVarSelected+'=false';
      simulator.sendSetRequest;
    end;
end;

procedure TForm1.MenuItemRemoveClick(Sender: TObject);
begin
  dataWatchGrid.DeleteRow(currentDataWatchRow);
end;

procedure TForm1.MenuItemMoveUpClick(Sender: TObject);
begin
 if dataWatchGrid.RowCount>=2 then
    if  (currentDataWatchRow>1)
    and (dataWatchGrid.Cells[currentDataWatchCol,currentDataWatchRow]<>'') then
      begin
      dataWatchGrid.InsertColRow(false,currentDataWatchRow-1);
      dataWatchGrid.Rows[currentDataWatchRow-1]:=dataWatchGrid.Rows[currentDataWatchRow+1];
      dataWatchGrid.DeleteRow(currentDataWatchRow+1);
      dataWatchGrid.row:=currentDataWatchRow-1;
      end;
end;

procedure TForm1.MenuItemMoveDownClick(Sender: TObject);
var
  i : integer;
begin
 if dataWatchGrid.RowCount>=2 then
    if currentDataWatchRow<dataWatchGrid.RowCount-2 then
      begin
      dataWatchGrid.InsertColRow(false,currentDataWatchRow+2);
      dataWatchGrid.Rows[currentDataWatchRow+2]:=
           dataWatchGrid.Rows[currentDataWatchRow];
      dataWatchGrid.DeleteRow(currentDataWatchRow);
      dataWatchGrid.row:=currentDataWatchRow+1;
      end;
end;

procedure TForm1.aboutItemClick(Sender: TObject);
begin
  aboutForm.show;
end;

procedure TForm1.TimerPulseTimer(Sender: TObject);
begin
  timerPulseFlag:=true;
  TTimer(Sender).Enabled:=false;
end;

procedure TForm1.IOplcGridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  rect : TRect;
begin
 with Sender as TSTringGrid do
   if (IsCellSelected[aCol,aRow]) and
      (Cells[aCol,aRow]<>'') then
     begin
     canvas.Brush.Color:=RGBToColor($4A,$90,$D9);
     rect:=CellRect(aCol,aRow);
     Canvas.FillRect(rect);
     Canvas.Font.Color:=clWhite;
     Canvas.TextOut(rect.Left+2,rect.Top+2,cells[acol,arow]);
     end;
end;



{ /DATA WATCH }

{ UTILITY }

procedure TForm1.lockMenu;
var
  i,j : integer;
begin
  for i:=0 to MainMenu.Items.Count-1 do
          if (MainMenu.Items[i].Caption<>'Simulate') then
          begin
               MainMenu.Items[i].Enabled:=false;
          end
          else
          begin
          for j:=0 to MainMenu.Items[i].Count-1 do
              begin
              if MainMenu.Items[i].Items[j].caption<>'Stop' then
                 MainMenu.Items[i].Items[j].Enabled:=false;
              if MainMenu.Items[i].Items[j].caption<>'Start' then
                 MainMenu.Items[i].Items[j].Enabled:=true;
              end;
          end;
  contactTools.Enabled:=false;
  projectTree.Enabled:=false;
end;

procedure TForm1.unLockMenu;
var
  i,j : integer;
begin
  for i:=0 to MainMenu.Items.Count-1 do
      if (MainMenu.Items[i].Caption='Simulate') then
      begin
      for j:=0 to MainMenu.Items[i].Count-1 do
           begin
               if MainMenu.Items[i].Items[j].caption='Stop' then
                  MainMenu.Items[i].Items[j].Enabled:=false;
               if MainMenu.Items[i].Items[j].caption='Start' then
                  MainMenu.Items[i].Items[j].Enabled:=true;
           end;
      end
      else MainMenu.Items[i].Enabled:=true;
  contactTools.Enabled:=true;
  projectTree.enabled:=true;
end;

{ /UTILITY }

end.
