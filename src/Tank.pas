unit Tank;

interface

uses
   FMX.Objects, FMX.Ani, FMX.Types, FMX.Graphics, SysUtils, System.Types,
   System.Classes, Windows, System.Math, System.UITypes;

const
   TANK_DELTA_SPEED = 0.1;
   TANK_DELTA_ROT = 0.8 * 2;
   TANK_DELTA_GUN_ROT = 1.5;
   TANK_MAX_SPEED = 3.0;
   TANK_MIN_SPEED = -TANK_MAX_SPEED;
   TANK_COOLDOWN_TICS = 30;
   TANK_BULLET_SPEED = TANK_MAX_SPEED * 3;
   TANK_BULLET_POWER = 5;
   TANK_HP_MARG = 3;

type
   TCharArray = array of Char;
   TTankMode = (mdMouseTrack, mdPVP, mdPingPong, mdEnemy);
   TTankRotor = (trCCW, trCW, trNone);
   TControlType = (ctMouse, ctKeys, ctNone);

   TTank = class(TComponent)
   protected
      FHPRect, FHPBack: TRectangle;
      FControlKeys: TCharArray;
      FGunControlKeys: TCharArray;
      FControlType: TControlType;
      FGunAngle, FBodyAngle: Single;
      FSpeed: Single;
      FGunAni, FBangAni: TBitmapListAnimation;
      FCoolDownTics: Integer;
      FReadyForShoot: Boolean;
      FMousePos: TPoint;
      FDestroyed: Boolean;
      FDead: Boolean;
      FHP: Integer;
      FBodyImg, FGunImg: TImage;
      FBodyScale: Single;
      FID: Integer;
      FTankRotor: TTankRotor;
      FPos, FVelocity: TPointF;
      procedure IncSpeed;
      procedure DecSpeed;
   public
      CreationDepth: Byte;
      procedure SetPos(pPos: TPointF);
      property Destroyed: Boolean read FDestroyed;
      property ControlType: TControlType read FControlType write FControlType;
      property BodyImg: TImage read FBodyImg;
      property Pos: TPointF read FPos write SetPos;
      property Rotor: TTankRotor read FTankRotor;
      property Speed: Single read FSpeed;
      property BodyAngle: Single read FBodyAngle;
      property BodyScale: Single read FBodyScale;
      property ID: Integer read FID;
      constructor Create(pX, pY, pBodyAngle, pSpeed: Single; pColor: String;
        pScaleFactor: Single; pID: Integer; pControlType: TControlType;
        Sender: TFmxObject); overload; virtual;
      procedure Shoot(Power: Integer);
      Destructor Destroy; overload;
      procedure Draw;
      procedure Damage(pAmount: Integer);
      procedure StartCoolDownTimer;
      procedure MoveLogick; virtual;
      procedure GunAngleLogick; virtual;
      procedure ShootLogick; virtual;
      procedure Update; virtual;
      procedure SetAngleFromMouse;
      procedure SetAngleFromKeys;
      procedure FreeTank(Sender: TObject);
      function CheckCollisions: Boolean;
   end;

function IsInStageBounds(toX, toY: Single): Boolean;
procedure NormalizeAngle(var pAng: Single);

implementation

uses
   FRoboWars, GameScreen, Model, Bullet, SoundManager;

constructor TTank.Create(pX, pY, pBodyAngle, pSpeed: Single; pColor: String;
  pScaleFactor: Single; pID: Integer; pControlType: TControlType;
  Sender: TFmxObject);
