// MAIN
if ((GRAFCET = 0) AND I1.state) then begin
O1.setState;
GRAFCET:=10;
end;
if ((GRAFCET = 10) AND I2.state) then begin
O2.setState;
GRAFCET:=20;
end;
if ((GRAFCET = 20) AND I3.state) then begin
O3.setState;
GRAFCET:=30;
end;
if RESET.state then begin
GRAFCET:=0;
O3.resetState;
O2.resetState;
O1.resetState;
end;
