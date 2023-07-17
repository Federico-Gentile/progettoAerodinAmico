function f = elasticRotorDeformation(q, u, mach, aColl, aTwis, aIndu, rotData, inp, aeroData, structure, ambData)

% Computing structural stiffness matrix
Modest = structure.ModesgtInterpolated;
Modesw = structure.ModesgwInterpolated;
K_modal = structure.Ks(:, :, end);

% Defining aerodinamic nodes [m]
x_aero = inp.x;

% Computing angle of attack [deg]
aThet = Modest' * q * 180/pi;
alpha = aColl + aTwis + aThet - aIndu*180/pi;

% Aerodynamic loads
cl = diag(interp2(aeroData.mach_cl, aeroData.angle_cl, aeroData.cl, mach', alpha));
cm = diag(interp2(aeroData.mach_cm, aeroData.angle_cm, aeroData.cm, mach', alpha));

%% Aggiungere proiezione del drag sull'equazione di flappeggio
% Forcing term (RHS)
RHSf = 0.5 * ambData.rho * rotData.c * Modesw .* repmat((u.^2 .* cl)',[rotData.No_c,1]);
RHSm = 0.25 * ambData.rho * rotData.c^2 * Modest .* repmat((u.^2 .* cm)',[rotData.No_c,1]);
RHSF = sum((RHSf(:,1:end-1)+RHSf(:,2:end)).*repmat(diff(x_aero)',[rotData.No_c,1]), 2) / 2;
RHSM = sum((RHSm(:,1:end-1)+RHSm(:,2:end)).*repmat(diff(x_aero)',[rotData.No_c,1]), 2) / 2;
RHS = RHSF + RHSM;

% Non linear equation set
f = K_modal * q - RHS;