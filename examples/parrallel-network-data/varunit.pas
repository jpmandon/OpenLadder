unit varunit;
// var and IO unit

{$mode objfpc}{$H+}

interface

uses bitUnit, timeUnit, fgl, sysutils;

type TgpioList = class(specialize TFPGObjectList<TIo>)
constructor Create(aFreeObjects: Boolean); end;
type TbitList = class(specialize TFPGObjectList<TBit>)
constructor Create(aFreeObjects: Boolean); end;
type TtimerList = class(specialize TFPGObjectList<TTimerObject>)
constructor Create(aFreeObjects: Boolean); end;


procedure initVar;
procedure initIO;
procedure initSystem;
procedure initTime;
function getVarValue(variable:string):string;
procedure setVarValue(variable,value:string);

var gpioList  : TgpioList;
    bitList   : TBitList;
    timerList : TtimerList;

//var
//IO
var
   I1		: TIO;
   I2		: TIO;
   I3		: TIO;
   I4		: TIO;
   O1		: TIO;
   I5		: TIO;
   O2		: TIO;
//SYSTEM
var
   sbAlways_On		: TBIT;
   sbAlways_Off		: TBIT;
   sbScanTime		: integer;
//TIME

implementation

constructor TgpioList.create(aFreeObjects: Boolean);
begin inherited Create(aFreeObjects); end;

constructor TBitList.create(aFreeObjects: Boolean);
begin inherited Create(aFreeObjects); end;

constructor TtimerList.create(aFreeObjects: Boolean);
begin inherited Create(aFreeObjects); end;

procedure initVar;
begin
bitList:=TBitList.Create(false);
//INITVAR
end;

procedure initIO;
begin
gpioList:=TGpioList.Create(false);
//INITIO
I1:=TIO.create('I1','GP0','INPUT');
I2:=TIO.create('I2','GP1','INPUT');
I3:=TIO.create('I3','GP2','INPUT');
I4:=TIO.create('I4','GP3','INPUT');
O1:=TIO.create('O1','GP4','OUTPUT');
I5:=TIO.create('I5','GP5','INPUT');
O2:=TIO.create('O2','GP6','OUTPUT');
end;

procedure initSystem;
begin
//INITSYSTEM
sbAlways_On:=TBIT.create('sbAlways_On',TRUE);
sbAlways_Off:=TBIT.create('sbAlways_Off',FALSE);
end;

procedure initTime;
begin
timerList:=TtimerList.Create(false);
//INITTIME
end;

function getVarValue(variable:string):string;
begin
case variable of
//GETVARVALUE
'sbScanTime': result:=inttostr(sbScanTime);
end;
end;

procedure setVarValue(variable,value:string);
begin
case variable of
//SETVARVALUE
'sbScanTime': sbScanTime:=strtoint(value);
end;
end;

end.
