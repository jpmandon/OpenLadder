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
function getVarValue(variable:string):string;
procedure setVarValue(variable,value:string);

var gpioList  : TgpioList;
    bitList   : TBitList;
    timerList : TtimerList;

//var
var
   MW2		: TBIT;
//IO
var
   setOn		: TIO;
   SetOff		: TIO;
   O1		: TIO;
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
MW2:=TBIT.create('MW2',false);
end;

procedure initIO;
begin
gpioList:=TGpioList.Create(false);
//INITIO
setOn:=TIO.create('setOn','GP0','INPUT');
SetOff:=TIO.create('SetOff','GP2','INPUT');
O1:=TIO.create('O1','GP1','OUTPUT');
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
