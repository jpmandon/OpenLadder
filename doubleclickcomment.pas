unit doubleclickcomment;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TcommentForm }

  TcommentForm = class(TForm)
    cancelButton: TButton;
    ColorDialog: TColorDialog;
    COMMENT: TLabel;
    editComment: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    OKbutton: TButton;
    BackgroundColorButton: TShape;
    TextcolorButton: TShape;
    procedure cancelButtonClick(Sender: TObject);
    procedure editCommentKeyPress(Sender: TObject; var Key: char);
    procedure OKbuttonClick(Sender: TObject);
    procedure BackgroundColorButtonClick(Sender: TObject);
    procedure TextcolorButtonClick(Sender: TObject);
  private

  public
  symbole : TObject;
  end;

var
  commentForm: TcommentForm;

implementation

{$R *.lfm}

uses LadderSymbol,main,usimplegraph;

{ TcommentForm }

procedure TcommentForm.cancelButtonClick(Sender: TObject);
begin
  self.hide;
end;

procedure TcommentForm.editCommentKeyPress(Sender: TObject; var Key: char);
begin
  if key=chr(13) then OKbuttonClick(self);
end;

procedure TcommentForm.OKbuttonClick(Sender: TObject);
begin
  TComment(symbole).allias:=editComment.Text;
  self.hide;
end;

procedure TcommentForm.BackgroundColorButtonClick(Sender: TObject);
begin
  if ColorDialog.execute then
      begin
      TEvsRectangularNode(symbole).brush.Color:=ColorDialog.Color;
      BackgroundColorButton.Brush.Color:=ColorDialog.Color;
      end;
end;

procedure TcommentForm.TextcolorButtonClick(Sender: TObject);
begin
  if ColorDialog.execute then
       begin
       TEvsRectangularNode(symbole).Font.Color:=ColorDialog.Color;
       textColorButton.Brush.Color:=ColorDialog.Color;
       end;
end;

end.

