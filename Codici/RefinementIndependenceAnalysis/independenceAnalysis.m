clear; close all; clc;
addpath('Templates');
addpath('Scripts');

%% User Defined Template

% Template Name 
C1_RANS_ref;

% Figure options
opts.plotFigure = 1;

% Graphical options

%% Richardson Analysis

dataProcessing;

%% Plot section
if opts.plotFigure
    plotFigure;
end



                       









