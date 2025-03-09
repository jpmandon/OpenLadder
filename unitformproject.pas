unit unitFormProject;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TprojectForm }

  TprojectForm = class(TForm)
    selectPathButton: TBitBtn;
    tOKbuttonProject: TButton;
    projectPLC: TComboBox;
    projectName: TEdit;
    projectPath: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    CancelButtonProject: TButton;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    procedure CancelButtonProjectClick(Sender: TObject);
    procedure tOKbuttonProjectClick(Sender: TObject);
    procedure selectPathButtonClick(Sender: TObject);
  private

  public

  end;

var
  newProjectForm: TprojectForm;

implementation

{$R *.lfm}

{ TprojectForm }

uses main;

procedure TprojectForm.selectPathButtonClick(Sender: TObject);
begin
    if SelectDirectoryDialog.execute then
       projectPath.Text:=SelectDirectoryDialog.FileName;
end;

procedure TprojectForm.tOKbuttonProjectClick(Sender: TObject);
begin
    if  (projectName.text<>'') and
        (projectPath.text<>'') and
        (projectPLC.Text<>'') then
           begin
            main.Form1.projectName:=projectName.text;
            main.Form1.projectPath:=projectPath.text;
            main.Form1.projectPLC:=projectPLC.Text;
            self.hide;
            main.form1.newProject;
           end
           else
           messagedlg('erreur','define all project data',mtWarning,[mbOK],'');
end;

procedure TprojectForm.CancelButtonProjectClick(Sender: TObject);
begin
  main.Form1.projectName:='';
  main.Form1.projectPath:='';
  main.Form1.projectPLC:='';
  self.hide;
end;

end.

