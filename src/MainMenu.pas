unit MainMenu;

interface

uses FMX.Objects, System.Types, System.SysUtils, FMX.Layouts, HighScoreScreen,
   DifficultyScreen;

type
   TMainMenu = class
   private

   public
      btnStart, btnSettings, btnHighScore, btnTuning, btnExit: TImage;
      FlowLayout: TFlowLayout;
      Constructor Create; overload;
      Destructor Destroy; overload;
      procedure Show;
      procedure ShowDifficultyScreen(Sender: TObject);
      procedure ShowHighScoreScreen(Sender: TObject);
      procedure ShowTuningScreen(Sender: TObject);
      procedure ExitGame(Sender: TObject);

   const
      N_MENU_ELEMENTS = 4;
   end;

implementation

uses FRoboWars;

Constructor TMainMenu.Create;
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
   btnStart := TImage.Create(FlowLayout);
   with btnStart do
   begin
      Parent := FlowLayout;
      Bitmap.LoadFromFile('btnStart.png');
      Width := FlowLayout.Width;
      Height := FlowLayout.Height / N_MENU_ELEMENTS;
      OnClick := ShowDifficultyScreen;
   end;

   btnTuning := TImage.Create(FlowLayout);
   with btnTuning do
   begin
      Parent := FlowLayout;
      Bitmap.LoadFromFile('btnTuning.png');
      Width := FlowLayout.Width;
      Height := FlowLayout.Height / N_MENU_ELEMENTS;
      OnClick := ExitGame;
   end;

   btnHighScore := TImage.Create(FlowLayout);
   with btnHighScore do
   begin
      Parent := FlowLayout;
      Bitmap.LoadFromFile('btnHighScores.png');
      Width := FlowLayout.Width;
      Height := FlowLayout.Height / N_MENU_ELEMENTS;
      OnClick := ShowHighScoreScreen;
   end;

   btnExit := TImage.Create(FlowLayout);
   with btnExit do
   begin
      Parent := FlowLayout;
      Bitmap.LoadFromFile('btnExit.png');
      Width := FlowLayout.Width;
      Height := FlowLayout.Height / N_MENU_ELEMENTS;
      OnClick := ExitGame;
   end;

end;

Destructor TMainMenu.Destroy;
begin
   FreeAndNil(btnStart);
   FreeAndNil(btnSettings);
   FreeAndNil(btnHighScore);
   FreeAndNil(btnTuning);
   FreeAndNil(FlowLayout);
   inherited Destroy;
end;

procedure TMainMenu.ShowDifficultyScreen(Sender: TObject);
begin
   Self.Destroy;
   MainForm.MainMenu := nil;
   MainForm.DiffScreen := TFRDifficulty.Create(MainForm);
end;

procedure TMainMenu.ShowTuningScreen(Sender: TObject);
begin
   btnStart.Visible := False;
end;

procedure TMainMenu.ShowHighScoreScreen(Sender: TObject);
begin
   Self.Destroy;
   // HigScoreScreen.Show;
end;

procedure TMainMenu.ExitGame(Sender: TObject);
begin
   MainForm.Close;
end;

procedure TMainMenu.Show;
begin
   btnStart.Visible := True;
end;

end.
