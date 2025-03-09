unit VariableUnit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TVariable = class
    protected
    fname    : string;
    ftype    : string;
    fcomment : string;
    public
    constructor create(name:string;typeVar:string;commentField:string); virtual;
    property nameVar:string read fname write fname;
    property typeVar:string read ftype write ftype;
    property comment:string read fcomment write fcomment;
  end;

type TIOPlc = class(TVariable)
     protected
     fGPIO : string;
     public
     constructor create(name:string;typeVariable:string;gpio:string;commentField:string);
     property gpio:string read fgpio write fGPIO;
     end;

type TTimerVar = class (TVariable)
     protected
     fpreset    : string;
     fpresetON  : string;
     fpresetOFF : string;
     public
     constructor create(name:string;preset,presetON,presetOFF:string;typev:string);
     property preset:string read fpreset write fpreset;
     property presetON:string read fpresetON write fpresetON;
     property presetOFF:string read fpresetOFF write fpresetOFF;
     end;


implementation

constructor TVariable.create(name:string;typeVar:string;commentField:string);
begin
     fname:=name;
     ftype:=typeVar;
     fcomment:=commentField;
end;

constructor TIOPlc.create(name:string;typeVariable:string;gpio:string;commentField:string);
begin
   inherited create(name,typeVariable,commentField);
   fgpio:=gpio;
end;

constructor TTimerVar.create(name:string;preset,presetON,presetOFF:string;typev:string);
begin
   inherited create(name,typev,'');
   fpreset:=preset;
   fpresetON:=presetON;
   fpresetOFF:=presetOFF;
end;

end.

