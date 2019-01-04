unit MUtils;

interface

uses System.Math, System.Types;
function QuadrEqu(A, B, C: Single): TPointF;

implementation

function QuadrEqu(A, B, C: Single): TPointF;
var
   D: Single;
begin
   D := B * B - 4 * A * C;
   if D < 0 then
      Result := PointF(NaN, NaN)
   else if D = 0 then
      Result := PointF(-B / (2 * A), -B / (2 * A))
   else
      Result := PointF((-B + sqrt(D)) / (2 * A), (-B - sqrt(D)) / (2 * A));
end;

end.
