unit doubleclicktimer;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,VariableUnit;

type

  { TtimerForm }

  TtimerForm = class(TForm)
    cancelButton: TButton;
    EditPresetValue: TEdit;
    EditTimerName: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    OKbutton: TButton;
    procedure cancelButtonClick(Sender: TObject);
    procedure EditPresetValueKeyPress(Sender: TObject; var Key: char);
    procedure EditTimerNameKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure OKbuttonClick(Sender: TObject);
  private

  public
    fsymbole : TObject;
  end;

var
  timerForm  : TtimerForm;

implementation

{$R *.lfm}

uses LadderSymbol,main;

{ TtimerForm }

procedure TtimerForm.cancelButtonClick(Sender: TObject);
begin
  hide;
end;

procedure TtimerForm.EditPresetValueKeyPress(Sender: TObject; var Key: char);
begin
  if ord(key)=13 then
     if not EditTimerName.enabled then OKbuttonClick(self)
     else EditTimerName.SetFocus;
end;

procedure TtimerForm.EditTimerNameKeyPress(Sender: TObject; var Key: char);
begin
  if ord(key)=13 then OKbuttonClick(self);
end;

procedure TtimerForm.FormShow(Sender: TObject);
begin
  if form1.TimerGrid.Cols[0].IndexOf(EditTimerName.text)<>-1 then
     EditTimerName.Enabled:=false
  else EditTimerName.Enabled:=true;
  if EditTimerName.Enabled then EditTimerName.SetFocus
                           else EditPresetValue.SetFocus;
end;

procedure TtimerForm.OKbuttonClick(Sender: TObject);
var
  timerName,presetValue : string;
  i                     : integer;
  begin
  timerName   := EditTimerName.Text;
  presetValue := EditPresetValue.Text;
  if EditTimerName.enabled then
     begin
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
     end;
  // check preset value
  if TryStrToInt(presetValue,i) then
     begin
     if (Caption='Timer ON') and (EditTimerName.enabled)  then begin
                            TTon(fsymbole).preset:=StrToInt(presetValue);
                            TTon(fsymbole).textAllias.text:=timerName;
                            TSymbol(fsymbole).hint:= TTon(fsymbole).textAllias.text+' '+
                                                     'Preset='+presetValue;
                            TSymbol(fsymbole).allias:=timerName;
                            timerList.Add(TTimerVar.create(timerName,presetValue,presetValue,'0','Ton'));
                            end;
     if (Caption='Timer OFF') and (EditTimerName.Enabled) then begin
                            TToff(fsymbole).preset:=StrToInt(presetValue);
                            TToff(fsymbole).textAllias.text:=timerName;
                            TSymbol(fsymbole).hint:= TToff(fsymbole).textAllias.text+' '+
                                                     'Preset='+presetValue;
                            TSymbol(fsymbole).allias:=timerName;
                            timerList.Add(TTimerVar.create(timerName,presetValue,presetValue,'0','Toff'));
                            end;
     with form1 do
             begin
             // put the timer in the grid
             if TimerGrid.Cols[0].IndexOf(timerName)=-1 then
                begin
                TimerGrid.RowCount:=TimerGrid.RowCount+1;
                TimerGrid.Cells[0,TimerGrid.RowCount-2]:=timerName;
                end;
          if not EditTimerName.enabled then
             for i:=0 to timerList.count-1 do
                 if timerList[i].nameVar=timerName then
                    begin
                    timerList[i].presetON:=presetValue;
                    timerList[i].presetOFF:=presetValue;
                    timerList[i].preset:=presetValue;
                    end;
             end;
     TTimerObject(fsymbole).preset:=strtoint(presetValue);
     TTimerObject(fsymbole).Hint:=timerName+' PRESET='+presetValue;
     if caption='Ton' then TTon(fsymbole).preset:=strtoint(presetValue);
     if caption='Toff' then TToff(fsymbole).preset:=strtoint(presetValue);
     end
     else
     begin
     ShowMessage(presetValue+' is not a valid value');
     exit;
     end;
  hide;
 end;

end.

