%% calcSpatiotemporalRaw
% This function starts with the raw image data, calculating the velocity 
% fields (EstimateVelocityFields) followed by segmentation of the foreground
% cellular regions in each image (SegmentationMovie) and includes a correction
% for microscope repositioning error (EstimateVelocityFields). The output
% of this stage includes quantification of the wound healing rate over time,
% and visualizations of the foreground/background segmentation and velocity
% fields. This step provides detailed visualization of the output in every 
% frame for troubleshooting and debugging.
% 
% 
% Input:
%   params - a structure map of the experiments parameters.
% 
%   dirs - a structure map of the created directories and files used for
%       analysis.
%
% For examples see 'quantifyMonolayerMigrationBulkMain.m' @step #1
% 
% 
% Yishaia Zabary, Jun. 2020 (Adapted for the Bioimage Data Analysis Workflows - Advanced Components
% and Methods Book from Zaritsky et. al. 2017 http://doi.org/10.1083/jcb.201609095)
function [] = calcSpatiotemporalRaw(params, dirs)
% calculates velocity fields with PIV, 
EstimateVeloctyFields(params, dirs);
% segmentation movie creator.
SegmentationMovie(params, dirs);
% healing rate calculation and plot creator.
CalcMonolayerMigrationMeasures(params, dirs);
% render overlaid velocity fields on each frame including a video
renderVelocityFieldVideo(params, dirs); 
end

