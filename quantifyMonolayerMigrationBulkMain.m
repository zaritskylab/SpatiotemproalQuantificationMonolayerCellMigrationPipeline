clearvars;
%% Advanced users parameters settings:
manualParameters = {};
manualParameters.reuse = false;
manualParameters.patchSizeUm = 15;
manualParameters.showScoreHeatMaps = false;

%% configuring matlab script paths
path = matlab.desktop.editor.getActiveFilename;
[filepath, filename, ext] = fileparts(path);
addpath(genpath(filepath));

%% Activation Flags:
flags = {};
flags.activateStep1 = true;
flags.activateStep2= true;
flags.activateStep3 = true;
flags.activateStep4 = true;
 
%% USER INPUT
format long;
path = uigetdir(matlabroot, 'Please select a directory containing multiple label free image stacks');
if length(path)==1 && path == 0
    error('no folder was selected');
end

% getting maximal number of frames in file
frameNo = getMaximalFrameNo([path filesep]);
prompt = {'Input: Physical pixel size (µm)', 'Input: Temporal resolution (min)', 'Input: Number of monolayer fronts', 'Input: Maximal single cell speed (µm/h)', 'Input: First frame to analyse', 'Input: Last frame to analyse', 'Input: Patch size (µm)'};
dlgTitle = 'Mandatory Parameters';
dlgDims = [1 40];
defaultiveInput = {'1.267428', '5', '1', '90', '1', sprintf('%d', frameNo), sprintf('%d',manualParameters.patchSizeUm)};
userInput = inputdlg(prompt, dlgTitle, dlgDims, defaultiveInput);
if isempty(userInput) 
    error('no input was detected! please try again');
end
if isnan(str2double(userInput{1}))
    error('Input %s is not valid, use positive float number only', userInput{1}(1));
elseif isnan(str2double(userInput{2}))
    error('Input %s is not valid, use positive float number only', userInput{2}(1));
elseif isnan(str2double(userInput{3}))
    error('Input %s is not valid, use positive float number only', userInput{3}(1));
elseif str2double(userInput{3}) ~= 1 && str2double(userInput{3}) ~= 2
    error('Input %s is not valid, either 1 or 2 monolayer fronts are accepted', userInput{3}(1));
elseif str2double(userInput{4}) <= 0 
    error('Input %s is not valid, use positive float numbers only', userInput{4}(1));
elseif str2double(userInput{5}) > frameNo ||str2double(userInput{5}) < 1 || str2double(userInput{5}) - int32(str2double(userInput{5})) ~= 0
    error('Input %s is not valid, use positive integer numbers only', userInput{5}(1));
elseif str2double(userInput{6}) > frameNo || str2double(userInput{6}) - int32(str2double(userInput{6})) ~= 0
    error('Input %s is not valid, use positive integer numbers equal or smaller to input frame number', userInput{6}(1));
elseif str2double(userInput{7}) <= 0 || str2double(userInput{7}) - int32(str2double(userInput{7})) ~= 0
    error('Input %s is not valid, use positive integers only', userInput{7}(1));
end

physicalPixelSize = abs(str2double(userInput{1}));
temporalResolution = abs(str2double(userInput{2}));
monolayerFrontNumber = abs(str2double(userInput{3}));
cellMaxSpeed = abs(str2double(userInput{4}));
firstFrameToAnalyse = str2double(userInput{5});
lastFrameToAnalyse = str2double(userInput{6});
manualParameters.patchSizeUm = str2double(userInput{7});
%% Pipeline analysis steps 1-2:

pathToFolder = [path filesep];

allImageStacks = dir(pathToFolder);

[allFilesPaths, filteredFileNames]= listDirs(pathToFolder, allImageStacks);

allMeasuresToProcess = {'speed', 'directionality'};
fnamesToAnalayze = [];
for fileToAnalyzeIDX = 1 : length(allFilesPaths)
    clear params;
    % Mendatory parameters & directories initialization:
    params.pixelSize  =  physicalPixelSize; % def 1.267428 µm
    params.timePerFrame = temporalResolution; % def 5 minutes
    params.nRois = monolayerFrontNumber; % def 1 
    params.maxSpeed = cellMaxSpeed; % def 90 µm/h
    params.reuse = manualParameters.reuse ; % def false
    params.showScoreHeatMaps = manualParameters.showScoreHeatMaps; % def false
    params.patchSizeUm = manualParameters.patchSizeUm; % def 15 µm
    params.minNFrames = firstFrameToAnalyse;
    params.maxNFrames = lastFrameToAnalyse;
    
    dirFName = allFilesPaths(fileToAnalyzeIDX);
    fprintf('Now analyzing file %s\n', dirFName{1});
    [params, dirs] = initParamsDirs(dirFName{1}, params);
    %%   Step #1 - calculates velocity fields, Segment foreground&backgroud, calc healing rate 
     if flags.activateStep1
        calcSpatiotemporalRaw(params, dirs);
    end
    %%   Step #2 - create kymographs, here all measures are extracted.
    if flags.activateStep2
        KymographsByMeasure(params, dirs, allMeasuresToProcess);
    end
    
end

%% Step #3 - Extract features from experiments kymographs
if flags.activateStep3
    featuresStruct = kymographsToFeaturesExtractor(dirs.kymographs, allMeasuresToProcess, params, dirs);
end

%%   Step #4 - perform PCA analysis; only demonstrated here for the features extracted from the speed measurement kymograph.
if flags.activateStep4 && flags.activateStep3
    pcaResults = PCAOnAllExperimentsMeasurements(allMeasuresToProcess, params, dirs);
    if size(pcaResults.speed.score) > 1
        pc1Scores = pcaResults.speed.score(1, :);
        pc2Scores = pcaResults.speed.score(2, :);

        hold on;
        scatter(pc1Scores, pc2Scores);
        title(sprintf('PC #1 about PC#2'));
        xlabel('PC1');
        ylabel('PC2');
        c = cellstr(removeFilesExtensions(filteredFileNames)); 
        dx = 0.01; dy = 0.1;
        text(pc1Scores+dx, pc2Scores+dy, c, 'Fontsize', 10);
        hold off;

    else
        warning('Not enough data for PCA!');
    end
end

disp('finished workflow');

