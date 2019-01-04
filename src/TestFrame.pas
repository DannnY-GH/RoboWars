unit TestFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Math.Vectors, FMX.Controls3D, FMX.Layers3D, FMX.Objects, FMX.Layouts;

type
  TFrame1 = class(TFrame)
    FlowLayout1: TFlowLayout;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Layout3D1: TLayout3D;
    procedure Image3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

procedure TFrame1.Image3Click(Sender: TObject);
begin
Image3.Visible := False;
end;

end.
