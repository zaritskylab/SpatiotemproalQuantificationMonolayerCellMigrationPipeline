%% whKymographs
% This function uses as input the velocity fields calculated 
% previously (see step #1) step and calculates three possible types of kymographs 
% for a given input. 
%   1. speed kymographs which is constructed by calculating the average 
%      velocity of all patches in spatial bands the distance of x µm from
%      the monolayer’s edge through time. 
%   2. directionality kymograph, where instead of average speed, the value 
%      of each bin is defined as the absolute ratio between the velocity
%      component perpendicular to the monolayer edge and the velocity 
%      component parallel to the monolayer edge. Each bin was calculated 
%      as the ratio obtained by the two-component decomposition of the
%      speed kymograph to a component normal and parallel to the monolayer
%      front. These components were calculated by considering the
%      orientation of the wound edge. 
% 
% 
% Input:
%   params - a structure map of the experiments parameters.
% 
%   dirs - a structure map of the created directories and files used for
%       analysis.
%
% For examples see 'quantifyMonolayerMigrationBulkMain.m' @step #3
% 
% 
% Yishaia Zabary, Jun. 2020 (Adapted for the Bioimage Data Analysis Workflows - Advanced Components
% and Methods Book from Zaritsky et. al. 2017 http://doi.org/10.1083/jcb.201609095)
function [] = whKymographs(params,dirs, measuresToExtract)

params.xStepMinutes = 60;
params.yStepUm = 50;
params.yMaxUm = params.kymoMaxDistMu - params.kymoMinDistMu;
params.fontsize = 24;
params.totalFramesToAnalyse = min([params.nTime params.kymoMaxTimeFrameNum]) - max([params.minNFrames params.kymoMinTimeFrameNum]);

fprintf('start kymographs\n');
close all;
if any(strcmp(measuresToExtract, 'speed'))
    generateSpeedKymograph(params,dirs);
end
if any(strcmp(measuresToExtract, 'directionality'))
    generateDirectionalMigrationKymograph(params,dirs);
end
if any(strcmp(measuresToExtract, 'coordination'))
    generateCoordinatedMigrationKymograph(params,dirs); 
end
close all;
end

function [] = generateSpeedKymograph(params,dirs)

speedKymographFname = [dirs.speedKymograph dirs.expname '_speedKymograph.mat'];

if exist(speedKymographFname,'file') && ~params.always
    return;
end

speedKymograph = nan(params.nstrips, params.totalFramesToAnalyse);
speedKymographX = nan(params.nstrips, params.totalFramesToAnalyse);
speedKymographY = nan(params.nstrips, params.totalFramesToAnalyse);
for t = max([params.kymoMinTimeFrameNum, params.minNFrames]) : min([params.nTime params.kymoMaxTimeFrameNum])
    roiFname = [dirs.roiData sprintf('%03d',t) '_roi.mat']; % ROI
    vfFname = [dirs.vfData sprintf('%03d',t) '_vf.mat']; % dxs, dys
    
    load(roiFname);
    load(vfFname);
    
    speed = sqrt(dxs.^2 + dys.^2);
    DIST = bwdist(~ROI);
    
    for d = 1 : params.nstrips
        inDist = ...
            (DIST > (params.strips(d)-params.kymoResolution.stripSize)) & ...
            (DIST < params.strips(d)) & ...
            ~isnan(speed);
        speedInStrip = speed(inDist);
        speedKymograph(d,t - max([params.minNFrames params.kymoMinTimeFrameNum]) + 1) = mean(speedInStrip);
        % For directional migration
        speedInStripX = dxs(inDist);
        speedKymographX(d,t - max([params.minNFrames params.kymoMinTimeFrameNum]) + 1) = mean(abs(speedInStripX));
        speedInStripY = dys(inDist);
        speedKymographY(d,t - max([params.minNFrames params.kymoMinTimeFrameNum]) + 1) = mean(abs(speedInStripY));
    end
end

% Translate to mu per hour
speedKymograph = speedKymograph .* params.toMuPerHour;

save(speedKymographFname,'speedKymograph','speedKymographX','speedKymographY');

metaData.fname = [dirs.speedKymograph dirs.expname '_speedKymograph.jpg'];
metaData.fnameFig = [dirs.speedKymograph dirs.expname '_speedKymograph.fig'];
metaData.caxis = [0 60];

params.caxis = metaData.caxis;
params.fname = metaData.fname;

plotKymograph(speedKymograph,params);

end

function [] = generateDirectionalMigrationKymograph(params,dirs)

directionalityKymographFname = [dirs.directionalityKymograph dirs.expname '_directionalityKymograph.mat'];

if exist(directionalityKymographFname,'file') && ~params.always
    return;
end


load([dirs.speedKymograph dirs.expname '_speedKymograph.mat']); % 'speedKymograph','speedKymographX','speedKymographY';
if params.isDx
    directionalityKymograph = speedKymographX ./ speedKymographY;
else
    directionalityKymograph = speedKymographY ./ speedKymographX;
end

save(directionalityKymographFname,'directionalityKymograph');

metaData.fname = [dirs.directionalityKymograph dirs.expname '_directionalityKymograph.jpg'];
metaData.fnameFig = [dirs.directionalityKymograph dirs.expname '_directionalityKymograph.fig'];

% metaData.caxis = [0 5]; % for more saturated visualization
metaData.caxis = [0 10]; % default


params.caxis = metaData.caxis;
params.fname = metaData.fname;

plotKymograph(directionalityKymograph,params);
end


%%
function [] = generateCoordinatedMigrationKymograph(params,dirs)
coordinationKymographFname = [dirs.coordinationKymograph dirs.expname '_coordinationKymograph.mat'];

if exist(coordinationKymographFname,'file') && ~params.always
    return;
end

coordinationKymograph = nan(params.nstrips,params.nTime);

for t = max([params.kymoMinTimeFrameNum, params.minNFrames]) : min([params.nTime params.kymoMaxTimeFrameNum])
    roiFname = [dirs.roiData sprintf('%03d',t) '_roi.mat']; % ROI
    coordinationFname = [dirs.coordination sprintf('%03d',t) '_coordination.mat']; % ROIclusters
    
    load(roiFname);
    load(coordinationFname);
        
    DIST = bwdist(~ROI);
    
    for d = 1 : params.nstrips        
        inDist = ((DIST > (params.strips(d)-params.kymoResolution.stripSize)) & (DIST < params.strips(d))) & ~isnan(ROIclusters);
                
        coordinationInStrip = ROIclusters(inDist);
        coordinationKymograph(d,t - max([1 params.kymoMinTimeFrameNum])) = sum(coordinationInStrip)/length(coordinationInStrip);
    end
end

save(coordinationKymographFname,'coordinationKymograph');

metaData.fname = [dirs.coordinationKymograph dirs.expname '_coordinationKymograph.jpg'];
metaData.fnameFig = [dirs.coordinationKymograph dirs.expname '_coordinationKymograph.fig'];
metaData.caxis = [0 1];

% plotKymograph(coordinationKymograph,metaData,params);

params.caxis = metaData.caxis;
params.fname = metaData.fname;

plotKymograph(coordinationKymograph,params);
end