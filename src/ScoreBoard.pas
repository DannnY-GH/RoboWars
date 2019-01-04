unit ScoreBoard;

interface

uses
   System.SysUtils, System.Types, System.UITypes, System.Classes,
   System.Variants,
   FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
   FMX.Objects, FMX.Layouts;

type
   TFRScoreBoard = class(TFrame)
      imgScoreL1: TImage;
      imgScoreL2: TImage;
    gpScoreBoard: TGridPanelLayout;
      txP1: TText;
      txP2: TText;
   private
      { Private declarations }
   public
      procedure ClearBoard;
   end;

var
   AScoreBoard: TFRScoreBoard;

implementation

{$R *.fmx}

procedure TFRScoreBoard.ClearBoard;
begin
   txP1.Text := '0';
   txP2.Text := '0';
end;

end.
