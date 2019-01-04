unit GameScreenN;

interface
type
  TGameScreen = class
  private

  public
    Constructor Create; overload;
    Destructor Destroy; overload;
    procedure Show;
  end;

implementation

uses FRoboWars;

Constructor TGameScreen.Create;
begin
  inherited Create;
end;

Destructor TGameScreen.Destroy;
begin

  inherited Destroy;
end;

procedure TGameScreen.Show;
begin
  //MainForm.Image1.Visible  := False;
end;

end.
