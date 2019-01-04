unit Menu;

interface

uses
   System.SysUtils, System.Types, System.UITypes, System.Classes,
   System.Variants,
   FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
   FMX.Objects, FMX.Layouts;

type
   TFRMainMenu = class(TFrame)
      btnStart: TImage;
      btnHelp: TImage;
      btnExit: TImage;
      gpMainMenu: TGridPanelLayout;
      btnCredits: TImage;
      procedure btnStartClick(Sender: TObject);
      procedure btnExitClick(Sender: TObject);
      procedure btnHelpClick(Sender: TObject);
    procedure btnCreditsClick(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
   end;

var
   AMainMenuScreen: TFRMainMenu;

implementation

uses FRoboWars, DifficultyScreen, CreditsScreen, Model, HelpScreen;
{$R *.fmx}

procedure TFRMainMenu.btnCreditsClick(Sender: TObject);
begin

   Self.Visible := False;
   ACreditsScreen.Visible := True;
end;

procedure TFRMainMenu.btnExitClick(Sender: TObject);
begin
   MainForm.Close;
end;

procedure TFRMainMenu.btnStartClick(Sender: TObject);
begin
   Self.Visible := False;
   ADifficultyScreen.Visible := True;
end;

procedure TFRMainMenu.btnHelpClick(Sender: TObject);
begin
   Self.Visible := False;
   AHelpScreen.Visible := True;
end;

end.
