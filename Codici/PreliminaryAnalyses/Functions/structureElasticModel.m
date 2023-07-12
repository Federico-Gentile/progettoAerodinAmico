function [structure, Data] = structureElasticModel(Data)

% Grid Definition
x = (0:1/Data.n_elem_f:1)*(Data.pitch_bearing-Data.flap_hinge_axis)+Data.flap_hinge_axis;
xb = 0.610/(Data.blade_radius-Data.pitch_bearing);
x = [x, (xb:(1-xb)/Data.n_elem_b:1)*(Data.blade_radius-Data.pitch_bearing)+Data.pitch_bearing];

% Retrieve Bending Stiffness and mass distribution from datas
[EJ_el, x_el] = w_interpolate(Data.blade_data(:,1), Data.blade_data(:,7), x); 
[m_el, x_el] = w_interpolate(Data.blade_data(:,1), Data.blade_data(:,3), x); 

% Application of the stiffness increase factor
EJ_el = Data.elastic_model_stiffness_factor*EJ_el;

% Frozen DOF list (if = 1: position of first node is fixed) for bending
cdofs = 1;

% Compute non rotating bending modes
[fb, Modesw, Modeswp] = FEM_beam_bending(x/Data.blade_radius, EJ_el(1:2:end), m_el(1:2:end), Data.blade_radius, cdofs, [], Data.n_modb);

% Retrieve Torsional Stiffness and moment of inertia distribution from datas
[GJ_el, x_el] = w_interpolate(Data.blade_data(:,1), Data.blade_data(:,11), x);
GJ_el(1:2*Data.n_elem_f) = 0*GJ_el(1:2*Data.n_elem_f);
[J_el, x_el] = w_interpolate(Data.blade_data(:,1), Data.blade_data(:,14), x); 

% Retrieve center of mass position from datas
[xi_el, x_el] = w_interpolate(Data.blade_data(:,1), Data.blade_data(:,4), x); 
Jcg_el = J_el - m_el.*(xi_el.*Data.c).^2;

xi_el = -1*xi_el.*Data.c + Data.xcg_shift*Data.c - Data.AC{blade}(x_el)*Data.c/2;
J_el = Jcg_el + m_el.*(xi_el).^2;

% Application of the stiffness increase factor
GJ_el = Data.elastic_model_stiffness_factor*GJ_el;

% Frozen DOF list (if = 1: position of first node is fixed) for torsion
cdofs = (1:Data.n_elem_f);                                  % No rotation before pitch bearing
gdofs = [Data.n_elem_f+1, Data.pitch_link_stiffness*Data.pitch_link_factor];      % Lumped spring at pitch link location (Pitch link factor changes the stiffness of the link)

% Compute non rotating torsional modes
[ft, Modest] = FEM_beam_torsion(x/Data.blade_radius, GJ_el(1:2:end), J_el(1:2:end), Data.blade_radius, cdofs, gdofs, Data.n_modt);

n_mod = Data.n_modb + Data.n_modt;
K = zeros(n_mod, n_mod);
Kg = zeros(n_mod, n_mod);
M = eye(n_mod, n_mod);

% Combine the uncoupled modes
K(1:Data.n_modb,1:Data.n_modb) = diag(fb.^2);
K(Data.n_modb+1:n_mod,Data.n_modb+1:n_mod) = diag(ft.^2);

% Mass coupling term due to shift of CG
% m y (r-e)
Mc = zeros(Data.n_modb, Data.n_modt);
for i = 1:Data.n_modb
    for j = 1:Data.n_modt
        Mc(i,j) = trapz(x, Modesw(i,:) .* m_el([1,2:2:end])' .*  xi_el([1,2:2:end])' .* Modest(j,:));
    end
end
M(1:Data.n_modb,Data.n_modb+1:n_mod) = M(1:Data.n_modb,Data.n_modb+1:n_mod) - Mc;  % Subtracting I_y theta ''
M(Data.n_modb+1:n_mod,1:Data.n_modb) = M(Data.n_modb+1:n_mod,1:Data.n_modb) - Mc'; % Subtracting I_y beta ''

N = zeros(size(x));
%H(end) = 0;
N(end-1) = m_el(end)/2*(x(end)^2 - x(end-1)^2);
for i = length(N)-2:-1:1
    N(i) = N(i+1) + m_el(i*2)/2*(x(i+1)^2 - x(i)^2);
end

% Rotational contribution to bending
for i = 1:Data.n_modb
    for j = 1:Data.n_modb
        Kg(i,j) = trapz(x, Modeswp(i, :) .* N .* Modeswp(j,:));
    end
end

% Rotational contribution to torsion
for i = 1:Data.n_modt
    for j = 1:Data.n_modt
        Kg(Data.n_modb+i,Data.n_modb+j) = trapz(x, Modest(i, :) .* J_el([1, 2:2:end])' .* Modest(j,:));
    end
end

% Stiffness coupling term due to shift of CG
% m y om^2 r
Kgc = zeros(Data.n_modb, Data.n_modt);

for i = 1:Data.n_modb
    for j = 1:Data.n_modt
        Kgc(i,j) = trapz(x, Modeswp(i, :) .* x .* m_el([1,2:2:end])' .*  xi_el([1,2:2:end])' .* Modest(j,:));
    end
end
Kg(1:Data.n_modb,Data.n_modb+1:n_mod) = Kg(1:Data.n_modb,Data.n_modb+1:n_mod) - Kgc;        % Subtracting I_y theta
Kg(Data.n_modb+1:n_mod,1:Data.n_modb) = Kg(Data.n_modb+1:n_mod,1:Data.n_modb) - Kgc';       % Subtracting I_y beta

%f = zeros(1,Data.No_c);
Modesgw = zeros(Data.No_c,length(x),1);
Modesgt = zeros(Data.No_c,length(x),1);

Kt = K + (Data.omega)^2*Kg;
[V,E] = eig(-Kt, M);
[Eo,I] = sort(diag(E), 'descend');

Modesgw(:,:) = (V(1:Data.n_modb,I(1:Data.No_c))')*Modesw(1:Data.n_modb,:);
Modesgt(:,:) = (V(Data.n_modb+1:n_mod,I(1:Data.No_c))')*Modest(1:Data.n_modt,:);
tempM = V'*M*V;
Ms(:, :) = tempM(I(1:Data.No_c), I(1:Data.No_c));
tempK =  V'*Kt*V;
Ks(:,:) = tempK(I(1:Data.No_c), I(1:Data.No_c));
clearvars tempM  tempK

structure.Ms = Ms;
structure.Ks = Ks;
structure.Modesgw = Modesgw;
structure.Modesgt = Modesgt;
structure.x = x;
structure.xi_el = xi_el;

end