unit unitNewProjectForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Grids, Dialogs, StdCtrls, Buttons;

type

  { TnewProjectForm }

  TnewProjectForm = class(TForm)
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
    procedure CancelButtonProjectClick(Sender: TObject);
    procedure selectPathButtonClick(Sender: TObject);
    procedure tOKbuttonProjectClick(Sender: TObject);
  private

  public

  end;

var
  newProjectForm: TnewProjectForm;

implementation

{$R *.lfm}

uses main;

procedure TnewProjectForm.selectPathButtonClick(Sender: TObject);
begin
    if SelectDirectoryDialog.execute then
       projectPath.Text:=SelectDirectoryDialog.FileName;
end;

procedure TnewProjectForm.tOKbuttonProjectClick(Sender: TObject);
begin
    if  (projectName.text<>'') and
        (projectPath.text<>'') and
        (projectPLC.Text<>'') then
           begin
            Form1.projectName:=projectName.text;
            Form1.projectPath:=projectPath.text+'/';
            Form1.projectPLC:=projectPLC.Text;
            self.hide;
            form1.newProject;
            form1.IOplcGrid.Options:= [goFixedHorzLine,goFixedVertLine,goHorzLine,
                                            goVertLine,goDontScrollPartCell,goEditing];
            form1.VARGrid.Options  := [goFixedHorzLine,goFixedVertLine,goHorzLine,
                                            goVertLine,goDontScrollPartCell,goEditing];
            form1.expandVarButton.Visible:=True;
            form1.expandVarButton.Visible:=True;
            form1.VariablesPageControl.Visible:=True;
           end
           else
           messagedlg('erreur','define all project data',mtWarning,[mbOK],'');
end;

procedure TnewProjectForm.CancelButtonProjectClick(Sender: TObject);
begin
  Form1.projectName:='';
  Form1.projectPath:='';
  Form1.projectPLC:='';
  hide;
end;
end.

