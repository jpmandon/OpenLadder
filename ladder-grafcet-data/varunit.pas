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
var
   GRAFCET		: integer;
//IO
var
   RESET		: TIO;
   O3		: TIO;
   O2		: TIO;
   O1		: TIO;
   I3		: TIO;
   I2		: TIO;
   I1		: TIO;
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
RESET:=TIO.create('RESET','GP6','INPUT');
O3:=TIO.create('O3','GP5','OUTPUT');
O2:=TIO.create('O2','GP4','OUTPUT');
O1:=TIO.create('O1','GP3','OUTPUT');
I3:=TIO.create('I3','GP2','INPUT');
I2:=TIO.create('I2','GP1','INPUT');
I1:=TIO.create('I1','GP0','INPUT');
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
'GRAFCET': result:=inttostr(GRAFCET);
end;
end;

procedure setVarValue(variable,value:string);
begin
case variable of
//SETVARVALUE
'sbScanTime': sbScanTime:=strtoint(value);
'GRAFCET': GRAFCET:=strtoint(value);
end;
end;

end.
