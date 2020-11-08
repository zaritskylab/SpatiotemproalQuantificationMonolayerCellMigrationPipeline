%% SingleExperimentKymographsToFeatures
% Extracts and returns an n feature vector for every specified measurement 
% kymograph for a single experiment.
% where n = params.kymographFeatMetaParams.spatialPartition *
% params.kymographFeatMetaParams.timePartition.
% 
% Input:
%   expPrefix - the experiment name, which prefixes all kymograph.mat file
%               names (e.g. 'expPrefix_speedKymograph.mat).
% 
%   kymographsTopDirectoryPath - path to to top directory of all kymographs
%           of the experiment. i.e.
%           kymographsTopDirectoryPath/
%                     [not mendatory]speed/expPrefix_speedKymograph.mat
%                     [not mendatory]directionality/expPrefix_directionalityKymograph.mat
%                     [not mendatory]coordination/expPrefix_coordinationKymograph.mat
%
%   allMeasureStr  - a list of all measures kymograph, i.e. one or
%       more of the following list {'speed','directionality','coordination'}
% 
%   params - a structure map of meta parameters for feature extraction
%
% 
% For examples see 'exampleOfEntireWorkflow.m' @step #5
% 
% Yishaia Zabary, Jun. 2020 (Adapted for the Bioimage Data Analysis Workflows - Advanced Components
% and Methods Book from Zaritsky et. al. 2017 http://doi.org/10.1083/jcb.201609095)

function [KymographsFeaturesStruct] = SingleExperimentKymographsToFeatures(expPrefix, kymographsTopDirectoryPath, allMeasureStr, params, dirs)
    % output directory
    outputDirectory = [kymographsTopDirectoryPath 'output'];
    if ~exist(outputDirectory,'dir')
        mkdir(outputDirectory);
    end
    KymographsFeaturesStruct = {};
    for iMeasure = 1 : length(allMeasureStr)  
        measureStr = allMeasureStr{iMeasure};
        kymographPath = [kymographsTopDirectoryPath measureStr filesep sprintf('%s_%sKymograph.mat', expPrefix, measureStr)];
        if ~exist(kymographPath, 'file')
            warning('no %s kymograph was found at %s', measureStr, kymographsTopDirectoryPath);
        else
            feats = kymographToFeaturesVec(kymographPath, measureStr, params);
            measureName = allMeasureStr(iMeasure);
            KymographsFeaturesStruct.(measureName{1}) = feats;
        end
    end
    save([dirs.kymographFeatures sprintf('%s_kymographFeautresStruct.mat', dirs.expname)], '-struct', 'KymographsFeaturesStruct');  
end