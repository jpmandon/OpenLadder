unit hardwaregpioDep;

{$mode ObjFPC}{$H+}{$MACRO ON}

interface

uses
  Classes, SysUtils;

procedure init_GPIO(GPIOname:string;typeGpio:string);
function getGpioNumber(GPIOname: string; typeGpio: string):integer;
procedure scanIO;

implementation

uses varunit;

procedure init_GPIO(GPIOname: string; typeGpio: string);
var
  gpio : integer;
begin
end;

function getGpioNumber(GPIOname: string; typeGpio: string):integer;
begin
  result:=strtoint(copy(GPIOname,pos('GP',GPIOname)+2,length(GPIOname)));
end;

procedure scanIO;
var
  i : integer;
begin
end;

end.

