%% FEM for Beam Torsional problems
%% Mass and stiffness matrices for a FEM elements of lenght L with constant
%% moment of inertia Jp and constant stiffness GJ within the element
% the dofs are  w(1) w'(1) w(2) w'(2)
% the shape functions are cubic polynomial 
% See Cooper Wright Pag 397 - 400
% Giuseppe Quaranta, Politecnico di Milano
% Aeroservoelasticity of fixed and rotary wing aircraft
%% INPUT 
% GJ    stiffness constant of the element
% Jp    mass constant of the element
% L     length of the element
%% OUTPUT
% M     Element Mass matrix
% K     Element Stiffness matrix

function [M, K] = elem_T_matrices(GJ, Jp, L) 

% Mass and stiffness matrices for a FEM elements of lenght L with constant
% mass m and constant stiffness EJ within the element
% the dofs are  theta(1) theta(2)
% the shape functions are linear functions 
% See Cooper Wright Pag 397 - 400
M = Jp*L/6* [   2    1;
               1    2];
    
 K = GJ/L*[ 1   -1;
           -1    1];

