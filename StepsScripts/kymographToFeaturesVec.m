    %% kymographsToFeaturesVec
% Extracts and returns an n feature vector for a single kymograph.
% where n = params.kymographFeatMetaParams.spatialPartition *
% params.kymographFeatMetaParams.timePartition.
% 
% Input:
%   kymographPath - path to 'kymograph.mat' file.
% 
%   measureStr - *one* of the following ['speed'/'directionality'/'coordination']
%                   occurding to your previous calculations.
% 
%   params - a structure map of the experiments parameters.
% 
%
% For examples see 'exampleOfEntireWorkflow.m' @step #3
% 
% Yishaia Zabary, Jun. 2020 (Adapted for the Bioimage Data Analysis Workflows - Advanced Components
% and Methods Book from Zaritsky et. al. 2017 http://doi.org/10.1083/jcb.201609095)
function [featuresArray] = kymographToFeaturesVec(kymographPath, measureStr, params)
metaParameters.timePerFrame = params.timePerFrame;
metaParameters.spaceToAnalyze = floor(params.maxDistToProcess/params.stripSizeUm); 
metaParameters.timeToAnalyze = params.maxTimeToProcess;
% the 'grid' attributes, defines the size and scale of the features.

%%
load(kymographPath)
eval(sprintf('kymograph = %sKymograph;',measureStr)); % kymograph
assert(exist('kymograph','var') > 0);
%%
distancesFromWound = find(isnan(kymograph(:,1)),1,'first')-1;
if isempty(distancesFromWound)
    distancesFromWound = size(kymograph,1);
end

if distancesFromWound < params.spatialPartition
    warning('Too few cells at %s! analyzing maximal available space, number of features = %d',kymographPath, distancesFromWound * params.timePartition);
    metaParameters.spaceToAnalyze = distancesFromWound;
    metaParameters.spatialPartition = distancesFromWound;
end

if length(kymograph(:, 1)) < metaParameters.spaceToAnalyze
    metaParameters.spaceToAnalyze = length(kymograph(:, 1));
end

featuresArray = getFeatures(kymograph,metaParameters, params);

end


%%
function [features] = getFeatures(kymograph, metaParameters, params)
nTime = min([floor(metaParameters.timeToAnalyze/metaParameters.timePerFrame) length(kymograph(1, :))]);
nSpace = metaParameters.spaceToAnalyze;
singleTileTime = floor(nTime/(params.timePartition));
singleTileSpace = floor(nSpace/(params.spatialPartition));

nFeats = params.timePartition * params.spatialPartition;
iSpace = 1 : singleTileSpace : nSpace+1;
iTime = 1 : singleTileTime : nTime+1; 

features = zeros(nFeats,1);
curFeatI = 0;
for y = 1 : params.spatialPartition
    for x = 1 : params.timePartition%x = 1 : metaParameters.timePartition
        curFeatI = curFeatI + 1;
        values = kymograph(iSpace(y):(iSpace(y+1)-1),iTime(x):(iTime(x+1)-1));
        values = values(~isinf(values));
        values = values(~isnan(values));
        features(curFeatI) = mean(values(:));
    end
end
end