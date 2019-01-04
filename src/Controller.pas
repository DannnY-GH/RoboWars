unit Controller;

interface

uses
   Timer, Windows, FMX.Dialogs, System.SysUtils, FMX.Forms;

type
   TController = class(TObject)
   public
      Timer: TMTimer;
      constructor Create; overload;
      destructor Destroy; overload;
      procedure Update;
      procedure Draw;
   end;

var
   AController: TController;

implementation

uses
   FRoboWars, Model, SoundManager;

constructor TController.Create;
begin
   inherited;
   Timer := TMTimer.Create(True, 5)
end;

destructor TController.Destroy;
begin
   MainForm.EndUpdate;
   Timer.Terminate;
   inherited;
end;

procedure TController.Draw;
begin

end;

procedure TController.Update;
begin
   AModel.Update;
   AModel.Draw;
   ASoundManager.Loop('menu');
end;

end.
