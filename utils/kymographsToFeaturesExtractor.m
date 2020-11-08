%% MultipleExperimentsToFeatures
% Extracts and returns an n feature vector for every specified measurement 
% kymograph for all experiments kymographs in a specified folder.
% where n = params.kymographFeatMetaParams.spatialPartition *
% params.kymographFeatMetaParams.timePartition.
% 
% Input:
%   mainKymographsDirectory - path to to top directory of all kymographs
%       of the experiments. i.e.
%           kymographs/
%                   [not mendatory]speed/expPrefix1_speedKymograph.mat
%                   [not mendatory]speed/expPrefix2_speedKymograph.mat
%                   [not mendatory]directionality/expPrefix1_directionalityKymograph.mat
%                   [not mendatory]directionality/expPrefix2_directionalityKymograph.mat
%                   [not mendatory]coordination/expPrefix1_coordinationKymograph.mat
%                   [not mendatory]coordination/expPrefix2_coordinationKymograph.mat
% 
% 
%   allMeasuresToProcess - a list of all measures kymograph, i.e. one or
%       more of the following list {'speed','directionality','coordination'}
% 
%   params - a structure map of meta parameters for feature extraction
%
% 
% 
% For examples see 'exampleOfEntireWorkflow.m' @step #3
% 
% Yishaia Zabary, Jun. 2020 (Adapted for the Bioimage Data Analysis Workflows - Advanced Components
% and Methods Book from Zaritsky et. al. 2017 http://doi.org/10.1083/jcb.201609095)
function [allExperimentsKymographsFeaturesArray] = kymographsToFeaturesExtractor(mainKymographsDirectory, allMeasuresToProcess, params, dirs)
    allExperimentsKymographsFeaturesArray = {};
    for measureIDX = 1 : length(allMeasuresToProcess)
        measure = allMeasuresToProcess{measureIDX};
        pathToMeasureDir = [mainKymographsDirectory measure filesep];
        measureDirContent = dir(pathToMeasureDir);
        for kymoFileIDX = 1 : length(measureDirContent)
            kymoFilename = measureDirContent(kymoFileIDX).name;
            if strcmp(kymoFilename, '.DS_Store') || strcmp(kymoFilename, '.') || strcmp(kymoFilename, '..')
                continue;
            else
                expPrefix = kymoFilename(1 : find(kymoFilename == '_' , 1, 'last') - 1);
                kymographPath = [pathToMeasureDir sprintf('%s_%sKymograph.mat', expPrefix, measure)];
                feats = kymographToFeaturesVec(kymographPath, measure, params);
                feats(isnan(feats))=0;
                allExperimentsKymographsFeaturesArray.(expPrefix).(measure) = feats; 
            end
            
        end
        
    end
    save(dirs.kymographFeaturesFname, '-struct', 'allExperimentsKymographsFeaturesArray');  
end

