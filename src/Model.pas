unit Model;

interface

uses Tank, EnemyTank, Bullet, Windows, FMX.Dialogs, System.Types,
   System.Generics.Collections, System.Classes, Controller, System.SysUtils,
   Ball, FMX.Forms, System.UITypes, FMX.MEDIA;

const
   MAX_CHILDS_CNT = 5;
   TANK_SCALE = 4.;
   MAX_CREATION_DEPTH = 2;
   PING_PONG_WIN_SCORE = 7;
   PVP_WIN_SCORE = 3;
   WIN_SCORES: array [0 .. 4] of Integer = (0, 1, 7, 3, 2);

type
   TActiveWindow = (awMainMenu, awPause, awDifficulty, awGame, awHelp);
   TGameState = (gsNone, gsCountDown, gsPlaying, gsGameOver);
   TGameMode = (gmNone, gm12MANY, gmPingPong, gmPVP, gmPvCOM);

   TModel = class
   private
   public
      FScore, PlayersCount: array [1 .. 3] of Integer;
      EnemyTargets: TList<Integer>;
      Bullets: TObjectList<TBullet>;
      Players: TObjectList<TTank>;
      Ball: TBall;
      FIsGameEnded, FIsRoundEnded: Boolean;
      FMousePos: TPointF;
      FShowDemo, FStopEnemies: Boolean;
      GameMode: TGameMode;
      GameState: TGameState;
      ActiveWindow: TActiveWindow;
      Constructor Create; overload;
      Destructor Destroy; overload;
      procedure StopGame;
      procedure SpawnChilds(pTank: TTank);
      procedure Draw;
      procedure NewGame(pGameMode: TGameMode);
      procedure PlayerLoose(pID: Integer);
      procedure DropTank(pID: Integer; pControlType: TControlType);
      procedure PopTank(pID: Integer);
      procedure ClearStage;
      procedure Update;
   end;

   TParticles = class(TThread)
   private
   protected
      procedure Execute; override;
      constructor Create(pDoNotLaunch: Boolean); overload;
   public
   end;

var
   AModel: TModel;
   Particles, Particles2: TParticles;

implementation

uses FRoboWars, GameScreen, CongratScreen, Menu, ScoreBoard,
   DifficultyScreen, MMSystem, SoundManager, PauseScreen;

constructor TModel.Create;
var
   MPlayer: TMediaPlayer;
begin
   inherited Create;
   FIsGameEnded := False;
   FStopEnemies := False;
   Players := TObjectList<TTank>.Create(False);
   Bullets := TObjectList<TBullet>.Create(False);
   EnemyTargets := TList<Integer>.Create;
   Particles := TParticles.Create(True);
   FShowDemo := False;
end;

procedure WaitKeyPress;
begin
   while not((GetKeyState(VK_SPACE) < 0) or (GetKeyState(VK_RETURN) < 0) and
     not(GetKeyState(VK_RCONTROL) < 0)) do
   begin
      Application.ProcessMessages;
      Sleep(50);
   end;
end;

function EnotherPlayerID(pN: Integer): Integer;
begin
   if AModel.GameMode = gmPvCOM then
   begin
      if pN = 1 then
         Result := 3
      else
         Result := 1;
   end
   else
      Result := 1 + pN mod 2;
end;

function EnotherPlayerName(pID: Integer): String;
begin
   if AModel.GameMode = gmPvCOM then
   begin
      if pID = 1 then
         Result := 'COM'
      else
         Result := '1';
   end
   else
      Result := IntToStr(EnotherPlayerID(pID));
end;

procedure TModel.PlayerLoose(pID: Integer);
begin
   FScore[EnotherPlayerID(pID)] := FScore[EnotherPlayerID(pID)] + 1;
   with ACongratScreen do
   begin
      case EnotherPlayerID(pID) of
         1:
            begin
               AScoreBoard.txP1.Text := IntToStr(FScore[1]);
               txCongrat.Color := TAlphaColors.Royalblue;
            end;
         2:
            begin
               AScoreBoard.txP2.Text := IntToStr(FScore[2]);
               txCongrat.Color := TAlphaColors.Red;
            end;
         3:
            begin
               AScoreBoard.txP2.Text := IntToStr(FScore[3]);
               txCongrat.Color := TAlphaColors.Red;
            end;
      end;
      if FScore[EnotherPlayerID(pID)] = WIN_SCORES[Ord(GameMode)] then
      begin
         txCongrat.Text := 'PLAYER ' + EnotherPlayerName(pID) + #13#10 + 'IS' +
           #13#10 + 'THE' + #13#10 + 'CHAPMION!!!';
         ASoundManager.PlaySound('winner');
         FIsGameEnded := True;
      end
      else
      begin
         txCongrat.Text := 'PLAYER ' + EnotherPlayerName(pID) + #13#10 + 'WINS';
         FIsRoundEnded := True;
      end;
      Visible := True;
      Application.ProcessMessages;
      WaitKeyPress;
      Visible := False;
   end;
