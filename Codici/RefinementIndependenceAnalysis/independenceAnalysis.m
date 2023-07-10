clear; close all; clc;
addpath('Templates');
addpath('Scripts');

%% User Defined Template

% Template Name 
templateTest;

% Figure options
opts.plotFigure = 1;
opts.saveFigure = 0;

% Graphical options

%% Richardson Analysis

dataProcessing;

%% Plot section
if opts.plotFigure
    plotFigure;
    if opts.saveFigure
        %
    end
end



                       









