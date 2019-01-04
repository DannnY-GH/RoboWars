unit Timer;

interface

uses
   System.Classes, FMX.Dialogs, System.Types, System.SysUtils, Windows;

type
   TMTimer = class(TThread)
   protected
      FDelay: Integer;
      procedure Execute; override;
   public
      constructor Create(pDoNotAutoStart: Boolean; pDelay: Integer);
      procedure SetDelay(pDelay: Integer);
      property Delay: Integer read FDelay write SetDelay;
   end;

implementation

uses FRoboWars, Controller;

procedure TMTimer.SetDelay(pDelay: Integer);
begin
   if Delay >= 0 then
      FDelay := pDelay;
end;

constructor TMTimer.Create(pDoNotAutoStart: Boolean; pDelay: Integer);
begin
   inherited Create(pDoNotAutoStart);
   Delay := pDelay;
   Priority := TThreadPriority.tpHighest;
   FreeOnTerminate := True;
end;

procedure TMTimer.Execute;
begin
   while not Terminated do
   begin
      Synchronize(AController.Update);
      Sleep(FDelay);
   end;
end;

end.
