unit PVPTank;

interface

uses
   FMX.Types, Windows, Tank;

type
   TPVPTank = class(TTank)
   protected
      FGunControlKeys: TCArray;
   public
      constructor Create(pX, pY, pBodyAngle, pSpeed: Single; pColor: String;
        pScaleFacgor: Single; pID: Integer; Sender: TFmxObject);
      procedure GunAngleLogick; override;
      procedure ShootLogick; override;
   end;

implementation

uses
   FRoboWars, GameScreen, Model, Bullet;

constructor TPVPTank.Create(pX, pY, pBodyAngle, pSpeed: Single; pColor: String;
  pScaleFacgor: Single; pID: Integer; Sender: TFmxObject);
begin
   inherited Create(pX, pY, pBodyAngle, pSpeed, pColor, pScaleFacgor,
     pID, Sender);
   case pID of
      1:
         begin
            FControlKeys := TCArray.Create('W', 'A', 'S', 'D');
            FGunControlKeys := TCArray.Create('C', 'B', 'V');
         end;
      2:
         begin
            FControlKeys := TCArray.Create('I', 'J', 'K', 'L');
            FGunControlKeys := TCArray.Create(Chr(VK_NUMPAD7), Chr(VK_NUMPAD9),
              Chr(VK_NUMPAD8));
         end;
      else:
         begin
            FControlKeys := TCArray.Create('W', 'A', 'S', 'D');
            FGunControlKeys := TCArray.Create('C', 'B', 'V');
         end;
   end;
end;

procedure TPVPTank.GunAngleLogick;
begin
   if GetKeyState(Ord(FGunControlKeys[0])) < 0 then
      FGunAngle := FGunAngle - TANK_DELTA_GUN_ROT;
   if GetKeyState(Ord(FGunControlKeys[1])) < 0 then
      FGunAngle := FGunAngle + TANK_DELTA_GUN_ROT;
end;

procedure TPVPTank.ShootLogick;
begin
   if GetKeyState(Ord(FGunControlKeys[2])) < 0 then
      Shoot(3);
end;

end.
