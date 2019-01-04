unit Debug;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects;

type
  TfrDebug = class(TFrame)
    txTs: TText;
    txVx: TText;
    txVy: TText;
    txAx: TText;
    FL: TFlowLayout;
    txAy: TText;
    txT1: TText;
    txT2: TText;
    txT3: TText;
    txT4: TText;
    txX: TText;
    txY: TText;
    txT: TText;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
