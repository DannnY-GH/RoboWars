unit FPSTimer;

interface

uses Timer, System.Types, System.SysUtils;

type
   TFPSTimer = class(TMTimer)
   public
      constructor Create;
      procedure OnTimer;
   end;

implementation

uses FRoboWars;

constructor TFPSTimer.Create;
begin
   inherited Create;
   Self.FDelay := 1000;
end;

procedure TFPSTimer.OnTimer;
begin
   //MainForm.Text1.Text := IntToStr(MainForm.FPS);
   //MainForm.FPS := 0;
end;

end.
