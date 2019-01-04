unit P2Tank;

interface

uses
   FMX.Types, Windows, Tank;

type
   TP2Tank = class(TPVPTank)
   protected
   public
      constructor Create(pX, pY, pBodyAngle, pSpeed: Single; pColor: String;
        pID: Integer; pMode: TTankMode; Sender: TFmxObject); override;
   end;

implementation

uses
   FRoboWars, GameScreen, Model, Bullet;

constructor TP2Tank.Create(pX, pY, pBodyAngle, pSpeed: Single; pColor: String;
  pID: Integer; pMode: TTankMode; Sender: TFmxObject);
begin
   inherited Create(pX, pY, pBodyAngle, pSpeed, pColor, pID, pMode, Sender);
   FControlKeys := TCArray.Create('I', 'J', 'K', 'L');
   // FControlKeys := TCArray.Create(Chr(VK_NUMPAD8), Chr(VK_NUMPAD4), Chr(VK_NUMPAD5),
   // Chr(VK_NUMPAD6));

   // FGunControlKeys := TCArray.Create('I', 'P', 'O');
   FGunControlKeys := TCArray.Create(Chr(VK_NUMPAD7), Chr(VK_NUMPAD9),
     Chr(VK_NUMPAD8));
end;

end.
