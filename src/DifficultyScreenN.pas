unit DifficultyScreenN;

interface

uses FMX.Objects, System.Types, System.SysUtils, FMX.Layouts;

type
   TDifficultyScreen = class
   private

   public
      btnHard, btnTuning, btnBack: TImage;
      FlowLayout: TFlowLayout;
      Constructor Create; overload;
      Destructor Destroy; overload;
      procedure ShowGameScreen(Sender: TObject);
      procedure Back(Sender: TObject);

   const
      N_MENU_ELEMENTS = 4;
   end;

implementation

uses FRoboWars, Menu, GameScreen;

Constructor TDifficultyScreen.Create;
var
   Margin: Single;
begin
   inherited Create;
   FlowLayout := TFlowLayout.Create(MainForm);
   with FlowLayout do
   begin
      Parent := MainForm;
      Width := MainForm.Width / 2;
      Height := MainForm.Height / 2;
      Align := FMX.Types.TAlignLayout.Center;
   end;

   btnHard := TImage.Create(FlowLayout);
   with btnHard do
   begin
      Parent := FlowLayout;
      Bitmap.LoadFromFile('btnStart.png');
      Width := FlowLayout.Width;
      Height := FlowLayout.Height / N_MENU_ELEMENTS;
      OnClick := ShowGameScreen;
   end;
   btnBack := TImage.Create(FlowLayout);
   with btnBack do
   begin
      Parent := FlowLayout;
      Bitmap.LoadFromFile('btnBack.png');
      Width := FlowLayout.Width;
      Height := FlowLayout.Height / N_MENU_ELEMENTS;
      OnClick := Back;
   end;

end;

Destructor TDifficultyScreen.Destroy;
begin
   FreeAndNil(btnHard);
   FreeAndNil(btnTuning);
   FreeAndNil(FlowLayout);
   inherited Destroy;
end;

procedure TDifficultyScreen.ShowGameScreen(Sender: TObject);
begin

   Self.Destroy;
   MainForm.DiffScreen := Nil;
   // MainForm.GameScreen := TGameScreen.Create;
end;

procedure TDifficultyScreen.Back(Sender: TObject);
begin
   Self.Destroy;
   MainForm.DiffScreen := Nil;
   // FRoboWars.MainMenu := TMainMenuFrame.Create(Self);
end;

end.
