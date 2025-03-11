unit pipe;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  sysutils,
  varunit,
  bitunit;

procedure scanPipe;

implementation

var
  i,j,n          : integer;
  chaine    	 : string;
  variable,etat  : string;
  delimiter 	 : string;
  checkVarlist   : array[0..100] of string;
  value		 : string;

procedure scanPipe;
  begin
    repeat
      readln(chaine);
      if chaine='*' then
         begin
         writeln('*');
         exit;
         end;
      if chaine<>'' then
         begin
         delimiter:=copy(chaine,0,1);
         chaine:=copy(chaine,2,length(chaine));
         end;
      case delimiter of
           '?' : begin
                 i:=0;
                 while length(chaine)<>0 do
                       begin
                         if pos(',',chaine)<>0 then
                            begin
                            checkVarlist[i]:=copy(chaine,1,pos(',',chaine)-1);
                            chaine:=copy(chaine,pos(',',chaine)+1,length(chaine))
                            end
                            else
                            begin
                            checkVarlist[i]:=chaine;
                            chaine:='';
                            end;
                         i:=i+1;
                       end;
                 end;
           '=' : begin		 
		   variable:=copy(chaine,1,pos('=',chaine)-1);
                   etat:=copy(chaine,pos('=',chaine)+1,length(chaine));
                   // is it a number ?
                   if variable[1]='@' then
	           begin
		    setVarValue(copy(variable,2,length(variable)),etat);               
                   end
                   else
                   // it's a bit
                   begin
                   for n:=0 to bitlist.count-1 do
		     begin
                     if bitlist[n].bitName=variable then
                        begin
                        if etat='true' then bitlist[n].state:=true
                        else bitlist[n].state:=false;
                        end;
                     end;   
                   end;    
                 end;
         end;
    until chaine='';
  if i>0 then
     for j:=0 to i-1 do
         begin
         // is it a number ?
         if checkVarList[j][1]='@' then
	    begin
	     value:=getVarValue(copy(checkVarlist[j],2,length(checkVarlist[j])));
	     writeln(checkVarlist[j]+'='+value);
	    end;
         for n:=0 to bitList.count-1 do
             if checkVarlist[j]=bitList[n].bitName then		
		     begin
			if bitList[n].state=true then
			   begin
			   if bitList[n].isSetReset then
			      writeln(checkVarlist[j]+'=Set')
			   else 
			      writeln(checkVarlist[j]+'=On');
			   end
			   else
			   begin
			   if bitList[n].isSetReset then
			      writeln(checkVarlist[j]+'=Reset')
			   else                    
			      writeln(checkVarlist[j]+'=Off');
			   end;
		     end;
         end;
  writeln('#');
  end;
  
end.

