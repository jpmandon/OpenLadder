program runtime;
{$MODE OBJFPC}
{$H+}
{$MEMORY 10000,10000}

{$I 'platform.cfg'}
{$I 'simulator.cfg'}

uses {$ifdef unix}cthreads,{$endif}classes,varunit,sysutils,timeunit
{$IFDEF Simulator}
,pipe,custapp,fptimer
{$ENDIF}
{$IFNDEF Simulator}
	{$IFDEF Raspberry_Pico}
	,pico_c,pico_gpio_c,hardwaregpiodep
	{$ENDIF}
{$ENDIF}	
;

{$IFDEF Simulator}
Type
        TTimerApp = Class(TCustomApplication)
	Private
		FTimer : TFPTimer;
	Public
		Procedure DoRun; override;
		Procedure DoTick(Sender : TObject);
  end;
var
	startScan,stopScan         : TDateTime;
	Hr,Mn,Sc,Ms,scanTime	   : word;
	
Procedure TTimerApp.DoTick(Sender : TObject);
Var
  i : integer;
begin
for i:=0 to timerList.count-1 do
 if (timerList[i] is TTOn) and (timerList[i].timerEnabled) then
    timerList[i].dec;
 if (timerList[i] is TTOff) then
    timerList[i].dec;
if (timerList[i] is TFlash) and (timerList[i].timerEnabled) then        
    timerList[i].dec;    
end;  

Procedure TTimerApp.DoRun;
begin
  FTimer:=TFPTimer.Create(Self);
  FTimer.Interval:=100;
  FTimer.OnTimer:=@DoTick;
  FTimer.Enabled:=True;
  Try
      while true do
        begin
	startScan:=now;
	scanPipe;
	//blocks
{$I 'main.pas'}
	CheckSynchronize;
	scanPipe;
	decodeTime(now-startScan,Hr,Mn,Sc,Ms);
	sbScanTime:=Ms;
	CheckSynchronize;
	end
  Finally
    FTimer.Enabled:=False;
    FreeAndNil(FTimer);
  end;
  Terminate;
end;		

{$ENDIF}

begin
  // Init
  gpioList:=TgpioList.Create(false);
  bitList:=TBitList.Create(false);
  initVar;
  initIO;
  initSystem;
  initTime;
  // Loop
  {$IFDEF Simulator}
  with TTimerApp.create(nil) do
	try 
	  run
	finally
	  Free;
	end;
  {$ELSE}
  while (true) do
        begin
          scanIO;
          //blocks
{$I 'main.pas'}
        end;
  {$ENDIF}
end.

