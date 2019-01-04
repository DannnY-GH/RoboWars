unit GameScreen;

interface

uses
   System.SysUtils, System.Types, System.UITypes, System.Classes,
   System.Variants,
   FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
   FMX.Objects, FMX.Layouts, FMX.Controls.Presentation, Controller, Debug,
   ScoreBoard, Windows;

type
   TFRGameScreen = class(TFrame)
      gpStage: TGridPanelLayout;
      imgBackg: TImage;
      btnBack: TImage;
      gpMouseTrack: TGridPanelLayout;
      lStage: TLayout;
      pnlMouseTrack: TPanel;
      gpYellowBackg: TGridPanelLayout;
      imgYellowBackg: TImage;
      c1: TCircle;
      tbSpeed: TTrackBar;
      cR: TCircle;
      c2: TCircle;
      frDebug1: TfrDebug;
      procedure btnBackClick(Sender: TObject);
      procedure pnlMouseTrackMouseMove(Sender: TObject; Shift: TShiftState;
        X, Y: Single);
      procedure FramePaint(Sender: TObject; Canvas: TCanvas;
        const ARect: TRectF);
      procedure tbSpeedChange(Sender: TObject);
      procedure FrameKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
        Shift: TShiftState);
   private
   public
   end;

var
   AGameScreen: TFRGameScreen;

implementation

uses
   FRoboWars, Model, DifficultyScreen, PauseScreen;
{$R *.fmx}

procedure TFRGameScreen.btnBackClick(Sender: TObject);
begin
   Self.Visible := False;

   AController.Timer.Suspend;
   AModel.StopGame;

   ADifficultyScreen.Visible := True;
   AScoreBoard.Visible := False;
end;

procedure TFRGameScreen.FrameKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
   if (AModel.ActiveWindow = awGame) and (Key = VK_ESCAPE) then
   begin
      AController.Timer.Suspend;
      APauseScreen.Visible := True;
   end;
end;

procedure TFRGameScreen.FramePaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
   Exit;
end;

procedure TFRGameScreen.pnlMouseTrackMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
begin
   AModel.FMousePos := PointF(X, Y);
end;

procedure TFRGameScreen.tbSpeedChange(Sender: TObject);
begin
   AController.Timer.Delay := Round(tbSpeed.Value);
end;

end.
