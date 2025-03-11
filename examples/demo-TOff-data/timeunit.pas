unit timeunit;

{$mode objfpc}{$H+}

{$I 'platform.cfg'}
{$I 'simulator.cfg'}

interface

uses
  Classes, SysUtils, bitunit
  {$IFNDEF SIMULATOR}
	{$IFDEF Raspberry_Pico}
	,pico_irq_c,pico_timer_c
	{$ENDIF}
  {$ENDIF}
  ;

Type

  TTimerObject = class(TBIT)	
	protected
		ftimerEnabled:boolean;  
		fpresetValue:word;				   
		fcurrentValue:word;
		ftimername:string;
	public		
		constructor Create(namevar:string;defaultState:boolean;presetInit:word);
		procedure dec; virtual; abstract;		
		procedure reset; virtual; abstract;
		procedure setPreset(preset:word);
		function getPreset:word;
		property presetValue:word read fpresetValue write fpresetValue;
		property timerEnabled:boolean read ftimerEnabled write ftimerEnabled;
		property currentValue:word read fcurrentValue write fcurrentValue;
		property timerName:string read fTimerName;				
	end; 
  
  TTOn = class(TTimerObject)
    public 		
		procedure reset; override;
		procedure dec; override;			
    end;

  TTOff = class(TTimerObject)
    public    
		procedure dec; override;
    end;
 
  TFlash = class(TTimerObject)
    private		
		ftimeON:word;
		ftimeOFF:word;
    public
		constructor Create(namevar:string;defaultState:boolean;presetON,presetOFF:word);
		procedure dec; override;
		property presetON:word read ftimeON write ftimeON;
		property presetOFF:word read ftimeOFF write ftimeOFF;
	end;

{$IFNDEF SIMULATOR}
{$IFDEF Raspberry_Pico}
procedure TIMER_IRQ_0_Handler; public name 'TIMER_IRQ_0_Handler';
{$ENDIF}
{$ENDIF}

var
  timerDec : boolean;

implementation

uses varunit;

//********************************************************************
// Timer Object
//********************************************************************

constructor TTimerObject.create(namevar:string;defaultState:boolean;presetInit:word);
begin
  inherited Create(namevar,defaultState);
  ftimername:=namevar;
  fpresetValue:=presetInit;
  fcurrentValue:=0;
  ftimerEnabled:=false;
  timerList.add(self);
  {$IFNDEF SIMULATOR}
  {$IFDEF Raspberry_Pico}
  irq_set_enabled(TIRQn_Enum.TIMER_IRQ_0,true);
  // set alarm to 100 mS
  TIMER.alarm[0]:=TIMER.timerawl+100000;
  TIMER.inte:=TIMER.inte or 1;
  timerdec:=false;
  {$ENDIF}
  {$ENDIF}
end;

function TTimerObject.getPreset:word;
begin
 getPreset:=fpresetValue;
end;

procedure TTimerObject.setPreset(preset:word);
begin
 fpresetValue:=preset;
end;

procedure TTOn.reset;
begin
 currentValue:=getPreset;
 ResetState;
end;

procedure TTOn.dec;
begin
if ftimerEnabled then
	begin
	if fcurrentValue>0 then fcurrentValue:=fcurrentValue-1;
	if fcurrentValue=0 then state:=true;
	end
else reset;
end;	

procedure TTOff.dec;
begin
if ftimerEnabled then 
	begin
	fstate:=true;
	fcurrentValue:=getPreset;
	end
else
	begin
	if fcurrentValue>0 then fcurrentValue:=fcurrentValue-1;
	if fcurrentValue=0 then fstate:=false;
	end;
end;	  

constructor TFlash.Create(namevar:string;defaultState:boolean;presetON,presetOFF:word);
begin
  inherited create(namevar,defaultState,presetON);
  ftimeON:=presetON;
  ftimeOFF:=presetOFF;
  fpresetValue:=presetON;
  fstate:=false;
end;

procedure TFlash.dec;
begin
if ftimerEnabled then
	begin
	if fcurrentValue>0 then fcurrentValue:=fcurrentValue-1;
	if fcurrentValue=0 then 
	   begin
	   if fstate then fcurrentValue:=ftimeOFF
	   else fcurrentValue:=ftimeON;
	   fstate:=not fstate;
	   end;
	end
else 
	begin
	fcurrentValue:=ftimeON;	
	fstate:=false;
	end;
end;

{$IFNDEF SIMULATOR}
{$IFDEF Raspberry_Pico}
procedure TIMER_IRQ_0_Handler; public name 'TIMER_IRQ_0_Handler';
begin
// ack alarm0
  TIMER.intr:=1;
  // set alarm0 off
  TIMER.inte:=Timer.inte xor 1;
  irq_set_enabled(TIRQn_Enum.TIMER_IRQ_0,true);
  // set alarm to 100 mS
  TIMER.alarm[0]:=TIMER.timerawl+100000;
  TIMER.inte:=TIMER.inte or 1;
  // set flag to dec timers
  timerdec:=true;
end;
{$ENDIF}
{$ENDIF}

end.
