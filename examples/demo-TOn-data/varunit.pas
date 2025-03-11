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
type TFrontList = class(specialize TFPGObjectList<TFront>)
constructor Create(aFreeObjects: Boolean); end;



procedure initVar;
procedure initIO;
procedure initSystem;
procedure initTime;
procedure initFront;
function getVarValue(variable:string):string;
procedure setVarValue(variable,value:string);

var gpioList  : TgpioList;
    bitList   : TBitList;
    timerList : TtimerList;
    frontList : TFrontList;

//var
//IO
var
   I1		: TIO;
   O1		: TIO;
//SYSTEM
var
   sbAlways_On		: TBIT;
   sbAlways_Off		: TBIT;
   sbScanTime		: integer;
//TIME
var
   TIMER1		: TTon;

implementation

constructor TgpioList.create(aFreeObjects: Boolean);
begin inherited Create(aFreeObjects); end;

constructor TBitList.create(aFreeObjects: Boolean);
begin inherited Create(aFreeObjects); end;

constructor TtimerList.create(aFreeObjects: Boolean);
begin inherited Create(aFreeObjects); end;

constructor TFrontList.create(aFreeObjects: Boolean);
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
bitList.Add(I1);
O1:=TIO.create('O1','GP1','OUTPUT');
bitList.Add(O1);
end;

procedure initSystem;
begin
//INITSYSTEM
sbAlways_On:=TBIT.create('sbAlways_On',TRUE);
bitList.Add(sbAlways_On);
sbAlways_Off:=TBIT.create('sbAlways_Off',FALSE);
bitList.Add(sbAlways_Off);
end;

procedure initTime;
begin
timerList:=TtimerList.Create(false);
//INITTIME
TIMER1:=TTOn.create('TIMER1',false,20);
bitlist.add(TIMER1);
end;

procedure initFront;
begin
frontList:=TFrontList.Create(false);
//INITFRONT
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
