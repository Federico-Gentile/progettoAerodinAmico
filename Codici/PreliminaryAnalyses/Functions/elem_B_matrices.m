%% FEM for Beam Bending problems
%% Mass and stiffness matrices for a FEM elements of lenght L with constant
%% mass m and constant stiffness EJ within the element
% the dofs are  w(1) w'(1) w(2) w'(2)
% the shape functions are cubic polynomial 
% See Cooper Wright Pag 397 - 400
% Giuseppe Quaranta, Politecnico di Milano
% Aeroservoelasticity of fixed and rotary wing aircraft
%% INPUT 
% EJ    stiffness constant of the element
% m     mass constant of the element
% L     length of the element
%% OUTPUT
% M     Element Mass matrix
% K     Element Stiffness matrix
%
function [M, K] = elem_B_matrices(EJ, m, L) 

M = m*L/420* [   156    22*L     54    -13*L;
                22*L   4*L^2   13*L   -3*L^2;
                  54    13*L    156    -22*L;
               -13*L  -3*L^2  -22*L    4*L^2];

 K = EJ/L^3*[ 12     6*L    -12      6*L;
             6*L   4*L^2   -6*L    2*L^2;
             -12    -6*L     12     -6*L;
             6*L   2*L^2   -6*L    4*L^2];

