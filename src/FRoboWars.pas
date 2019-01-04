unit FRoboWars;

interface

uses
   Tank, GameScreen, Menu, DifficultyScreen, CongratScreen, ScoreBoard,
   HelpScreen, Model, Controller, StopWatch, System.Classes, FMX.Types,
   FMX.Controls, FMX.Objects, Timer, System.SysUtils, System.Types,
   System.UITypes, System.Variants, FMX.Forms, FMX.Graphics, FMX.Dialogs,
   FMX.Layouts, System.Math.Vectors, FMX.Controls3D, FMX.Layers3D, TestFrame,
   FMX.Controls.Presentation, FMX.StdCtrls, FMX.Ani, Windows, Debug,
   SoundManager, PauseScreen, System.Generics.Collections, CreditsScreen;

type
   TMainForm = class(TForm)
      imgBackground: TImage;
      procedure FormCreate(Sender: TObject);
      procedure FormResize(Sender: TObject);
      procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
        Shift: TShiftState);
   private
      PrevWindowSize: TPoint;
      PrevStageSize: TPointF;
   public
   end;

var
   MainForm: TMainForm;

implementation

{$R *.fmx}
{$R *.Windows.fmx MSWINDOWS}

procedure TMainForm.FormCreate(Sender: TObject);
begin
   AMainMenuScreen := TFRMainMenu.Create(Self);
   AMainMenuScreen.Parent := Self;
   ADifficultyScreen := TFRDifficulty.Create(Self);
   ADifficultyScreen.Parent := MainForm;
   ADifficultyScreen.Visible := False;
   AGameScreen := TFRGameScreen.Create(Self);
   AGameScreen.Parent := MainForm;
   AGameScreen.Visible := False;
   Visible := False;
   AHelpScreen := TFRHelpScreen.Create(Self);
   AHelpScreen.Parent := MainForm;
   AHelpScreen.Visible := False;
   ACreditsScreen := TFRCreditsScreen.Create(Self);
   ACreditsScreen.Parent := MainForm;
   ACreditsScreen.Visible := False;
   ACongratScreen := TFRCongratScreen.Create(Self);
   ACongratScreen.Parent := MainForm;
   ACongratScreen.Visible := False;
   AModel := TModel.Create;
   ASoundManager := TSoundManager.Create;
   ASoundManager.PlaySound('menu');
   AController := TController.Create;
   AScoreBoard := TFRScoreBoard.Create(Self);
   AScoreBoard.Parent := AGameScreen;
   AScoreBoard.Visible := False;
   APauseScreen := TFRPauseScreen.Create(Self);
   APauseScreen.Parent := Self;
   APauseScreen.Visible := False;
   with AModel do
   begin
      ActiveWindow := awMainMenu;
   end;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
   with ASoundManager do
   begin
      if KeyChar = '1' then
         ASoundManager.FlipVolume('menu');
   end;
   with AModel do
   begin
      if KeyChar = '9' then
         FShowDemo := not FShowDemo;
      if KeyChar = '0' then
         FStopEnemies := not FStopEnemies;
      if KeyChar = '2' then
         if Players.Count > 0 then
            with Players[0] do
               ControlType := Tank.TControlType((Ord(ControlType) + 1) mod 2);
   end;

   if KeyChar = '=' then
      AModel.DropTank(3, ctNone);
   if KeyChar = '-' then
      AModel.PopTank(3);

   if (Key = VK_ESCAPE) then
   begin
      case AModel.ActiveWindow of
         awGame:
            begin
               AController.Timer.Suspend;
               APauseScreen.Visible := True;
               AModel.ActiveWindow := awPause;
            end;
         awPause:
            begin
               APauseScreen.btnResume.OnClick(Self);
               AModel.ActiveWindow := awGame;
            end;
         awHelp:
            begin
               AHelpScreen.btnExit.OnClick(Self);
            end;
      end;
   end;

   if (Key = VK_RETURN) and (Shift = [ssAlt]) then
   begin
      if MainForm.WindowState <> System.UITypes.TWindowState.wsMaximized then
      begin
         PrevWindowSize := Point(Self.Width, Self.Height);
         Self.FullScreen := True;
         imgBackground.WrapMode := FMX.Objects.TImageWrapMode.Original;
         Self.BorderStyle := TFmxFormBorderStyle.bsNone;
      end
      else
      begin
         Self.FullScreen := False;
         Self.BorderStyle := TFmxFormBorderStyle.Sizeable;
         Self.Width := PrevWindowSize.X;
         Self.Height := PrevWindowSize.Y;
      end;
   end;
end;

procedure TMainForm.FormResize(Sender: TObject);
var
   WFact, HFact: Single;
   I: Integer;
begin
   WFact := AGameScreen.imgBackg.Width / PrevStageSize.X;
   HFact := AGameScreen.imgBackg.Height / PrevStageSize.Y;
   AScoreBoard.Position.Point :=
     PointF(AGameScreen.imgBackg.Width / 2 - AScoreBoard.Width / 2, 0);
   with AModel do
   begin
      case GameMode of
         gmPingPong:
            begin
               if not(Players.Count = 0) then
               begin
                  with Players[1] do
                     Pos := PointF(Pos.X * WFact, Pos.Y * HFact);
                  with Players[0] do
                     Pos := PointF(Pos.X, Pos.Y * HFact);
               end;
               if Ball <> nil then
                  with Ball do
                     Pos := PointF(Pos.X * WFact, Pos.Y * HFact);
            end;
      else
         begin
            for I := 0 to Players.Count - 1 do
               Players[I].Pos := PointF(Players[I].Pos.X * WFact,
                 Players[I].Pos.Y * HFact);
         end;
      end;
   end;
   PrevWindowSize := Point(Self.Width, Self.Height);
   PrevStageSize := PointF(AGameScreen.imgBackg.Width,
     AGameScreen.imgBackg.Height);
end;

end.
