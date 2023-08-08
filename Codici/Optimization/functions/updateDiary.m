function updateDiary(x, out_xfoil_root, out, sett)
%UPDATEDIARY Summary of this function goes here
%   Detailed explanation goes here
diary("histories\"+sett.opt.historyFilename+".txt")
fprintf("%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%i\t%i\n", x(1), x(2), x(3), x(4), x(5), x(6), x(7), x(8), sum(out_xfoil_root.nConv)/size(out_xfoil_root.criticalMat,1)*size(out_xfoil_root.criticalMat,2), out.P, out.coll, out.T, min(out.alpha), max(out.alpha), out_xfoil_root.failXFOIL, out.exitflag);
diary off
end

