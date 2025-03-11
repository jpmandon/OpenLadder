// main
O1.state:=((NOT(SetOff.state) AND (setOn.state OR O1.state)));
O2.state:=(O1.state);
