unit doubleclickflash;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  VariableUnit;

type

  { TflashForm }

  TflashForm = class(TForm)
    cancelButton: TButton;
    EditPresetValueON: TEdit;
    EditPresetValueOFF: TEdit;
    EditTimerName: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    OKbutton: TButton;
    procedure cancelButtonClick(Sender: TObject);
    procedure EditPresetValueOFFKeyPress(Sender: TObject; var Key: char);
    procedure EditPresetValueONKeyPress(Sender: TObject; var Key: char);
    procedure EditTimerNameKeyPress(Sender: TObject; var Key: char);
    procedure OKbuttonClick(Sender: TObject);
  private

  public
    fsymbole : TObject;

  end;

var
  flashForm: TflashForm;

implementation

{$R *.lfm}

uses LadderSymbol,main;

{ TflashForm }

procedure TflashForm.cancelButtonClick(Sender: TObject);
begin
  hide;
end;

procedure TflashForm.EditPresetValueOFFKeyPress(Sender: TObject; var Key: char);
begin
  if ord(key)=13 then OKbuttonClick(self);
end;

procedure TflashForm.EditPresetValueONKeyPress(Sender: TObject; var Key: char);
begin
  if ord(key)=13 then OKbuttonClick(self);
end;

procedure TflashForm.EditTimerNameKeyPress(Sender: TObject; var Key: char);
begin
  if ord(key)=13 then OKbuttonClick(self);
end;

procedure TflashForm.OKbuttonClick(Sender: TObject);
var
  timerName,presetValueON : string;
  presetValueOff          : string;
  i                       : integer;
  begin
  timerName   := EditTimerName.Text;
  presetValueON := EditPresetValueON.Text;
  presetValueOFF := EditPresetValueOFF.Text;
  // check timerName
  if (form1.VARGrid.Cols[0].IndexOf(timerName)=-1) and
     (form1.SystemGrid.Cols[0].IndexOf(timerName)=-1) and
     (form1.IOplcGrid.Cols[0].IndexOf(timerName)=-1) and
     (form1.TimerGrid.Cols[0].IndexOf(timerName)=-1)
     then begin
          end
     else begin
          ShowMessage('The name '+EditTimerName.text+' is already used');
          exit;
          end;
  // check preset value
  if (TryStrToInt(presetValueON,i)) and
     (TryStrToInt(presetValueOFF,i)) then
     begin
      TFlash(fsymbole).presetON:=StrToInt(presetValueON);
      TFlash(fsymbole).presetOFF:=StrToInt(presetValueOFF);
      TFLASH(fsymbole).textAllias.text:=timerName;
      TSymbol(fsymbole).hint:= TTon(fsymbole).textAllias.text+' '+
                               'ON='+presetValueON+' OFF='+presetValueOFF;
      TSymbol(fsymbole).allias:=timerName;
      timerList.Add(TTimerVar.create(timerName,presetValueON,presetValueON,presetValueOff,'TFlash'));
      with form1 do
            begin
            TimerGrid.RowCount:=TimerGrid.RowCount+1;
            TimerGrid.Cells[0,TimerGrid.RowCount-2]:=EditTimerName.Text;
            TimerGrid.Cells[1,TimerGrid.RowCount-2]:='blink';
            end;
     end
     else
     begin
     ShowMessage(presetValueON+' or '+presetValueOFF+' are not valid value');
     exit;
     end;
  hide;
end;

end.

