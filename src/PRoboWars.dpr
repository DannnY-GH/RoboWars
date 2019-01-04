program PRoboWars;

uses
   System.StartUpCopy,
   FMX.Forms,
   FRoboWars in 'FRoboWars.pas' {MainForm} ,
   Menu in 'Menu.pas' {FRMainMenu: TFrame} ,
   DifficultyScreen in 'DifficultyScreen.pas' {FRDifficulty: TFrame} ,
   GameScreen in 'GameScreen.pas' {FRGameScreen: TFrame} ,
   CreditsScreen in 'CreditsScreen.pas' {FRCreditsScreen: TFrame} ,
   Model in 'Model.pas',
   Tank in 'Tank.pas',
   Timer in 'Timer.pas',
   Controller in 'Controller.pas',
   Bullet in 'Bullet.pas',
   EnemyTank in 'EnemyTank.pas',
   MUtils in 'MUtils.pas',
   Debug in 'Debug.pas' {frDebug: TFrame} ,
   Ball in 'Ball.pas',
   CongratScreen in 'CongratScreen.pas' {FRCongratScreen: TFrame} ,
   SoundManager in 'SoundManager.pas',
   HelpScreen in 'HelpScreen.pas' {FRHelpScreen: TFrame};

{$R *.res}

begin
   // ReportMemoryLeaksOnShutdown := True;
   Application.Initialize;
   Application.CreateForm(TMainForm, MainForm);
   Application.Run;

end.