end;

constructor TParticles.Create(pDoNotLaunch: Boolean);
begin
   inherited Create(pDoNotLaunch);
   Priority := TThreadPriority.tpHigher;
end;

procedure TParticles.Execute;
var
   I: Integer;
begin
   begin
      I := 0;
      with AModel do
      begin
         while I < Bullets.Count do
         begin
            if Assigned(Bullets[I]) then
            begin
               if not Bullets[I].FDestroyed then
               begin
                  Bullets[I].Update;
               end
               else
               begin
                  if not Bullets[I].FDrawing then
                  begin
                     Bullets[I].Destroy;
                     Bullets.Delete(I);
                     Dec(I);
                  end;
               end;
            end;
            Inc(I);
         end;
      end;
   end;
end;

destructor TModel.Destroy;
var
   I: Integer;
begin
   Particles.Terminate;
   for I := 0 to Players.Count - 1 do
      Players[I].Destroy;
   Players.Destroy;
   for I := 0 to Bullets.Count - 1 do
      Bullets[I].Destroy;
   Bullets.Destroy;
   inherited Destroy;
end;

procedure TModel.Draw;
var
   I: Integer;
begin
   MainForm.BeginUpdate;
   if FShowDemo then
      SetVisibilityOfDemoElements(True)
   else
      SetVisibilityOfDemoElements(False);
   I := 0;
   while I < Players.Count do
   begin
      if Assigned(Players[I]) then
         Players[I].Draw;
      Inc(I);
   end;
   I := 0;
   while I < Bullets.Count do
   begin
      if Assigned(Bullets[I]) then
         Bullets[I].Draw;
      Inc(I);
   end;
   case GameMode of
      gmPingPong:
         begin
            Ball.Draw;
         end;
   end;
   MainForm.EndUpdate;
end;

procedure TModel.PopTank(pID: Integer);
var
   I: Integer;
begin
   if PlayersCount[pID] > 0 then
      for I := Players.Count - 1 downto 0 do
         if Players[I].ID = pID then
         begin
            Dec(PlayersCount[Players[I].ID]);
            Players[I].Destroy;
            Players.Delete(I);
            Break;
         end;
end;

procedure TModel.SpawnChilds(pTank: TTank);
var
   I: Integer;
   R: Extended;
   ChildTank: TTank;
   toX, toY: Single;
   DeltaAng: Single;
begin
   DeltaAng := 360 / MAX_CHILDS_CNT;
   with pTank do
   begin
      R := BodyImg.Height / 2;
      for I := 1 to MAX_CHILDS_CNT do
      begin
         toX := Pos.X + R * COS(DeltaAng * I * PI / 180);
         toY := Pos.Y + R * SIN(DeltaAng * I * PI / 180);
         if IsInStageBounds(toX, toY) then
         begin
            ChildTank := TTank.Create(toX, toY, DeltaAng * I + 90, 0,
              IntToStr(ID), BodyScale * 1.6, ID, ctKeys, AGameScreen.lStage);
            ChildTank.CreationDepth := CreationDepth + 1;
            Players.Add(ChildTank);
            PlayersCount[ID] := PlayersCount[ID] + 1;
         end;
      end;
   end;
end;

procedure TModel.Update;
var
   I: Integer;
begin
   begin
      I := 0;
      with AModel do
      begin
         if FIsRoundEnded then
         begin
            FIsRoundEnded := False;
            ClearStage;
            NewGame(GameMode);
         end
         else if FIsGameEnded then
         begin
            StopGame;
            FIsGameEnded := False;
            AGameScreen.Visible := False;
            ADifficultyScreen.Visible := True;
         end
         else
         begin
            while I < Players.Count do
            begin
               if Assigned(Players[I]) then
               begin
                  if not Players[I].Destroyed then
                  begin
                     Players[I].Update;
                  end
                  else
                  begin
                     case GameMode of
                        gm12MANY:
                           begin
                              if Players[I].CreationDepth < MAX_CREATION_DEPTH
                              then
                              begin
                                 SpawnChilds(Players[I]);
                              end
                              else
                              begin
                                 if PlayersCount[Players[I].ID] = 1 then
                                    PlayerLoose(Players[I].ID);
                              end;
                           end;
                        gmPingPong:
                           begin
                              Ball.Destroyed := True;
                              PlayerLoose(Players[I].ID);
                           end;
                        gmPVP:
                           begin
                              PlayerLoose(Players[I].ID);
                           end;
                        gmPvCOM:
                           begin
                              PlayerLoose(Players[I].ID);
                           end;
                     end;
                     Dec(PlayersCount[Players[I].ID]);
                     Players[I].Destroy;
                     Players.Delete(I);
                     Dec(I);
                  end;
               end;
               Inc(I);
            end;
         end;
      end;
      case GameMode of
         gmPingPong:
            begin
               if Ball <> nil then
               begin
                  if not(Ball.Destroyed or FIsGameEnded) then
                     Ball.Update;
               end;
            end;
      end;
      Particles.Execute;
   end;
