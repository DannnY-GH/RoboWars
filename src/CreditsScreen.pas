unit CreditsScreen;

interface

uses
   System.SysUtils, System.Types, System.UITypes, System.Classes,
   System.Variants,
   FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
   FMX.Objects, System.Rtti, FMX.Grid.Style, FMX.Controls.Presentation,
   FMX.ScrollBox, FMX.Grid, FMX.Layouts, FMX.Ani;

type
   TFRCreditsScreen = class(TFrame)
    gpCredits: TGridPanelLayout;
      btnExit: TImage;
      imgLogo: TImage;
    imgCredits: TImage;
    rBack: TRectangle;
      procedure btnExitClick(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
   end;

var
   ACreditsScreen: TFRCreditsScreen;

implementation

uses
   FRoboWars, Menu;
{$R *.fmx}

procedure TFRCreditsScreen.btnExitClick(Sender: TObject);
begin
   Self.Visible := False;
   AMainMenuScreen.Visible := True;
end;

end.
