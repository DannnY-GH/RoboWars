unit EnemyTank;

interface

uses
   FMX.Objects, FMX.Ani, FMX.Types, FMX.Graphics, SysUtils, System.Types,
   System.Classes, Windows, System.Math, Tank;

const
   ENEMY_BULLET_POWER = 1;
   OPTIMAL_DIST = 250;

type
   TMoveDirection = (drUp = 1, drDowm = -1, drLeft, drRifht, drNone);

   TEnemyTank = class(TTank)
   protected
      FMoveDirection: TMoveDirection;
   public
      constructor Create(pX, pY, pBodyAngle, pSpeed: Single; pColor: String;
        pScaleFactor: Single; pID: Integer; pControlType: TControlType;
        Sender: TFmxObject); override;
      procedure GunAngleLogick; override;
      procedure MoveLogick; override;
      procedure Update; override;
      function GetCircleShootDirection(AimTank: TTank): TPointF;
      function GetLinearShootDirection(AimTank: TTank): TPointF;
   end;

procedure SetVisibilityOfDemoElements(pV: Boolean);

implementation

uses
   FRoboWars, GameScreen, Model, Bullet, MUtils;

constructor TEnemyTank.Create(pX, pY, pBodyAngle, pSpeed: Single;
  pColor: String; pScaleFactor: Single; pID: Integer;
  pControlType: TControlType; Sender: TFmxObject);
begin
   inherited Create(pX, pY, pBodyAngle, pSpeed, pColor, pScaleFactor, pID,
     pControlType, Sender);
   FMoveDirection := drUp;
end;

function CCW(Ang1, Ang2: Single): Boolean;
begin
   Result := COS(DegToRad(Ang2)) * SIN(DegToRad(Ang1)) - SIN(DegToRad(Ang2)) *
     COS(DegToRad(Ang1)) > 0;
end;

procedure TEnemyTank.MoveLogick;
var
   I: Integer;
   Dist: TPointF;
   DistMod, Ang: Single;
   Found: Boolean;
begin
   with AModel do
   begin
      Found := False;
      for I := 0 to Players.Count - 1 do
      begin
         if not((ClassName = 'TEnemyTank') or Found) then
         begin
            Found := True;
            with Players[I] do
            begin
               Dist := PointF(Pos.X - Self.Pos.X, Pos.Y - Self.Pos.Y);
               DistMod := Sqrt(Sqr(Dist.X) + Sqr(Dist.Y));
               Ang := RadToDeg(ArcCos(Dist.X / DistMod));
               if Pos.Y < Self.Pos.Y then
                  Ang := -Ang;
            end;
            begin
               if not(Abs(DistMod - OPTIMAL_DIST) < 10) then
                  if DistMod > OPTIMAL_DIST then
                     Ang := Ang + 45 * Ord(FMoveDirection)
                  else
                     Ang := Ang - 45 * Ord(FMoveDirection);
               if CCW(Ang, BodyAngle) then
                  FBodyAngle := FBodyAngle + TANK_DELTA_ROT
               else
                  FBodyAngle := FBodyAngle - TANK_DELTA_ROT;
            end;
         end;
      end;
   end;
   case FMoveDirection of
      drUp:
         IncSpeed;
      drDowm:
         DecSpeed;
   end;
   if CheckCollisions then
      FMoveDirection := TMoveDirection(-Ord(FMoveDirection));
end;

function TEnemyTank.GetLinearShootDirection(AimTank: TTank): TPointF;
var
   Xt, Yt, Vt, Vxt, Vyt, r0x, r0y: Extended;
   A, B, C, D: Extended;
   T: Extended;
   X, Y: Extended;
begin
   with AimTank do
   begin
      Xt := Pos.X;
      Yt := Pos.Y;
      r0x := (Xt - Self.Pos.X);
      r0y := (Yt - Self.Pos.Y);
      Vxt := Speed * COS((BodyAngle - 90) * PI / 180);
      Vyt := Speed * SIN((BodyAngle - 90) * PI / 180);
      Vt := Speed;

      A := Sqr(TANK_BULLET_SPEED) + Sqr(Vt);
      B := -2 * (r0x * Vxt + r0y * Vyt);
      C := -(Sqr(r0x) + Sqr(r0y));
      D := Sqr(B) - 4 * A * C;

      T := (-B + Sqrt(D)) / (2 * A);
      X := Xt + Vxt * (T);
      Y := Yt + Vyt * (T);
      with AGameScreen.c1 do
      begin
         Position.Point := PointF(X - Width / 2, Y - Height / 2);
         AGameScreen.c2.Position := Position;
      end;
      Result := PointF(X - Self.Pos.X, Y - Self.Pos.Y)
   end;
end;

