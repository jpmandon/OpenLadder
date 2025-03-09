unit doubleClickBit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  mouse,uSimpleGraph;

type

  { TbitForm }

  TbitForm = class(TForm)
    CheckBoxSystemBit: TCheckBox;
    OKbutton: TButton;
    cancelButton: TButton;
    Label2: TLabel;
    contactListBox: TListBox;
    nameField: TEdit;
    Label1: TLabel;
    procedure cancelButtonClick(Sender: TObject);
    procedure CheckBoxSystemBitChange(Sender: TObject);
    procedure contactListBoxClick(Sender: TObject);
    procedure contactListBoxDblClick(Sender: TObject);
    procedure contactListBoxKeyPress(Sender: TObject; var Key: char);
    procedure FormActivate(Sender: TObject);
    procedure nameFieldKeyPress(Sender: TObject; var Key: char);
    procedure OKbuttonClick();
    procedure updateSymbolName;
  protected
    fsymbole : TObject;
  public
    property symbole : TObject write fsymbole;
  end;

var
  bitForm     : TbitForm;

implementation

uses LadderSymbol,main;

{$R *.lfm}

{ TbitForm }

procedure TbitForm.cancelButtonClick(Sender: TObject);
begin
  self.Close;
end;

procedure TbitForm.CheckBoxSystemBitChange(Sender: TObject);
var
  i : integer;
begin
   contactListBox.Clear;
   for i:=0 to ioPlcList.Count-1 do
      if (ioPlcList.Items[i].typeVar='INPUT') or
         (ioPlcList.Items[i].typeVar='OUTPUT') then
         contactListBox.items.Add(ioPlcList.Items[i].nameVar);
   for i:=0 to varList.Count-1 do
     if varList.Items[i].typeVar='BIT' then
        begin
        contactListBox.Items.Add(varList.Items[i].nameVar);
        end;
   for i:=0 to timerList.Count-1 do
       contactListBox.Items.Add(timerList[i].nameVar);
   if CheckBoxSystemBit.checked then
      for i:=1 to Form1.SystemGrid.RowCount-1 do
        if form1.SystemGrid.Cells[0,i]<>'' then
        begin
          if form1.SystemGrid.Cells[1,i]='BIT' then
             begin
             contactListBox.Items.Add(form1.SystemGrid.Cells[0,i]);
             end;
        end;
   contactListBox.Sorted:=true;
end;

procedure TbitForm.contactListBoxClick(Sender: TObject);
begin
  nameField.text:=contactListBox.Items[contactListBox.ItemIndex];
end;

procedure TbitForm.contactListBoxDblClick(Sender: TObject);
begin
  nameField.text:=contactListBox.Items[contactListBox.ItemIndex];
  updateSymbolName;
  close;
end;

procedure TbitForm.contactListBoxKeyPress(Sender: TObject; var Key: char);
begin
  if ord(key)=13 then
     begin
     nameField.Text:=contactListBox.Items[contactListBox.ItemIndex];
     OKbuttonClick();
     end;
end;

procedure TbitForm.FormActivate(Sender: TObject);
begin
  if contactListBox.Count>0 then contactListBox.Selected[0]:=true;
  ActiveControl:=nameField;
end;

procedure TbitForm.nameFieldKeyPress(Sender: TObject; var Key: char);
begin
  if ActiveControl=nameField then
     if key=chr(13) then
        begin
        ActiveControl:=OKbutton;
        updateSymbolName;
        self.close();
        end;
end;

procedure TbitForm.OKbuttonClick();
begin
  updateSymbolName;
  self.close();
end;

procedure TbitForm.updateSymbolName;
begin
  if length(namefield.text)<>0 then
     begin
     if fsymbole.ClassName='TBit' then
        begin
        TBit(fsymbole).allias:=nameField.Text;
        TBit(fsymbole).Text:=nameField.Text;
        TSymbol(fsymbole).textAllias.Text:=nameField.text;
        TEvsGraphObject(fsymbole).hint:=nameField.Text;
        end
        else
        begin
        TCoil(fsymbole).allias:=nameField.Text;
        TCoil(fsymbole).Text:=nameField.Text;
        TSymbol(fsymbole).textAllias.text:=nameField.text;
        TEvsGraphObject(fsymbole).hint:=nameField.Text;
        end;
     end
  else
     MessageDlgPos('Le nom du symbole doit être défini !!',mtWarning,[mbOK],0,self.Left+(self.width div 2),self.Top+(self.height div 2))
end;

{ TbitForm }



end.

