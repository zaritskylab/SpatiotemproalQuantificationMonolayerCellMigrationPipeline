%% KymographsByMeasure
% Renders a color kymograph describing the average measurement (e.g. speed)
% of the band of cells in a given distance to the monolayer migrtaing edge.
% The kymograph's x-axis is time in seconds, y-axis is the distance from
% the monolayer edge while the color encodes the average measurement value
% at the corresponding (x,y).
% Saves the kymograph as .fig and .jpg files.
% 
% Input:
%   params - a structure map of meta parameters for feature extraction
% 
%   dirs - a structure map of the created directories and files used for
%       analysis.
%   allMeasuresToProcess - a list of all required measures kymographs, i.e. one or
%       more of the following list {'speed','directionality','coordination'}
%
% For examples see 'exampleOfEntireWorkflow.m' @step #1
% 
% Yishaia Zabary, Jun. 2020 (Adapted for the Bioimage Data Analysis Workflows - Advanced Components
% and Methods Book from Zaritsky et. al. 2017 http://doi.org/10.1083/jcb.201609095)
function [] = KymographsByMeasure(params, dirs, allMeasuresToProcess)
whKymographs(params,dirs, allMeasuresToProcess);
end