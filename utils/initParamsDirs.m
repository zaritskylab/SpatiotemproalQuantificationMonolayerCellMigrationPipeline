%% initParamsDirs
% Initializes all parameters and directories and splits the images stacks
% to single images files (in created images folder).
% Parameters which were not placed in the params structure are initialized
% with defaultive values.
% Directories are created inside the directory the original time lapse
% stack is located.
% 
% Input:
%   params - a structure map.
% 
%   dirs - a structure map of the created directories and files used for
%       analysis.
% 
%
% Parameters defaultive values:
% 
% 1. params.isDx = true; % is the monolayer migrates mainly across the
%                          x-axis of the imaged plane.
% 2. params.frameJump = 1; % displacement calculation between frame# t and
%                            frame# t+frameJump.
% 3. params.maxSpeed = 90; % Estimated maximum x-axis migration speed(µm/h).
% 4. params.fixGlobalMotion = false; % correct for bias due to motion
% 5. params.nRois = 1; 
% 6. params.showScoreHeatMaps = false; % Enables similarity visualization.
% 7. params.patchSize = ceil(params.patchSizeUm/params.pixelSize); % 15 um in pixels
% 8. params.nBilateralIter = 1; 
% 9. params.minClusterArea = 5000;
% 10. params.regionMerginParams.P = 0.03;% small P --> more merging
% 11. params.regionMerginParams.Q = 0.005;% large Q --> more merging (more significant than P)
% 12. params.kymoResolution.maxDistMu = 180; % um
% 13. params.kymoResolution.min = params.patchSize;
% 14. params.kymoResolution.stripSize = params.patchSize;        
% 15. params.maxNFrames = 300;
% 16. params.always = true;
% 
% 
% Yishaia Zabary, Jun. 2020 (Adapted for the Bioimage Data Analysis Workflows - Advanced Components
% and Methods Book from Zaritsky et. al. 2017 http://doi.org/10.1083/jcb.201609095)
function [params,dirs] = initParamsDirs(filename,params) 

[mainDirname, expname, ext] = fileparts(filename);

if ~(strcmp(ext, '.tif') || strcmp(ext, '.zvi')|| strcmp(ext, '.lsm'))
    error('filename %s not supported',ext);
end

%% Parameters
if ~isfield(params,'pixelSize') || ~isfield(params,'timePerFrame')
    error('pixelSize, patchSizeUm, maxSpeed and timePerFrame are obligatory parameters');
end

if ~isfield(params,'isDx')
    params.isDx = true;
else
    if ~params.isDx
        error('currently supporting only dx, rotate you images');
    end
end


if ~isfield(params,'patchSizeUm')
    params.patchSizeUm = 15; %µm
end


if ~isfield(params,'frameJump')
    params.frameJump = 1;
end

if ~isfield(params,'maxSpeed')
    params.maxSpeed = 90; % µm / hr    
end

if ~isfield(params,'fixGlobalMotion')
    params.fixGlobalMotion = false; % correct for bias due to motion
end

if ~isfield(params,'nRois')
    params.nRois = 1; 
end
if ~isfield(params,'showScoreHeatMaps')
    params.showScoreHeatMaps = false; 
end
params.searchRadiusInPixels = ...
    ceil((params.maxSpeed/params.pixelSize)*...
    (params.timePerFrame*params.frameJump/60)); 

params.toMuPerHour = params.pixelSize * 60/(params.timePerFrame*params.frameJump);


if ~isfield(params,'patchSize')
    params.patchSize = ceil(params.patchSizeUm/params.pixelSize); % 15 um in pixels
end

if ~isfield(params,'nBilateralIter')
    params.nBilateralIter = 1;
end

if ~isfield(params,'minClusterArea') % in mu^2
    params.minClusterArea = 5000;
end

if ~isfield(params,'regionMerginParams')
    params.regionMerginParams.P = 0.03;% small P --> more merging
    params.regionMerginParams.Q = 0.005;% large Q --> more merging (more significant than P)
end

if ~isfield(params,'kymoMaxDistMu') % jumps of patchSizeUm
    params.kymoMaxDistMu = 180; 
end
if ~isfield(params,'kymoMinDistMu') % jumps of patchSizeUm
    params.kymoMinDistMu = params.patchSizeUm;
end 

if ~isfield(params, 'kymoMinTimeMinutes') % jumps of timePerFrame 
     params.kymoMinTimeMinutes = 0; % in minutes
end

if ~isfield(params, 'kymoMaxTimeMinutes') % jumps timePerFrame 
     params.kymoMaxTimeMinutes = params.frameJump*params.timePerFrame*getFrameNo(mainDirname,expname,ext); % in minutes
     
end

if ~isfield(params, 'stripSizeUm') % jumps patchSizeUm 
     params.stripSizeUm = params.patchSizeUm; % in minutes
     
end

params.kymoResolution.stripSize = ceil(params.stripSizeUm/params.pixelSize) ;%params.patchSize;

params.kymoMinTimeFrameNum = (params.kymoMinTimeMinutes==0)*1 + (params.kymoMinTimeMinutes>0)* (params.kymoMinTimeMinutes / params.timePerFrame * params.frameJump);
params.kymoMaxTimeFrameNum = params.kymoMaxTimeMinutes / params.timePerFrame * params.frameJump;

params.kymoResolution.nPatches = floor((params.kymoMaxDistMu-params.kymoMinDistMu) / params.patchSizeUm);
params.kymoResolution.max = params.kymoMaxDistMu/params.pixelSize; %params.kymoResolution.nPatches*params.patchSize;

params.strips =  ceil(params.kymoMinDistMu/params.pixelSize) : params.kymoResolution.stripSize : params.kymoResolution.max;
params.nstrips = length(params.strips);

if ~isfield(params,'maxNFrames')
    params.maxNFrames = 300;
end

if ~isfield(params,'reuse')
    params.reuse = false;
end

params.always = ~params.reuse;

% Kymograph to features parameters
if ~isfield(params,'timePartition')
    params.timePartition = 4;
end

if ~isfield(params,'spatialPartition')
    params.spatialPartition = 3;
end

if ~isfield(params,'maxTimeToProcess') % in minutes
    params.maxTimeToProcess = params.kymoMaxTimeMinutes;
end

if ~isfield(params,'maxDistToProcess') % in µm
    params.maxDistToProcess = params.kymoMaxDistMu;
end


%% Directories

dirs.main = [mainDirname filesep];
dirs.dirname = [dirs.main expname];
dirs.expname = expname;

% images
dirs.images = [dirs.dirname filesep 'images' filesep];

% VF
dirs.vf = [dirs.dirname filesep 'VF' filesep];
dirs.vfData = [dirs.vf 'vf' filesep];
dirs.vfDataOrig = [dirs.vf 'vfOrig' filesep];
dirs.vfScores = [dirs.vf 'scoresVis' filesep];
% dirs.vfBilateral = [dirs.vf 'bilateral' filesep];
dirs.vfVis = [dirs.vf 'vfVis' filesep];

% ROI
dirs.roi = [dirs.dirname filesep 'ROI' filesep];
dirs.roiData = [dirs.roi 'roi' filesep];
% dirs.roiVis = [dirs.roi 'vis' filesep];

% Coordination
% dirs.coordination = [dirs.dirname filesep 'coordination' filesep];
% dirs.coordinationVis = [dirs.coordination filesep 'vis'];

% kymographs
dirs.kymographs = [dirs.main 'kymographs' filesep];
dirs.speedKymograph = [dirs.kymographs 'speed' filesep];
dirs.directionalityKymograph = [dirs.kymographs 'directionality' filesep];
% dirs.coordinationKymograph = [dirs.kymographs 'coordination' filesep];

% Healing rate
dirs.monolayerMigrationMeasures = [dirs.main 'monolayerMigrationMeasures' filesep];
dirs.segmentation = [dirs.main 'segmentation' filesep];

% motion correction (micrscope repeat error)
dirs.correctMotion = [dirs.main 'correctMotion' filesep];

% Kymograph features:
dirs.kymographFeatures = [dirs.main 'kymographFeatures' filesep];
dirs.kymographFeaturesFname = [dirs.kymographFeatures 'AllexperimentsAllMeasuresKymographFeautresStruct.mat'];

% PCA results:
dirs.PCAResultsMain = [dirs.main 'PCA_Results' filesep];
dirs.PCAResults = {};
dirs.PCAResultsFName = [dirs.PCAResultsMain 'extracted_pcs_for_experiments.mat'];
% dirs.PCAResults.speed = [dirs.PCAResultsMain 'speed' filesep];
% dirs.PCAResults.directionality = [dirs.PCAResultsMain 'directionality' filesep];
%% Create local directories
if ~exist(dirs.dirname,'dir')
    mkdir(dirs.dirname);
end

if ~exist(dirs.images,'dir')
    mkdir(dirs.images);
end

if ~exist(dirs.vf,'dir')
    mkdir(dirs.vf);
end

if ~exist(dirs.vfData,'dir')
    mkdir(dirs.vfData);
end

if ~exist(dirs.vfDataOrig,'dir')
    mkdir(dirs.vfDataOrig);
end

if ~exist(dirs.vfScores,'dir')
    mkdir(dirs.vfScores);
end

% if ~exist(dirs.vfBilateral,'dir')
%     mkdir(dirs.vfBilateral);
% end

if ~exist(dirs.vfVis,'dir')
    mkdir(dirs.vfVis);
end

if ~exist(dirs.roi,'dir')
    mkdir(dirs.roi);
end

if ~exist(dirs.roiData,'dir')
    mkdir(dirs.roiData);
end

% if ~exist(dirs.roiVis,'dir')
%     mkdir(dirs.roiVis);
% end

% if ~exist(dirs.coordination,'dir')
%     mkdir(dirs.coordination);
% end
% 
% if ~exist(dirs.coordination,'dir')
%     mkdir(dirs.coordinationVis);
% end

if ~exist(dirs.correctMotion,'dir')
    mkdir(dirs.correctMotion);
end

%% Global directories
if ~exist(dirs.kymographs,'dir')
    mkdir(dirs.kymographs);
end

if ~exist(dirs.speedKymograph,'dir')
    mkdir(dirs.speedKymograph);
end

if ~exist(dirs.directionalityKymograph,'dir')
    mkdir(dirs.directionalityKymograph);
end

% if ~exist(dirs.coordinationKymograph,'dir')
%     mkdir(dirs.coordinationKymograph);
% end

if ~exist(dirs.monolayerMigrationMeasures,'dir')
    mkdir(dirs.monolayerMigrationMeasures);
end

if ~exist(dirs.segmentation,'dir')
    mkdir(dirs.segmentation);
end

if ~exist(dirs.kymographFeatures,'dir')
    mkdir(dirs.kymographFeatures);
end

if ~exist(dirs.PCAResultsMain,'dir')
    mkdir(dirs.PCAResultsMain);
end

% if ~exist(dirs.PCAResults.speed,'dir')
%     mkdir(dirs.PCAResults.speed);
% end

% if ~exist(dirs.PCAResults.directionality,'dir')
%     mkdir(dirs.PCAResults.directionality);
% end

%% create images in directory
nFrames = arrangeImages(mainDirname,expname,ext,dirs.images);

%% frames to include parameters
if ~isfield(params,'minNFrames') || params.minNFrames < 1 || params.minNFrames > params.maxNFrames
    params.minNFrames = 1;
end

if ~isfield(params,'nTime') || (params.nTime > (min(nFrames,params.maxNFrames) - 1))
    params.nTime = min(nFrames,params.maxNFrames) - 1;
end

end

%% From stack to image folder
function [nFrames] = arrangeImages(mainDirname,expname,ext,imagesdir)
    fname = [mainDirname filesep expname ext];

    if ~exist(fname,'file')    
        t = 1;
        while exist([imagesdir sprintf('%03d',t) '.tif'],'file')
            t = t + 1;
        end
        nFrames = t - 1;

        if nFrames < 2    
            error('File %s nor images exist',fname);
        end
        return;
    end


    if (strcmp(ext, '.tif'))
        info = imfinfo(fname);
        nFrames = numel(info);
        for t = 1 : nFrames
            I = imread(fname,t);
            if size(I,3) > 1
                I = I(:,:,1);
            end
            eval(['imwrite(I,''' [imagesdir sprintf('%03d',t) '.tif'''] ',''tif'')']);
        end
    elseif (strcmp(ext, '.zvi'))
            fname = [mainDirname name '.zvi'];
            data = bfopen(fname);
            images = data{1};
            nFrames = size(images,1);
            for t = 1 : nFrames
                I = images(t,1);
                I = I{:};
                eval(['imwrite(I,''' [imagesdir sprintf('%03d',t) '.tif'''] ',''tif'')']);
            end
    elseif (strcmp(ext,'.lsm'))
            fname = [mainDirname name '.lsm'];
            stack = tiffread29(fname);
            nFrames = length(stack);
            for t = 1 : nFrames
                    data = stack(t).data;
                    if length(data) == 2
                        I = data{2};
                    else
                        I = data;
                    end
                    eval(['imwrite(I,''' [imagesdir sprintf('%03d',t) '.tif'''] ',''tif'')']);
            end
    end
end

