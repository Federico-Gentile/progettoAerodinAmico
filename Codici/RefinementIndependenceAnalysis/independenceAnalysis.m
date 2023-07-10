clear; close all; clc;
addpath('Templates');
addpath('Scripts');

%% User Defined Template

% Template Name 
C4_RANS;

% Figure options
opts.plotFigure = 1;

% Graphical options

%% Richardson Analysis

dataProcessing;

%% Plot section
if opts.plotFigure
    plotFigure;
end



                       









