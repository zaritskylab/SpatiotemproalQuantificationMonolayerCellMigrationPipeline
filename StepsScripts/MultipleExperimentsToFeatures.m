%% MultipleExperimentsToFeatures
% Extracts and returns an n feature vector for every specified measurement 
% kymograph for all experiments kymographs in a specified folder.
% where n = params.kymographFeatMetaParams.spatialPartition *
% params.kymographFeatMetaParams.timePartition.
% 
% Input:
%   mainKymographsDirectory - path to to top directory of all kymographs
%       of the experiments. i.e.
%           mainExperimentsDirectory/
%               exp1Prefix/kymographs/
%                   [not mendatory]speed/expPrefix_speedKymograph.mat
%                   [not mendatory]directionality/expPrefix_directionalityKymograph.mat
%                   [not mendatory]coordination/expPrefix_coordinationKymograph.mat
%               exp2Prefix/kymographs/
%                   [not mendatory]speed/expPrefix_speedKymograph.mat
%                   [not mendatory]directionality/expPrefix_directionalityKymograph.mat
%                   [not mendatory]coordination/expPrefix_coordinationKymograph.mat
% 
%   allMeasuresToProcess - a list of all measures kymograph, i.e. one or
%       more of the following list {'speed','directionality','coordination'}
% 
%   params - a structure map of meta parameters for feature extraction
%
% 
% 
% For examples see 'exampleOfEntireWorkflow.m' @step #5
% 
% Yishaia Zabary, Jun. 2020 (Adapted for the Bioimage Data Analysis Workflows - Advanced Components
% and Methods Book from Zaritsky et. al. 2017 http://doi.org/10.1083/jcb.201609095)
function [allExperimentsKymographsFeaturesArray] = MultipleExperimentsToFeatures(mainKymographsDirectory, allMeasuresToProcess, params)
    allExperimentsDirectoryContent = dir(mainKymographsDirectory);
    
    for expPrefixIDX = 1 : length(allExperimentsDirectoryContent)
        expPrefix =allExperimentsDirectoryContent(expPrefixIDX).name;
        if strcmp(expPrefix, '.DS_Store') || strcmp(expPrefix, '.') || strcmp(expPrefix, '..')
            continue;
        else
            kymographsTopDirectoryPath = mainKymographsDirectory;
            singleExpKymographFeaturesArray = SingleExperimentKymographsToFeatures(expPrefix, kymographsTopDirectoryPath, allMeasuresToProcess, params);
            existingFieldsNames = fieldnames(singleExpKymographFeaturesArray);
            for measureIDX = 1 : length(existingFieldsNames)
                measureName = existingFieldsNames(measureIDX);
                if ~isnan(str2double(expPrefix))
                    expPrefix = sprintf('EXP_%s', expPrefix);
                end
                allExperimentsKymographsFeaturesArray.(expPrefix).(measureName{1}) = singleExpKymographFeaturesArray.(measureName{1}); 
            end
        end 
    end
end