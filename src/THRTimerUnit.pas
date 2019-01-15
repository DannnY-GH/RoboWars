unit THRTimerUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, Math, Windows;

type
   THRTimer = class;

     TTimerThread = class(TThread)
     private
       { Private declarations }
       FOwner: THRTimer;
     protected
       procedure Execute; override;
     end;

     THRTimer = class(TComponent)
     private
       FInterval: Double;
       FOnTimer: TNotifyEvent;
       FStartTime: Double;
       FClockRate: Double;
       FExists: Boolean;
       FEnabled: Boolean;
       FThread: TTimerThread;
       FPriority: TThreadPriority;

     public
       constructor Create(AOwner: TComponent); override;
       function ReadTimer: Double;
       procedure SetEnabled(Value: Boolean);
       procedure SetInterval(const Value: Double);
       procedure SetPriority(const Value: TThreadPriority);
     protected
       function StartTimer: Boolean;
       procedure Timer; virtual;
     published
       property Exists: Boolean read FExists;
       property Enabled: Boolean read FEnabled write SetEnabled;
       property Interval: Double read FInterval write SetInterval;
       property OnTimer: TNotifyEvent read FOnTimer write FOnTimer;
       property Priority: TThreadPriority read FPriority write SetPriority;
     end;

implementation

uses
   FRoboWars;

{ THRTimer }

constructor THRTimer.Create(AOwner: TComponent);
var
  QW: Int64;
begin
  inherited Create(AOwner);
  FExists := QueryPerformanceFrequency(QW);
  FClockRate := QW;
  FEnabled := false;
  FInterval := 1;
  FPriority := TpNormal;
end;

function THRTimer.ReadTimer: Double;
var
  ET: Int64;
begin
  QueryPerformanceCounter(ET);
  Result := 1000.0 * (ET - FStartTime) / FClockRate;
end;

procedure THRTimer.SetEnabled(Value: Boolean);
begin
   if FEnabled = Value then Exit
      else FEnabled := Value;

   if FEnabled then
   begin
      StartTimer;
      FThread := TTimerThread.Create(false);
      FThread.FOwner := Self;
      FThread.FreeOnTerminate := true;
      FThread.Priority := FPriority;
   end
   else
      FThread.Terminate;
end;

procedure THRTimer.SetInterval(const Value: Double);
begin
  if FInterval <> Value then
  begin
    if Enabled then
    begin
      Enabled := False;
      FInterval := Value;
      Enabled := True;
    end
    else
      FInterval := Value;
  end;
end;

procedure THRTimer.SetPriority(const Value: TThreadPriority);
begin
  if FPriority <> Value then
    FPriority := Value;
end;

function THRTimer.StartTimer: Boolean;
var
  QW: Int64;
begin
  Result := QueryPerformanceCounter(QW);
  FStartTime := QW;
end;

procedure THRTimer.Timer;
begin
  if not (csDesigning in ComponentState) then
    if Assigned(FOnTimer) then FOnTimer(Self);
    //âîò ñþäà ñâîé êîä âñòàâëÿåøü
   MainForm.TestTank.FBodyImg.Position.Point :=
     PointF(MainForm.TestTank.FBodyImg.Position.X + 0.5,
     MainForm.TestTank.FBodyImg.Position.Y);
end;

// TTimerThread
procedure TTimerThread.Execute;
var
  StartT: Double;
  TickCounter: Integer;
begin
  TickCounter := 1;
  StartT := FOwner.ReadTimer;
  while not (Terminated or Application.Terminated) do
  begin
    if (FOwner.ReadTimer - StartT) >= FOwner.FInterval * TickCounter then
    begin
      //Synchronize(FOwner.Timer);
      FOwner.Timer;
      //Inc(TickCounter);
      Sleep(1);
    end;
  end;
end;

end.
