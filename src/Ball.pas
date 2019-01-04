unit Ball;

interface

uses
   FMX.Objects, FMX.Ani, FMX.Types, FMX.Graphics, SysUtils, System.Types,
   System.Classes, Windows, System.Math;

const
   BALL_DELTA_SPEED = 0.1;
   MAX_ANG = 75;

type
   TBall = class(TComponent)
   private
      FBodyImg: TImage;
      FPos, FVelocity: TPointF;
      FBodyAngle, FSpeed: Single;
      FDestroyed: Boolean;
   public
      procedure SetPos(pPos: TPointF);
      constructor Create(pX, pY, pSpeed, pAngle, pScaleFactor: Single;
        Sender: TFmxObject); overload;
      destructor Destroy; overload;
      procedure Draw;
      procedure Update;
      function GetNewVelocity(pBoard: TPointF): TPointF;
      function CheckCollisions: Boolean;
      property Destroyed: Boolean read FDestroyed write FDestroyed;
      property Pos: TPointF read FPos write SetPos;
   end;

implementation

uses
   Tank, Model, FRoboWars, GameScreen, SoundManager;

constructor TBall.Create(pX, pY, pSpeed, pAngle, pScaleFactor: Single;
  Sender: TFmxObject);
begin
   inherited Create(Sender);
   FBodyImg := TImage.Create(Self);
   with FBodyImg do
   begin
      Parent := Sender;
      FPos := PointF(pX, pY);
      FSpeed := pSpeed;
      FVelocity := PointF(pSpeed * COS(GradToRad(pAngle - 90)),
        pSpeed * Sin(GradToRad(pAngle - 90)));
      FBodyAngle := pAngle;
      Bitmap.LoadFromFile('assets\ball.png');
      WrapMode := TImageWrapMode.Fit;
      FBodyImg.Width := Bitmap.Width / pScaleFactor;
      FBodyImg.Height := Bitmap.Height / pScaleFactor;
   end;
   FDestroyed := False;
end;

destructor TBall.Destroy;
begin
   FreeAndNil(FBodyImg);
   inherited Destroy;
end;

procedure TBall.Draw;
begin
   with FBodyImg do
      Position.Point := PointF(FPos.X - Width / 2, FPos.Y - Height / 2);
end;

procedure TBall.SetPos(pPos: TPointF);
begin
   FPos := pPos;
end;

function TBall.GetNewVelocity(pBoard: TPointF): TPointF;
var
   dY, ndY: Single;
begin
   dY := FPos.Y - pBoard.Y;
   ndY := dY / AModel.Players[0].BodyImg.Height / 2;
   if FVelocity.X < 0 then
      Result := PointF(FSpeed * COS(GradToRad(MAX_ANG * ndY)),
        FSpeed * Sin(GradToRad(MAX_ANG * ndY)))
   else
      Result := PointF(-FSpeed * COS(GradToRad(MAX_ANG * ndY)),
        FSpeed * Sin(GradToRad(MAX_ANG * ndY)))
end;

function TBall.CheckCollisions: Boolean;
const
   COEF = 20;
var
   SelfRect, AimRect, ResRect: TRectF;
   i: Integer;
   toX, toY: Single;
begin
   Result := False;
   toX := FPos.X + FVelocity.X;
   toY := FPos.Y + FVelocity.Y;
   SelfRect := RectF(toX - FBodyImg.Width / 2, toY - FBodyImg.Height / 2,
     toX + FBodyImg.Width / 2, toY + FBodyImg.Height / 2);
   if IsInStageBounds(toX, toY) then
   begin
      with AModel do
      begin
         for i := 0 to Players.Count - 1 do
         begin
            with Players[i] do
            begin
               AimRect := RectF(Pos.X - BodyImg.Width / 2,
                 Pos.Y - BodyImg.Height / 2 + COEF, Pos.X + BodyImg.Width / 2,
                 Pos.Y + BodyImg.Height / 2 - COEF);
               if System.Types.IntersectRectF(ResRect, SelfRect, AimRect) then
               begin
                  Result := True;
                  if ID = 1 then
                  begin
                     toX := Pos.X + FBodyImg.Width / 2 + BodyImg.Width / 2;
                     ASoundManager.PlaySound('ping');
                  end
                  else
                  begin
                     toX := Pos.X - FBodyImg.Width / 2 - BodyImg.Width / 2;
                     ASoundManager.PlaySound('pong');
                  end;
                  FVelocity := GetNewVelocity(Pos);
               end;
            end;
         end;
      end;
   end
   else
   begin
      Result := True;
      with AGameScreen.imgBackg do
      begin
         if (toY < 0) or (toY > Height) then
         begin
            FVelocity := PointF(FVelocity.X, -FVelocity.Y);
            ASoundManager.PlaySound('pingwall');
         end
         else
         begin
            FDestroyed := True;
            ASoundManager.PlaySound('pinglose');
            if (toX - Self.FBodyImg.Width < 0) then
            begin
               AModel.PlayerLoose(1);
            end
            else
            begin
               AModel.PlayerLoose(2);
            end;
         end;
      end;
   end;
   FPos := PointF(toX, toY);
end;

procedure TBall.Update;
begin
   if CheckCollisions then
      FSpeed := FSpeed + BALL_DELTA_SPEED;
end;

end.
