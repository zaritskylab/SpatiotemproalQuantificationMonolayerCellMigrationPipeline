function [featuresByMeasures] = unifyFeaturesFromMultipleExperiments(featuresStruct, measuresToUnify)
    import java.util.*;
    allExperimentsNames = fieldnames(featuresStruct);
    numberOfExperiments = length(allExperimentsNames);
    numOfFeatures = getNumOfFeatures(featuresStruct);
    for measureIDX = 1 : length(measuresToUnify)
        measureName = measuresToUnify(measureIDX);
        measures.(measureName{1}) = zeros(numberOfExperiments, numOfFeatures);
        for expIDX = 1 : length(allExperimentsNames)
            expName = allExperimentsNames(expIDX);
            expMeasureFeatureVector = featuresStruct.(expName{1}).(measureName{1});
            expMeasureFeatureVector = expMeasureFeatureVector';
            measures.(measureName{1})(expIDX, :) = expMeasureFeatureVector;
        end
    end
    featuresByMeasures = measures;
end
function [numOfFeatures] = getNumOfFeatures(featuresStruct)
    allExperimentsNames = fieldnames(featuresStruct);
    firstExperimentName = allExperimentsNames(1);
    experimentMeasures = featuresStruct.(firstExperimentName{1});
    allexperimentsMeasuresNames = fieldnames(experimentMeasures);
    firstMeasureName = allexperimentsMeasuresNames(1);
    numOfFeatures = length(experimentMeasures.(firstMeasureName{1}));
end