end;

procedure TModel.ClearStage;
var
   I: Integer;
begin
   for I := 0 to Players.Count - 1 do
      Players[I].Destroy;
   Players.Clear;
   for I := 0 to Bullets.Count - 1 do
      Bullets[I].Destroy;
   Bullets.Clear;
   case GameMode of
      gmPingPong:
         begin
            AScoreBoard.Visible := False;
            Ball.Destroy;
            Ball := nil;
         end;
   end;
end;

procedure TModel.StopGame;
begin
   ClearStage;
   FScore[1] := 0;
   FScore[2] := 0;
   FScore[3] := 0;
   AScoreBoard.ClearBoard;
   GameMode := gmNone;
   ActiveWindow := awDifficulty;
end;

procedure TModel.DropTank(pID: Integer; pControlType: TControlType);
var
   TempTank: TTank;
   RoundedW, RoundedH: Integer;
begin
   TempTank := nil;
   RoundedW := Round(AGameScreen.imgBackg.Width);
   RoundedH := Round(AGameScreen.imgBackg.Height);
   repeat
      if TempTank <> nil then
         FreeAndNil(TempTank);
      begin
         with AGameScreen do
            case pID of
               1, 2:
                  TempTank := TTank.Create(Random(RoundedW), Random(RoundedH),
                    0, 0, IntToStr(pID), TANK_SCALE, pID, pControlType, lStage);
               3:
                  TempTank := TEnemyTank.Create(Random(RoundedW),
                    Random(RoundedH), 0, 0, IntToStr(pID), TANK_SCALE, pID,
                    pControlType, lStage);
            end;
      end;
   until not TempTank.CheckCollisions;
   Players.Add(TempTank);
   PlayersCount[pID] := PlayersCount[pID] + 1;
end;

procedure TModel.NewGame(pGameMode: TGameMode);
begin
   MainForm.OnResize(Self);
   GameState := gsCountDown;
   GameMode := pGameMode;
   AGameScreen.Visible := True;
   ActiveWindow := awGame;
   with AGameScreen do
   begin
      case pGameMode of
         gmPingPong:
            begin
               Players.Add(TTank.Create(10, imgBackg.Height / 2, 0, 0, '1',
                 TANK_SCALE, 001, ctKeys, lStage));
               Players.Add(TTank.Create(imgBackg.Width, imgBackg.Height / 2, 0,
                 0, '2', TANK_SCALE, 002, ctKeys, lStage));
               Ball := TBall.Create(imgBackg.Width / 2, imgBackg.Height / 2, 3,
                 90, 1, lStage);
               AScoreBoard.Position.Point :=
                 PointF(imgBackg.Width / 2 - AScoreBoard.Width / 2, 0);
               AScoreBoard.Visible := True;
               PlayersCount[1] := 1;
               PlayersCount[2] := 1;
            end;
         gmPvCOM:
            begin
               DropTank(1, ctMouse);
               DropTank(3, ctNone);
               AScoreBoard.Position.Point :=
                 PointF(imgBackg.Width / 2 - AScoreBoard.Width / 2, 0);
               AScoreBoard.Visible := True;
            end;
         gmPVP:
            begin
               DropTank(1, ctKeys);
               DropTank(2, ctKeys);
               AScoreBoard.Position.Point :=
                 PointF(imgBackg.Width / 2 - AScoreBoard.Width / 2, 0);
               AScoreBoard.Visible := True;
            end;
         gm12MANY:
            begin
               DropTank(1, ctKeys);
               DropTank(2, ctKeys);
               AScoreBoard.Position.Point :=
                 PointF(imgBackg.Width / 2 - AScoreBoard.Width / 2, 0);
               AScoreBoard.Visible := True;
            end;
      end;
   end;
   AController.Timer.Resume;
end;

end.
