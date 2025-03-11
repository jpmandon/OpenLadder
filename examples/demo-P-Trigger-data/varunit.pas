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
var
   OUTPUT1		: TFront;
   MW0		: integer;
//IO
var
   INTER		: TIO;
   LED1		: TIO;
   LED2		: TIO;
   LED3		: TIO;
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
INTER:=TIO.create('INTER','GP0','INPUT');
bitList.Add(INTER);
LED1:=TIO.create('LED1','GP1','OUTPUT');
bitList.Add(LED1);
LED2:=TIO.create('LED2','GP2','OUTPUT');
bitList.Add(LED2);
LED3:=TIO.create('LED3','GP3','OUTPUT');
bitList.Add(LED3);
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
end;

procedure initFront;
begin
frontList:=TFrontList.Create(false);
//INITFRONT
OUTPUT1:=TFRONT.create('OUTPUT1',false);
frontList.Add(OUTPUT1);
end;

function getVarValue(variable:string):string;
begin
case variable of
//GETVARVALUE
'sbScanTime': result:=inttostr(sbScanTime);
'MW0': result:=inttostr(MW0);
end;
end;

procedure setVarValue(variable,value:string);
begin
case variable of
//SETVARVALUE
'sbScanTime': sbScanTime:=strtoint(value);
'MW0': MW0:=strtoint(value);
end;
end;

end.
