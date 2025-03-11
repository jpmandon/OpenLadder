// MAIN
if I1.state then TIMER1.timerEnabled:=true else begin TIMER1.timerEnabled:=false; TIMER1.reset; end;
O1.state:=(TIMER1.state);
