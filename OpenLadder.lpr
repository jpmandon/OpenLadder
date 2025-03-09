program OpenLadder;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Main, doubleClickBit, unitNewProjectForm, doubleclickcompare,
  doubleclickstore, doubleclickcomment, doubleclickmath, simulatorUnit,
  doubleclicktimer, doubleclickflash, unitAboutForm;

{$R *.res}

begin
  RequireDerivedFormResource:=true;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TbitForm, bitForm);
  Application.CreateForm(TnewProjectForm, newProjectForm);
  Application.CreateForm(TCompareForm, CompareForm);
  Application.CreateForm(TstoreForm, storeForm);
  Application.CreateForm(TcommentForm, commentForm);
  Application.CreateForm(TMathForm, mathForm);
  Application.CreateForm(TmathForm, mathForm);
  Application.CreateForm(TtimerForm, timerForm);
  Application.CreateForm(TflashForm, flashForm);
  Application.CreateForm(TaboutForm, aboutForm);
  Application.Run;
end.

