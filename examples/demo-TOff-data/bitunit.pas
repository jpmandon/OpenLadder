unit bitunit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,hardwaregpiodep;

type TBIT = class(TObject)
  protected
    fstate    : boolean;
    fname     : string;	
    fTypeVar  : string;
    fisSetReset : boolean;
    public
    constructor create(name:string;defaultState:boolean);
    procedure setState;
    procedure resetState;
    function getState:boolean;
    function isIO:boolean; virtual;
    function isInput:boolean;
    property state:boolean read fstate write fstate;
    property bitName:string read fname;
    property isSetReset:boolean read fisSetReset;
    end;

type TIo = class(TBit)
  protected
    fGpio : string;

    public
    constructor create(name,gpio,typeVar:string);
    function isIO:boolean; override;
    property gpio:string read fgpio;
    property typeGpio:string read fTypeVar;
    property isSetReset:boolean read fisSetReset;
    end;

type TFront = class(TBIT)
  protected
    fNumScan   : word;
    fOldState : boolean;
  public
    constructor create(name:string;defaultState:boolean);
    property NumScan:word read fNumScan write fNumScan;
    property OldState:boolean read fOldState write fOldState;
  end;

implementation

uses varunit;

{ TBIT }

constructor TBIT.create(name:string;defaultState:boolean);
begin
  Inherited create;
  fstate:=defaultState;
  fname:=name;
  fisSetReset:=false;
end;

procedure TBit.setState;
begin
     fstate:=true;
     fisSetReset:=true;
end;

procedure TBit.resetState;
begin
     fstate:=false;
     fisSetReset:=true;
end;

function TBit.getState:boolean;
begin  
  result:=fstate;
end;

function TBit.isIO:boolean;
begin
  result:=false;
end;

function TBit.isInput:boolean;
begin
  if fTypeVar='INPUT' then
     result:=true
     else
     result:=false;
end;

{ /TBIT }

{ TIO }

constructor TIo.create(name,gpio,typeVar:string);
begin
  Inherited create(name,false);
  fGpio:=gpio;
  fTypeVar:=typeVar;
  gpioList.Add(self);
  fisSetReset:=false;
  init_GPIO(gpio,typeVar);
end;

function TIo.isIO:boolean;
begin
  result:=true;
end;

{ /TIO }

{ TFRONT }

constructor TFront.create(name:string;defaultState:boolean);
begin
  inherited create(name,defaultState);
end;

{ /TFRONT }

end.