begin
   inherited Create(Sender);
   FID := pID;
   FHP := 100;
   FDead := False;
   FTankRotor := trNone;
   FControlType := pControlType;
   CreationDepth := 1;
   case pID of
      1:
         begin
            FControlKeys := TCharArray.Create('W', 'A', 'S', 'D');
            FGunControlKeys := TCharArray.Create('V', 'N', 'B');
         end;
      2:
         begin
            FControlKeys := TCharArray.Create('I', 'J', 'K', 'L');
            FGunControlKeys := TCharArray.Create(Chr(VK_LEFT), Chr(VK_RIGHT),
              Chr(VK_DOWN));
         end;
   end;
   FCoolDownTics := 0;
   FReadyForShoot := True;
   FBodyScale := pScaleFactor;
   FPos := PointF(pX, pY);
   FVelocity := PointF(0, 0);
   FBodyAngle := pBodyAngle;
   FGunAngle := pBodyAngle;
   FSpeed := pSpeed;
   FDestroyed := False;
   FBodyImg := TImage.Create(Self);
   with FBodyImg do
   begin
      Parent := Sender;
      Bitmap.LoadFromFile('assets\' + pColor + 'body.png');
      WrapMode := TImageWrapMode.Fit;
      RotationAngle := pBodyAngle;
      FBodyImg.Width := Bitmap.Width / pScaleFactor;
      FBodyImg.Height := Bitmap.Height / pScaleFactor;
   end;
   FGunImg := TImage.Create(Self);
   with FGunImg do
   begin
      Parent := Sender;
      Bitmap.LoadFromFile('assets\' + pColor + 'gun.png');
      WrapMode := TImageWrapMode.Fit;
      RotationAngle := pBodyAngle;
      FGunImg.Width := Bitmap.Width / pScaleFactor;
      FGunImg.Height := Bitmap.Height / pScaleFactor;
   end;
   FBangAni := TBitmapListAnimation.Create(FBodyImg);
   with FBangAni do
   begin
      Parent := FBodyImg;
      AnimationBitmap.LoadFromFile('assets\bang.png');
      PropertyName := 'Bitmap';
      AnimationCount := 12;
      AnimationRowCount := 1;
      Duration := 0.5;
      Delay := 0;
      Loop := False;
      OnFinish := FreeTank;
   end;
   FHPBack := TRectangle.Create(Self);
   with FHPBack do
   begin
      Parent := Sender;
      Fill.Color := TAlphaColors.Red;
      Width := FBodyImg.Width - TANK_HP_MARG * 2;
      Stroke.Thickness := 0.5;
      Height := BodyImg.Width / 8;
   end;
   FHPRect := TRectangle.Create(Self);
   with FHPRect do
   begin
      Parent := Sender;
      Fill.Color := TAlphaColors.Chartreuse;
      Width := FBodyImg.Width - TANK_HP_MARG * 2;
      Stroke.Color := TAlphaColors.Null;
      Height := BodyImg.Width / 8;
   end;
end;

procedure TTank.SetPos(pPos: TPointF);
begin
   FPos := pPos;
end;

destructor TTank.Destroy;
begin
   inherited Destroy;
end;

procedure TTank.ShootLogick;
begin
   case FControlType of
      ctMouse:
         if GetKeyState(VK_LBUTTON) < 0 then
            Shoot(TANK_BULLET_POWER);
      ctKeys:
         if GetKeyState(Ord(FGunControlKeys[2])) < 0 then
            Shoot(TANK_BULLET_POWER);
   end;
   StartCoolDownTimer;
end;

procedure TTank.SetAngleFromMouse;
var
   VectCos: Single;
   MouseVec: TPointF;
begin
   with AModel do
      MouseVec := PointF(FMousePos.X - FPos.X, FMousePos.Y - FPos.Y);
   with MouseVec do
   begin
      VectCos := Y / sqrt(X * X + Y * Y);
      FGunAngle := ArcCos(VectCos) / PI * 180;
      FGunAngle := 180 - FGunAngle;
      if MouseVec.X < 0 then
         FGunAngle := -FGunAngle;
   end;
end;

procedure TTank.SetAngleFromKeys;
begin
   if GetKeyState(Ord(FGunControlKeys[Ord(trCCW)])) < 0 then
      FGunAngle := FGunAngle - TANK_DELTA_GUN_ROT;
   if GetKeyState(Ord(FGunControlKeys[Ord(trCW)])) < 0 then
      FGunAngle := FGunAngle + TANK_DELTA_GUN_ROT;
end;

procedure TTank.GunAngleLogick;
begin
   case FControlType of
      ctMouse:
         SetAngleFromMouse;
      ctKeys:
         SetAngleFromKeys;
   end;
end;

procedure TTank.IncSpeed;
begin
   if FSpeed + TANK_DELTA_SPEED < TANK_MAX_SPEED then
      FSpeed := FSpeed + TANK_DELTA_SPEED
   else
      FSpeed := TANK_MAX_SPEED;
end;

procedure TTank.DecSpeed;
begin
   if FSpeed - TANK_DELTA_SPEED > TANK_MIN_SPEED then
      FSpeed := FSpeed - TANK_DELTA_SPEED
   else
      FSpeed := TANK_MIN_SPEED;
end;

procedure NormalizeAngle(var pAng: Single);
begin
   if pAng > 360 then
      pAng := pAng - 360;
   if pAng < -360 then
      pAng := pAng + 360;
end;

procedure MakePositiveAnglee(var pAng: Single);
begin
   if pAng < 0 then
      pAng := pAng + 360;
end;

procedure TTank.MoveLogick;
begin
   FTankRotor := trNone;
   if AModel.GameMode <> gmPingPong then
   begin
      if GetKeyState(Ord(FControlKeys[1])) < 0 then
      begin
         FBodyAngle := FBodyAngle - TANK_DELTA_ROT;
         FTankRotor := trCCW;
      end;
      if GetKeyState(Ord(FControlKeys[3])) < 0 then
      begin
         FBodyAngle := FBodyAngle + TANK_DELTA_ROT;
         FTankRotor := trCW;
      end;
      NormalizeAngle(FBodyAngle);
   end;
   if GetKeyState(Ord(FControlKeys[0])) < 0 then
      IncSpeed
   else if GetKeyState(Ord(FControlKeys[2])) < 0 then
      DecSpeed
   else
   begin
      if Abs(FSpeed) < 0.1 then
         FSpeed := 0
      else
      begin
         if FSpeed > 0 then
            FSpeed := FSpeed - TANK_DELTA_SPEED / 2;
         if FSpeed < 0 then
            FSpeed := FSpeed + TANK_DELTA_SPEED / 2
      end;
   end;
   CheckCollisions;
end;

function IsInStageBounds(toX, toY: Single): Boolean;
begin
   with AGameScreen.imgBackg do
      Result := (toX >= 0) and (toX <= Width) and (toY >= 0) and
        (toY <= Height);
end;

function TTank.CheckCollisions: Boolean;
const
   COEF = 20;
var
   SelfRect, AimRect, ResRect: TRectF;
   i: Integer;
   toX, toY: Single;
begin
   Result := False;
   toX := FPos.X + FSpeed * COS((FBodyAngle - 90) * PI / 180);
   toY := FPos.Y + FSpeed * SIN((FBodyAngle - 90) * PI / 180);
   SelfRect := RectF(toX - FBodyImg.Width / 2, toY - FBodyImg.Height / 2,
     toX + FBodyImg.Width / 2, toY + FBodyImg.Width / 2);
   if IsInStageBounds(toX, toY) then
   begin
      with AModel do
      begin
         for i := 0 to Players.Count - 1 do
         begin
            with Players[i] do
               AimRect := RectF(FPos.X - FBodyImg.Width / 2,
                 FPos.Y - FBodyImg.Height / 2 + COEF, FPos.X + FBodyImg.Width /
                 2, FPos.Y + FBodyImg.Height / 2 - COEF);
            if System.Types.IntersectRectF(ResRect, SelfRect, AimRect) and
              (Players[i] <> Self) then
            begin
               Result := True;
               FSpeed := 0;
               Exit;
            end;
         end;
      end;
      FPos := PointF(toX, toY);
   end
   else
   begin
      Result := True;
      FSpeed := 0;
   end;
end;

procedure TTank.Update;
begin
   if not FDead then
   begin
      GunAngleLogick;
      ShootLogick;
      MoveLogick;
      with FHPRect do
      begin
         Width := (BodyImg.Width - TANK_HP_MARG * 2) / 100 * FHP;
      end;
   end;
end;

procedure TTank.Shoot(Power: Integer);
var
   BulletX, BulletY: Single;
begin
   if FReadyForShoot then
   begin
      FReadyForShoot := False;
      BulletX := FPos.X + FGunImg.Height / 2 * COS((FGunAngle - 90) * PI / 180);
      BulletY := FPos.Y + FGunImg.Height / 2 * SIN((FGunAngle - 90) * PI / 180);
      AModel.Bullets.Add(TBullet.Create(BulletX, BulletY, FGunAngle,
        TANK_BULLET_SPEED, Power, FID, AGameScreen.lStage));
      ASoundManager.PlaySound('shot');
   end;
end;

procedure TTank.StartCoolDownTimer;
begin
   if not FReadyForShoot then
   begin
      Inc(FCoolDownTics);
      if FCoolDownTics = TANK_COOLDOWN_TICS then
      begin
         FReadyForShoot := True;
         FCoolDownTics := 0;
      end;
   end;
end;

procedure TTank.Draw;
var
   HPPos: TPointF;
begin
   FBodyImg.Position.Point := PointF(FPos.X - FBodyImg.Width / 2,
     FPos.Y - FBodyImg.Height / 2);
   FBodyImg.RotationAngle := FBodyAngle;
   FGunImg.Position.Point := PointF(FPos.X - FBodyImg.Width / 2,
     FPos.Y - FBodyImg.Height / 2);
   FGunImg.RotationAngle := FGunAngle;
   HPPos := PointF(Pos.X - FBodyImg.Width / 2 + TANK_HP_MARG,
     Pos.Y - BodyImg.Height / 2 - 15);
   FHPRect.Position.Point := HPPos;
   FHPBack.Position.Point := HPPos;
end;

procedure TTank.Damage(pAmount: Integer);
begin
   FHP := FHP - pAmount;
   if (FHP <= 0) and (not FDead) then
   begin
      FDead := True;
      ASoundManager.PlaySound('boom');
      FHPRect.Visible := False;
      FHPBack.Visible := False;
      FGunImg.Visible := False;
      FBodyImg.Width := FBodyImg.Width * 3;
      FBodyImg.Height := FBodyImg.Height * 3;
      FBangAni.Enabled := True;
   end;
end;

procedure TTank.FreeTank(Sender: TObject);
begin
   FDestroyed := True;
end;

end.
