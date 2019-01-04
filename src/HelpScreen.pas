unit HelpScreen;

interface

uses
   System.SysUtils, System.Types, System.UITypes, System.Classes,
   System.Variants,
   FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
   FMX.Objects, System.Rtti, FMX.Grid.Style, FMX.Controls.Presentation,
   FMX.ScrollBox, FMX.Grid, FMX.Layouts;

type
   TFRHelpScreen = class(TFrame)
      btnExit: TImage;
      gpHelp: TGridPanelLayout;
      imgKeys: TImage;
      Image1: TImage;
      Rectangle1: TRectangle;
      procedure btnExitClick(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
   end;

var
   AHelpScreen: TFRHelpScreen;

implementation

uses
   FRoboWars, Menu, GameScreen, PauseScreen, Model;

{$R *.fmx}

procedure TFRHelpScreen.btnExitClick(Sender: TObject);
begin
   Self.Visible := False;
   if AGameScreen.Visible then
   begin
      APauseScreen.Visible := True;
      AModel.ActiveWindow := awPause;
   end
   else
   begin
      AMainMenuScreen.Visible := True;
      AModel.ActiveWindow := awMainMenu;
   end;
end;

end.
