unit doubleclickmath;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  uSimpleGraph;

type

  { TmathForm }

  TmathForm = class(TForm)
    cancelButton: TButton;
    CheckBoxSystemVar: TCheckBox;
    ComboBoxVar1: TComboBox;
    ComboBoxVar2: TComboBox;
    ComboBoxVar3: TComboBox;
    imageOperateur: TImage;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    OKbutton: TButton;
    procedure cancelButtonClick(Sender: TObject);
    procedure CheckBoxSystemVarChange(Sender: TObject);
    procedure OKbuttonClick(Sender: TObject);
  private

  public
    fsymbole : TObject;
  end;

var
  mathForm: TmathForm;

implementation

uses LadderSymbol,main;

{$R *.lfm}

{ TmathForm }

procedure TmathForm.cancelButtonClick(Sender: TObject);
begin
  self.hide;
end;

procedure TmathForm.CheckBoxSystemVarChange(Sender: TObject);
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

procedure TmathForm.OKbuttonClick(Sender: TObject);
var
  var1,var2,var3 : string;
  i              : integer;
begin
   var1:=ComboBoxVar1.Text;
   var2:=ComboBoxVar2.Text;
   var3:=ComboBoxVar3.Text;
   // check VAR1
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
   // check VAR2
   if (form1.VARGrid.Cols[0].IndexOf(var2)=-1) and
      (form1.SystemGrid.Cols[0].IndexOf(var2)=-1) and
      (TryStrToInt(var2,i)) then
            var2:=ComboBoxVar2.Text;
   if (form1.VARGrid.Cols[0].IndexOf(var2)<>-1) or
      (form1.SystemGrid.Cols[0].IndexOf(var2)<>-1) then
            var2:=ComboBoxVar2.Text;
   if (form1.VARGrid.Cols[0].IndexOf(var2)=-1) and
         (form1.SystemGrid.Cols[0].IndexOf(var2)=-1) and
         (not TryStrToInt(var2,i)) then
            begin
            form1.error(ComboBoxVar2.text+' is not a valid value');
            exit;
            end;
   // check VAR3
   if (form1.VARGrid.Cols[0].IndexOf(var3)=-1) then
            begin
            form1.error(ComboBoxVar3.text+' is not a valid value');
            exit;
            end;
  TMath(fsymbole).var1:=var1;
  TMath(fsymbole).var2:=var2;
  TMath(fsymbole).var3:=var3;
  TMath(fsymbole).textAllias.Text:=var3+'='+var1+TMath(fsymbole).getOperateur+var2;
  TMath(fsymbole).equation:='('+var1+TMath(fsymbole).getOperateur+var2+')';
  TSymbol(fsymbole).allias:=TMath(fsymbole).textAllias.text;
  TEvsGraphObject(fsymbole).hint:=TMath(fsymbole).textAllias.text;
  self.Hide;
end;

end.

