unit unitOpenProjectForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TForm2 }

  TForm2 = class(TForm)
    CancelButtonProject: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    projectName: TEdit;
    projectPath: TEdit;
    projectPLC: TComboBox;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    selectPathButton: TBitBtn;
    tOKbuttonProject: TButton;
  private

  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

uses main;

{ TForm2 }


end.

