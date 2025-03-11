// MAIN
if I1.state then FLASH.timerEnabled:=true else  begin FLASH.timerEnabled:=false; FLASH.state:=false; end;
O1.state:=(FLASH.state);
