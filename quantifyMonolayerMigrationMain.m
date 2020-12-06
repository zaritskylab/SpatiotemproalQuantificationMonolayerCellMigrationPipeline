clearvars;
%% Advanced users parameters settings:
params.reuse = false; 
params.patchSizeUm = 15;
params.showScoreHeatMaps = false;
%% configuring matlab script paths
path = matlab.desktop.editor.getActiveFilename;
[filepath, filename, ext] = fileparts(path);
addpath(genpath(filepath));

%% Activation Flags:
flags = {};
flags.activateStep1 = true; 
flags.activateStep2= true;
flags.activateStep3 = true; 

%% USER INPUT
format long;
[file,path] = uigetfile({'*.tif;*.lsm;*.zvi'}, 'Please select a label free image stack');

if (length(file)==1  && length(path)==1)
    warning('no file was selected');
    return;
end
% getting number of frames in file
[filepath, filename, ext] = fileparts([path file]);
frameNo = getFrameNo(filepath, filename, ext);
prompt = {'Input: Physical pixel size (µm)', 'Input: Temporal resolution (min)', 'Input: Number of monolayer fronts', 'Input: Maximal single cell speed (µm/h)', 'Input: First frame to analyse', 'Input: Last frame to analyse', 'Input: Patch size (µm)'};
dlgTitle = 'Mandatory Parameters';
dlgDims = [1 40];
defaultiveInput = {'1.267428', '5', '1', '90', '1', sprintf('%d', frameNo), sprintf('%d',params.patchSizeUm)};
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
patchSizeUm = str2double(userInput{7});
pathToFile = [path file];

%% Pipeline analysis:

% Mendatory parameters & directories initialization:
params.pixelSize  =  physicalPixelSize; % def 1.267428 µm
params.timePerFrame = temporalResolution; % def 5 minutes
params.nRois = monolayerFrontNumber; % def 1 
params.maxSpeed = cellMaxSpeed;
params.minNFrames = firstFrameToAnalyse;
params.maxNFrames = lastFrameToAnalyse;
params.patchSizeUm = patchSizeUm;

[params, dirs] = initParamsDirs(pathToFile,params); % set missing parameters, create output directories

%%   Step #1 - calculates velocity fields, Segment foreground&backgroud, calc healing rate 
if flags.activateStep1
    calcSpatiotemporalRaw(params, dirs);
end
%%   Step #2 - create kymographs, here all measures are extracted.
if flags.activateStep2
    allMeasuresToProcess = {'speed', 'directionality'};
    KymographsByMeasure(params, dirs, allMeasuresToProcess);
end
%%   Step #3 - extract features from kymographs
if flags.activateStep3    
    allMeasuresToProcess = {'speed', 'directionality'};
    featuresStruct = SingleExperimentKymographsToFeatures(dirs.expname, dirs.kymographs, allMeasuresToProcess, params, dirs);
end


disp('finished all steps');

