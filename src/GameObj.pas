unit GameObj;

interface

uses
  FRoboWars, FMX.Objects, FMX.Ani, FMX.Types, FMX.Graphics, SysUtils, System.Types,
  System.Classes;

type
  TGameObj = class
  private
    fPosition: TPointF;
    FImage: TImage;
    fDestroyed: Boolean;
  public
    Constructor Create; overload;
    Destructor Destroy; overload;
    //Constructor Create(pX, pY, pAngle, pSpeed: Single); overload;
    //procedure SetPosition(pPosition: TPointF);
    //procedure Update; virtual; abstract;
    //property Destroyed: Boolean read fDestroyed;
    //property Position: TPointF read fPosition write SetPosition;
  end;

implementation

constructor TGameObj.Create;
begin
  inherited Create;
end;

destructor TGameObj.Destroy;
begin
   inherited Destroy;
end;

end.
