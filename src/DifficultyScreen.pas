unit DifficultyScreen;

interface

uses
   System.SysUtils, System.Types, System.UITypes, System.Classes,
   System.Variants,
   FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
   FMX.Objects, FMX.Layouts, Controller, Tank, EnemyTank;

type
   TFRDifficulty = class(TFrame)
      GridPanelLayout1: TGridPanelLayout;
      btnPvsCOM: TImage;
      btnExit: TImage;
      btnPVP: TImage;
      btnPingPong: TImage;
      btn12MANY: TImage;
      procedure btnExitClick(Sender: TObject);
      procedure btnPvsCOMClick(Sender: TObject);
      procedure btnPVPClick(Sender: TObject);
      procedure btnPingPongClick(Sender: TObject);
      procedure btn12MANYClick(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
   end;

var
   ADifficultyScreen: TFRDifficulty;

implementation

uses FRoboWars, Model, GameScreen, Ball, Menu;
{$R *.fmx}

procedure TFRDifficulty.btn12MANYClick(Sender: TObject);
begin
   AModel.NewGame(gm12MANY);
   Self.Visible := False;
end;

procedure TFRDifficulty.btnExitClick(Sender: TObject);
begin
   Self.Visible := False;
   AMainMenuScreen.Visible := True;
   AModel.ActiveWindow := awMainMenu;
end;

procedure TFRDifficulty.btnPvsCOMClick(Sender: TObject);
begin
   AModel.NewGame(gmPvCOM);
   Self.Visible := False;
end;

procedure TFRDifficulty.btnPingPongClick(Sender: TObject);
begin
   AModel.NewGame(gmPingPong);
   Self.Visible := False;
end;

procedure TFRDifficulty.btnPVPClick(Sender: TObject);
begin
   AModel.NewGame(gmPVP);
   Self.Visible := False;
end;

end.
