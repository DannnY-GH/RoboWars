unit PauseScreen;

interface

uses
   System.SysUtils, System.Types, System.UITypes, System.Classes,
   System.Variants,
   FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
   FMX.Objects, FMX.Layouts;

type
   TFRPauseScreen = class(TFrame)
      GridPanelLayout1: TGridPanelLayout;
      btnResume: TImage;
      Rectangle1: TRectangle;
      btnHelp: TImage;
      btnExit: TImage;
      procedure btnResumeClick(Sender: TObject);
      procedure btnHelpClick(Sender: TObject);
      procedure btnExitClick(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
   end;

var
   APauseScreen: TFRPauseScreen;

implementation

uses
   Controller, Model, HelpScreen, DifficultyScreen, GameScreen, Menu;
{$R *.fmx}

procedure TFRPauseScreen.btnHelpClick(Sender: TObject);
begin
   Self.Visible := False;
   AMainMenuScreen.btnHelp.OnClick(Self);
   AModel.ActiveWindow := awHelp;
end;

procedure TFRPauseScreen.btnResumeClick(Sender: TObject);
begin
   Self.Visible := False;
   AController.Timer.Resume;
   AModel.ActiveWindow := awGame;
end;

procedure TFRPauseScreen.btnExitClick(Sender: TObject);
begin
   Self.Visible := False;
   AController.Timer.Resume;
   AGameScreen.btnBack.OnClick(Self);
end;

end.
