unit Bullet;

interface

uses
   FMX.Objects, FMX.Dialogs, FMX.Ani, FMX.Types, FMX.Graphics, SysUtils,
   System.Types,
   System.Classes, Windows, System.Math;

const
   DEATH_TIME = 1000;
   // DAMAGE_VAL = 1;

type
   TBulletState = (bsFly, bsBang);

   TBullet = class(TComponent)
   private
      FBulletState: TBulletState;
      FBodyImg: TImage;
      FBangAni: TBitmapListAnimation;
      FPos, FVelocity: TPointF;
      FOwnerID: Integer;
      FLifeTime: Integer;
      FDamageAmount: Integer;

   public
      FDestroyed, FDrawing: Boolean;
      Constructor Create; overload;
      constructor Create(pX, pY, pGunAngle, pSpeed: Single;
        pPower, pID: Integer; Sender: TFmxObject); overload;
      Destructor Destroy; overload;
      procedure Draw;
      procedure FreeBullet(Sender: TObject);
      procedure CheckCollisions;
      procedure Update;
      procedure Bang;
   end;

implementation

uses
   FRoboWars, GameScreen, Model, Tank,SoundManager;

constructor TBullet.Create;
begin
   inherited Create(Self);
end;

constructor TBullet.Create(pX, pY, pGunAngle, pSpeed: Single;
  pPower, pID: Integer; Sender: TFmxObject);
begin
   inherited Create(Sender);
   FOwnerID := pID;
   FLifeTime := 0;
   FBulletState := bsFly;
   FPos := PointF(pX, pY);
   FVelocity := PointF(pSpeed * COS((pGunAngle - 90) * PI / 180),
     pSpeed * SIN((pGunAngle - 90) * PI / 180));
   FDestroyed := False;
   FBodyImg := TImage.Create(Self);
   FDamageAmount := pPower;
   with FBodyImg do
   begin
      Parent := Sender;
      Bitmap.LoadFromFile('assets\bullet.png');
      WrapMode := TImageWrapMode.Fit;
      RotationAngle := pGunAngle;
      FBodyImg.Width := Bitmap.Width / 3;
      FBodyImg.Height := Bitmap.Height / 3;
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
      OnFinish := FreeBullet;
   end;
   FDrawing := False;
end;

destructor TBullet.Destroy;
begin
   FreeAndNil(FBodyImg);
   inherited Destroy;
end;

procedure TBullet.Bang;
begin
   FBulletState := bsBang;
   with FBodyImg do
   begin
      Bitmap.Clear(0);
      Width := Width * 4;
      Height := Height * 4;
   end;
end;

procedure TBullet.CheckCollisions;
const
   COEF = 20;
var
   BulletRect, AimRect, ResRect: TRectF;
   i: Integer;
begin
   BulletRect := RectF(FPos.X - FBodyImg.Width / 2, FPos.Y - FBodyImg.Height /
     2, FPos.X + FBodyImg.Width / 2, FPos.Y + FBodyImg.Width / 2);
   with AModel do
   begin
      for i := 0 to Players.Count - 1 do
      begin
         with Players[i] do
            AimRect := RectF(Pos.X - BodyImg.Width / 2, Pos.Y - BodyImg.Height /
              2 + COEF, Pos.X + BodyImg.Width / 2, Pos.Y + BodyImg.Height /
              2 - COEF);
         if System.Types.IntersectRectF(ResRect, BulletRect, AimRect) and
           (FOwnerID <> Players[i].ID) then
         begin
            Bang;
            ASoundManager.PlaySound('bodyhit');
            Players[i].Damage(FDamageAmount);
            Break;
         end;
      end;
   end;
   if not IsInStageBounds(FPos.X, FPos.Y) then
      Bang;
end;

procedure TBullet.Update;
begin
   Inc(FLifeTime);
   if FLifeTime = DEATH_TIME then
      FDestroyed := True
   else
   begin
      if FBulletState <> bsBang then
         CheckCollisions;
      if FBulletState = bsFly then
      begin
         FPos := PointF(FPos.X + FVelocity.X, FPos.Y + FVelocity.Y)
      end;
      // BulletR := TRectF(FPos.X, FPos.Y);
   end;
end;

procedure TBullet.Draw;
begin
   FDrawing := True;
   FBodyImg.Position.Point := PointF(FPos.X - FBodyImg.Width / 2,
     FPos.Y - FBodyImg.Height / 2);
   if FBulletState = bsBang then
   begin
      FBangAni.Enabled := True;
   end;
   FDrawing := False;
end;

procedure TBullet.FreeBullet(Sender: TObject);
begin
   FDestroyed := True;
end;

end.