function TEnemyTank.GetCircleShootDirection(AimTank: TTank): TPointF;
var
   Xt, Yt, Vt, Vb, r0x, r0y, Rx, Ry: Extended;
   A, B, C, D, F, G: Extended;
   T1, T2: Extended;
   X, Y: Extended;
   R, OMEGA, FI, realT1, realT2: Extended;
   M: TPointF;
   MVect1, MVect2: TPointF;

   function GetDirection(pT: Extended; var realT: Extended;
     RootN: Byte): TPointF;
   begin
      with AimTank do
      begin
         if Rotor = trCW then
         begin
            FI := (BodyAngle - 180) * PI / 180 + OMEGA * pT
         end
         else
         begin
            FI := (BodyAngle) * PI / 180 + -OMEGA * pT;
         end;
         M := PointF(Pos.X + R * COS(FI) + Rx, Pos.Y + R * SIN(FI) + Ry);
         Result := PointF(M.X - Self.Pos.X, M.Y - Self.Pos.Y);
         with Result do
            realT := (Sqrt(Sqr(X) + Sqr(Y)) / Vb);

         // DEMO
         if RootN = 1 then
            with AGameScreen.c1 do
               Position.Point := PointF(M.X - Width / 2, M.Y - Height / 2)
         else
            with AGameScreen.c2 do
               Position.Point := PointF(M.X - Width / 2, M.Y - Height / 2);
         // DEMO
      end;
   end;

begin
   with AimTank do
   begin
      Xt := Pos.X;
      Yt := Pos.Y;
      Vb := TANK_BULLET_SPEED;
      Vt := Speed;
      r0x := (Xt - Self.Pos.X);
      r0y := (Yt - Self.Pos.Y);
      OMEGA := (TANK_DELTA_ROT * PI) / 180;
      R := Vt / OMEGA;

      if Rotor = trCW then
      begin
         Rx := R * COS(BodyAngle * PI / 180);
         Ry := R * SIN(BodyAngle * PI / 180);
      end
      else
      begin
         Rx := R * COS((BodyAngle - 180) * PI / 180);
         Ry := R * SIN((BodyAngle - 180) * PI / 180);
      end;

      F := Sqr(r0x) + Sqr(r0y) + Sqr(R) + 2 * (r0x * Rx + r0y * Ry);
      G := F + Sqr(R);
      A := Sqr(Sqr(Vb));
      B := -2 * Sqr(Vb) * G;
      C := Sqr(G) - 4 * F * Sqr(R);
      D := Sqr(B) - 4 * A * C;

      T1 := Sqrt((-B + Sqrt(D)) / (2 * A));
      T2 := Sqrt((-B - Sqrt(D)) / (2 * A));
      MVect1 := GetDirection(T1, realT1, 1);
      MVect2 := GetDirection(T2, realT2, 2);

      if Abs(T1 - realT1) < Abs(T2 - realT2) then
         Result := MVect1
      else
         Result := MVect2;

      // DEMO
      X := Pos.X + Rx - R;
      Y := Pos.Y + Ry - R;
      with AGameScreen.cR do
      begin
         Width := R * 2;
         Height := R * 2;
         Position.Point := PointF(X, Y);
      end;
      // DEMO
   end;
end;

procedure SetVisibilityOfDemoElements(pV: Boolean);
begin
   with AGameScreen do
   begin
      cR.Visible := pV;
      c2.Visible := pV;
      c1.Visible := pV;
   end;
end;

procedure HideCircleMoveElements;
begin
   with AGameScreen do
   begin
      c1.Visible := False;
      cR.Visible := False;
   end;
end;

procedure TEnemyTank.GunAngleLogick;
var
   VectCos: Single;
   I, MinIndex, UnderControlAmnt: Integer;
   FMouseVec: TPointF;
begin
   with AModel do
   begin
      for I := 0 to Players.Count - 1 do
      begin
         if not(Players[I].ClassName = 'TEnemyTank') then
         begin
            with Players[I] do
            begin
               if Rotor = trNone then
               begin
                  AGameScreen.cR.Width := 0;
                  AGameScreen.cR.Height := 0;
                  FMouseVec := GetLinearShootDirection(Players[I])
               end
               else
               begin
                  FMouseVec := GetCircleShootDirection(Players[I]);
               end;
            end;
            break;
         end;
      end;
      with FMouseVec do
      begin
         VectCos := Y / Sqrt(X * X + Y * Y);
         FGunAngle := ArcCos(VectCos) / PI * 180;
         FGunAngle := FGunAngle + 180;
         if FMouseVec.X > 0 then
            FGunAngle := -FGunAngle;
      end;
   end;
end;

procedure TEnemyTank.Update;
begin
   GunAngleLogick;
   Shoot(ENEMY_BULLET_POWER);
   StartCoolDownTimer;
   if not AModel.FStopEnemies then
      MoveLogick;
   with FHPRect do
   begin
      Width := (BodyImg.Width - TANK_HP_MARG * 2) / 100 * FHP;
   end;
end;

end.
