%% PCAOnAllExperimentsMeasurements
% Perform PCA analysis on all measurements' features.
% 
% Input:
%   featuresStruct - structure divided to measurements. each measurement
%       hold the features of all experiments.
% 
%   allMeasuresToProcess - a list of all measures kymograph, i.e. one or
%       more of the following list {'speed','directionality','coordination'}
%
% 
% For examples see 'exampleOfEntireWorkflow.m' @step #5
% 
% Yishaia Zabary, Jun. 2020 (Adapted for the Bioimage Data Analysis Workflows - Advanced Components
% and Methods Book from Zaritsky et. al. 2017 http://doi.org/10.1083/jcb.201609095)

function [pcaResultsByMeasure] = PCAOnAllExperimentsMeasurements(allMeasuresToProcess, params, dirs, featuresArray)
    if nargin < 4 && exist(dirs.PCAResultsFName,'file') && ~params.always   
        pcaResultsByMeasure = load(dirs.PCAResultsFName);
        return     
    elseif nargin < 4 && exist(dirs.PCAResultsFName,'file')
        delete(dirs.PCAResultsFName);
    end
    if nargin < 4
        featuresStruct = load(dirs.kymographFeaturesFname);
        featuresByMeasure = unifyFeaturesFromMultipleExperiments(featuresStruct, allMeasuresToProcess);
    else
        featuresByMeasure = {};
        featuresByMeasure.(allMeasuresToProcess) = featuresArray;
        temp = allMeasuresToProcess;
        allMeasuresToProcess = {};
        allMeasuresToProcess{1} = temp;
    end
    
    pcaResultsByMeasure = {};
    for measureIDX=1: length(fieldnames(featuresByMeasure))
        measureFeatures = featuresByMeasure.(allMeasuresToProcess{measureIDX})';
%         if params.usePreCalc
%             [coeff,score,latent] = loadPreCalcAndTransform(measureFeatures, allMeasuresToProcess{measureIDX}, params);
%         else
        [coeff,score,latent] = PreCalcsForPCA(measureFeatures);
%         end
        if isempty(coeff) || isempty(score) || isempty(latent)
            error('Empty (NaN) features detected, can not perform PCA analysis. This normally is due to a small stack size (short movie), or too large patchSize param.')
        end
        pcaResultsByMeasure.(allMeasuresToProcess{measureIDX}).coeff = coeff;
        pcaResultsByMeasure.(allMeasuresToProcess{measureIDX}).score = score;
        pcaResultsByMeasure.(allMeasuresToProcess{measureIDX}).latent = latent;
    end
    if nargin < 4
        save(dirs.PCAResultsFName, '-struct', 'pcaResultsByMeasure');
    end
    
end

function [coeff,score,latent] = loadPreCalcAndTransform(measureFeatures, measure, params)
    nfeats = length(measureFeatures(1, :));
    normalizedSingleMeasureFeatures = zeros(length(measureFeatures(:, 1)), nfeats);
    if strcmp(measure, 'speed')
        preCalc = load(params.preCalcLocationSpeed).precalcPcaParams;
        coeff = preCalc.coeff;
        latent = preCalc.latent;
    else
        preCalc = load(params.preCalcLocationSpeed).precalcPcaParams;
        coeff = preCalc.coeff;
        latent = preCalc.latent;
    end
    for i=1 : nfeats
        singleFeat = normalizeFeat(measureFeatures(:, i));
        normalizedSingleMeasureFeatures(:, i) = singleFeat;
    end
    score = coeff * normalizedSingleMeasureFeatures;
end

function [coeff,score,latent] = PreCalcsForPCA(singleMeasureFeatures)
    nfeats = length(singleMeasureFeatures(1, :));
    normalizedSingleMeasureFeatures = zeros(length(singleMeasureFeatures(:, 1)), nfeats);
    meanFeats = zeros(size(singleMeasureFeatures(1, :)));
    stdFeats = zeros(size(singleMeasureFeatures(1, :)));
    for i=1 : nfeats
        singleFeat = normalizeFeat(singleMeasureFeatures(:, i));
        meanFeats(i) = mean(singleFeat);
        stdFeats(i) = std(singleFeat);
        normalizedSingleMeasureFeatures(:, i) = singleFeat;
    end
    [coeff,score,latent] = pca(normalizedSingleMeasureFeatures);
        
end
function [normalizedFeatureStruct] = normalizeFeat(singleFeatureStruct)
    normalizedFeatureStruct = zeros(size(singleFeatureStruct));
    featMean = mean(singleFeatureStruct);
    featStd = std(singleFeatureStruct);
    for i=1 : length(singleFeatureStruct)
        normalized_value = (singleFeatureStruct(i) - featMean)/featStd;
        normalizedFeatureStruct(i) = normalized_value(1);
    end
end