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
//SYSTEM
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
end;

procedure initSystem;
begin
//INITSYSTEM
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
end;

function getVarValue(variable:string):string;
begin
case variable of
//GETVARVALUE
end;
end;

procedure setVarValue(variable,value:string);
begin
case variable of
//SETVARVALUE
end;
end;

end.
