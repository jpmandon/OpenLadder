unit unitsaveasform;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TsaveAsForm }

  TsaveAsForm = class(TForm)
    OkButton: TButton;
    Label2: TLabel;
    cancelButton: TButton;
    projectPathEdit: TEdit;
    Label1: TLabel;
    projectNameedit: TEdit;
    selectPathButton: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure setPath(pathname:string);
    procedure setName(nameProject:string);
  private

  public

  end;

var
  saveAsForm: TsaveAsForm;

implementation

{$R *.lfm}

{ TsaveAsForm }

uses main;

procedure TsaveAsForm.FormCreate(Sender: TObject);
begin
end;

procedure TsaveAsForm.setPath(pathname:string);
begin
  projectPathEdit.text:=pathname;
end;

procedure TsaveAsForm.setName(nameProject:string);
begin
  projectNameEdit.text:=name;
end;

end.

