unit unitAboutForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls;

type

  { TaboutForm }

  TaboutForm = class(TForm)
    ButtonClose: TButton;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    splashTab: TTabSheet;
    AuthorTab: TTabSheet;
    LicenseTab: TTabSheet;
    procedure ButtonCloseClick(Sender: TObject);
  private

  public

  end;

var
  aboutForm: TaboutForm;

implementation

{$R *.lfm}

{ TaboutForm }

procedure TaboutForm.ButtonCloseClick(Sender: TObject);
begin
  hide;
end;

end.

