unit doubleclickstore;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  uSimpleGraph;

type

  { TstoreForm }

  TstoreForm = class(TForm)
    cancelButton: TButton;
    CheckBoxSystemVar: TCheckBox;
    ComboBoxVar1: TComboBox;
    ComboBoxVar2: TComboBox;
    Label1: TLabel;
    Label3: TLabel;
    OKbutton: TButton;
    Shape1: TShape;
    Shape2: TShape;
    procedure cancelButtonClick(Sender: TObject);
    procedure CheckBoxSystemVarChange(Sender: TObject);
    procedure OKbuttonClick(Sender: TObject);
  private

  public
    fsymbole : TObject;
  end;

var
  storeForm: TstoreForm;

implementation

{$R *.lfm}

uses LadderSymbol,main;

{ TstoreForm }

procedure TstoreForm.OKbuttonClick(Sender: TObject);
var
  var1,var2 : string;
  i         : integer;
begin
   var1:=ComboBoxVar1.Text;
   if (form1.VARGrid.Cols[0].IndexOf(var1)=-1) and
      (form1.SystemGrid.Cols[0].IndexOf(var1)=-1) and
      (TryStrToInt(var1,i)) then
            var1:=ComboBoxVar1.Text;
   if (form1.VARGrid.Cols[0].IndexOf(var1)<>-1) or
      (form1.SystemGrid.Cols[0].IndexOf(var1)<>-1) then
            var1:=ComboBoxVar1.Text;
   if (form1.VARGrid.Cols[0].IndexOf(var1)=-1) and
         (form1.SystemGrid.Cols[0].IndexOf(var1)=-1) and
         (not TryStrToInt(var1,i)) then
            begin
            form1.error(ComboBoxVar1.text+' is not a valid value');
            exit;
            end;
  var2:=ComboBoxVar2.Items[ComboBoxVar2.ItemIndex];
  TStore(fsymbole).var1:=var1;
  TStore(fsymbole).var2:=var2;
  TStore(fsymbole).textAllias.Text:=var2+'='+var1;
  TSymbol(fsymbole).equation:=var2+':='+var1;
  TSymbol(fsymbole).allias:=TStore(fsymbole).textAllias.text;
  TEvsGraphObject(fsymbole).hint:=TStore(fsymbole).textAllias.text;
  self.Hide;
end;

procedure TstoreForm.cancelButtonClick(Sender: TObject);
begin
  self.Hide;
end;

procedure TstoreForm.CheckBoxSystemVarChange(Sender: TObject);
var
  i           : integer;
  selectedVar : integer;
begin
   ComboBoxVar1.Clear;
   ComboBoxVar2.Clear;
   for i:=0 to varList.Count-1 do
     if varList.Items[i].typeVar<>'BIT' then
        begin
        ComboBoxVar1.Items.Add(varList.Items[i].nameVar);
        ComboBoxVar2.Items.Add(varList.Items[i].nameVar);
        end;
   if CheckBoxSystemVar.checked then
      begin
      for i:=1 to form1.SystemGrid.RowCount-1 do
        if (form1.SystemGrid.Cells[1,i]<>'BIT') and
           (form1.SystemGrid.Cells[0,i]<>'') then
           begin
           ComboBoxVar1.Items.Add(form1.SystemGrid.Cells[0,i]);
           ComboBoxVar2.Items.Add(form1.SystemGrid.Cells[0,i]);
           end;
      end;
   ComboBoxVar1.Sorted:=true;
   ComboBoxVar2.Sorted:=true;
   // select Var
   selectedVar:=ComboBoxVar1.Items.IndexOf(Tcompare(fsymbole).Var1);
   if selectedVar=-1 then ComboBoxVar1.ItemIndex:=0
   else ComboBoxVar1.ItemIndex:=selectedVar;
   selectedVar:=ComboBoxVar2.Items.IndexOf(Tcompare(fsymbole).Var2);
   if selectedVar=-1 then ComboBoxVar2.ItemIndex:=0
   else ComboBoxVar2.ItemIndex:=selectedVar;
end;

end.

