unit unitProjectTree;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,ComCtrls;

type TProjectTree = class(TTreeview)
  protected
  fproject : TProject;
  public
  constructor create(project:TProject);
  procedure miseajour;
end;

implementation

constructor TProjectTree.create(project:TProject);
begin
     fproject:=project;
end;

procedure TProjectTree.miseajour;
var
  i : integer ;
begin
     for i:=0 to fprojectTree.Items.Count-1 do
         fproject.fprojectTree.Items[i].Delete;
     fproject.fprojectTree.Update;
     fproject.fprojectTree.Items.Add(nil,fproject.fname);
     fproject.fprojectTree.Items.Add(nil,'Logic modules');
end;

end.

