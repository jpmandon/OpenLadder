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
   O1		: TIO;
   O2		: TIO;
   O3		: TIO;
//SYSTEM
var
   sbAlways_On		: TBIT;
   sbAlways_Off		: TBIT;
   sbScanTime		: integer;
//TIME
var
   TIMER1		: TTon;
   TIMER2		: TToff;
   FLASH		: TFlash;

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
O1:=TIO.create('O1','GP1','OUTPUT');
O2:=TIO.create('O2','GP2','OUTPUT');
O3:=TIO.create('O3','GP3','OUTPUT');
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
TIMER1:=TTOn.create('TIMER1',false,100);
TIMER2:=TTOff.create('TIMER2',false,50);
FLASH:=TFlash.create('FLASH',false,30,30);
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
