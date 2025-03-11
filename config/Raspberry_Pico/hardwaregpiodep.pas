unit hardwaregpioDep;

{$mode ObjFPC}{$H+}{$MACRO ON}

interface

uses
  Classes, SysUtils,pico_gpio_c;

procedure init_GPIO(GPIOname:string;typeGpio:string);
function getGpioNumber(GPIOname: string; typeGpio: string):integer;
procedure scanIO;

implementation

uses varunit,bitunit;

procedure init_GPIO(GPIOname: string; typeGpio: string);
var
  gpio : integer;
begin
  gpio:=strtoint(copy(GPIOname,pos('GP',GPIOname)+2,length(GPIOname)));
  gpio_init(gpio);
  if typeGpio='INPUT' then
     gpio_set_dir(gpio,TGPIO_Direction.GPIO_IN);
  if typeGpio='OUTPUT' then
     gpio_set_dir(gpio,TGPIO_Direction.GPIO_OUT);
  gpio_put(gpio,false);
end;

function getGpioNumber(GPIOname: string; typeGpio: string):integer;
begin
  result:=strtoint(copy(GPIOname,pos('GP',GPIOname)+2,length(GPIOname)));
end;

procedure scanIO;
var
  i : integer;
begin
  for i:=0 to gpioList.Count-1 do
      begin
      if gpioList[i].isInput then
         gpioList[i].state:=gpio_get(getGpioNumber(gpioList[i].gpio,gpioList[i].typeGpio))
      else
         gpio_put(getGpioNumber(gpioList[i].gpio,gpioList[i].typeGpio),gpioList[i].state);
      end;
end;

end.

