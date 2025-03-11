// MAIN
if INTER.state then begin if not (OUTPUT1.OldState) then begin OUTPUT1.NumScan:=CurrScan+1; end; end 
else begin if OUTPUT1.OldState then OUTPUT1.OldState:=false; end;
if OUTPUT1.state then MW0:=MW0 + 10;
LED1.state:=((MW0 = 10));
LED2.state:=((MW0 = 20));
LED3.state:=((MW0 = 30));
if (MW0 = 40) then MW0:=0;
