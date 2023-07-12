%% function to compute the torsional modes of a structure given the mass 
%% distribution and the stiffness distribution  
%% INPUT
% x     grid, vector of nodes used to represent the structure
%       the position must be between 0 and 1, so in non-dimensional
%       cooordinates
% GJ    vector of stiffness properties at each elements. Elements are
%       n-1, where n is the number of nodes
% Jp    vector of mass associated with each element
% L     length of the beam
% cdofs list of the constrained dofs: e.g. 2 means that the rotation 
%       of node 2 is constrained to zero 
% gdofs are dofs that are grounded using a lumped stiffness. The list must 
%       be composed by a matric [dof, stiffness_value]  
% n     number of modes to send to output
%% OUTPUT
% f       frequencies from 1 to n
% Modest  Modal shapes for torsional rotation at nodes Matrix [n x length of x]
% Giuseppe Quaranta, Politecnico di Milano
% Aeroservoelasticity of fixed and rotary wing aircraft

function [f, Modest] = FEM_beam_torsion(x, GJ, Jp, L, cdofs, gdofs, No)
 
n_elem = length(x)-1;
n_nodes = n_elem + 1;
n_dofs = n_nodes;
if (x(end) > 1)
    x = x ./ x(end);
    warning('Nodes position is rescaled to be in the interval [0,1]');
end
    
if (length(GJ) ~= n_elem) || (length(Jp) ~= n_elem) 
    error('Wrong size of input vectors');
end

K = zeros(n_dofs,n_dofs);
M = zeros(n_dofs,n_dofs);

% assembly
for i = 1:n_elem
    [Me,Ke] =  elem_T_matrices(GJ(i), Jp(i), (x(i+1) - x(i))*L );
    K(i:(i+1),i:(i+1)) = K(i:(i+1),i:(i+1)) + Ke;
    M(i:(i+1),i:(i+1)) = M(i:(i+1),i:(i+1)) + Me;
end

% set consatraints by eliminating rows and columns
% set w(0) w'(0) = 0
if not(isempty(gdofs))
    for i = 1 : size(gdofs,1)
        K(gdofs(i,1), gdofs(i,1)) = gdofs(i,2) + K(gdofs(i,1), gdofs(i,1));
    end
end
dofs = 1:n_dofs;
% free dofs
f_dofs = setdiff(dofs,cdofs); 
Kr = K(f_dofs, f_dofs);
Mr = M(f_dofs, f_dofs);
[V,E] = eig(-Kr, Mr);
[Eo,I] = sort(diag(E), 'descend');
f = imag(sqrt(Eo(1:No)));
Modes = zeros(length(f),n_dofs);
Modes(:,f_dofs) = V(:,I(1:No))';

%WARNING Addition 18/10/2021 Scale the modes at unit mass 
Mm = Modes*M*Modes';
Modes = diag(1./sqrt(diag(Mm)))*Modes;

Modest = Modes;
