% Function name: whCorrectGlobalMotion
% Author: Assaf Zaritsky, May 2015
% Description: corrects global motion in the image (cause by microscope
%              repeatability problem). Uses the background texture to estimate local 
%              background motion. If most of motion ~= 0 than there is a global motion to be corrected 

function [] = whCorrectGlobalMotion(params,dirs)

correctMotionFname = [dirs.correctMotion dirs.expname '_correctMotion.mat'];

if exist(correctMotionFname,'file') && ~params.always
    return;
end

% move back to original files
if exist([dirs.vfDataOrig filesep '001_vf.mat'],'file')    
    % unix(sprintf('cp -R %s %s',[dirs.vfDataOrig '*.mat'],dirs.vfData));
    copyfile([dirs.vfDataOrig '*.mat'], dirs.vfData);
end
    
% unix(sprintf('cp -R %s %s',[dirs.vfData '*.mat'],dirs.vfDataOrig));
copyfile([dirs.vfData '*.mat'], dirs.vfDataOrig);


correctionsDx = [];
correctionsDy = [];
medianPrecentDx = [];
medianPrecentDy = [];

for t = params.minNFrames : params.nTime
    vfFname = [dirs.vfData sprintf('%03d',t) '_vf.mat'];
    roiFname = [dirs.roiData sprintf('%03d',t) '_roi.mat'];    
    
    fprintf(sprintf('correcting motion estimation frame %d\n',t));
    
    load(vfFname); % dxs, dys
    load(roiFname); % ROI
    
    [correctDx, medianPDx] = getCorrection(dxs,ROI);
    %     xsBackground = dxs(~ROI);
    %     xsBackground = xsBackground(~isnan(xsBackground));
    %     nXsBackground = length(xsBackground);
    %     medianXsBackground = median(xsBackground(:));
    %     if medianXsBackground ~= 0 && (sum(xsBackground == medianXsBackground) > 0.6 * nXsBackground)
    %         correctDx = -medianXsBackground;
    %     else
    %         correctDx = 0;
    %     end
    correctionsDx = [correctionsDx correctDx];
    medianPrecentDx = [medianPrecentDx medianPDx];
    
    [correctDy, medianPDy] = getCorrection(dys,ROI);
    correctionsDy = [correctionsDy correctDy];
    medianPrecentDy = [medianPrecentDy medianPDy];
   
    if abs(correctDx) > 0.5 || abs(correctDy) > 0.5
        imgFname0 = [dirs.images sprintf('%03d',t) '.tif'];
        imgFname1 = [dirs.images sprintf('%03d',t+params.frameJump) '.tif'];
        I0 = imread(imgFname0);    
        I1 = imread(imgFname1);
        
        if size(I0,3) > 1
            tmp = I0(:,:,1) - I0(:,:,2);
            assert(sum(tmp(:)) == 0);
            I0 = I0(:,:,1);
            I1 = I1(:,:,1);
        end
        
        [dydx, dys, dxs, scores] = blockMatching(I0, I1, params.patchSize,params.searchRadiusInPixels,true(size(I0)),round(correctDx),round(correctDy)); % block width, search radius,
    end
    
    
    
    %% correction
    dxs = dxs + correctDx;
    dys = dys + correctDy;
    save(vfFname,'dxs','dys','scores');

end

nCorrected = sum(abs(correctionsDx) > 0.5 | abs(correctionsDy) > 0.5);
nCorrectedDx = sum(abs(correctionsDx) > 0.5);
nCorrectedDy = sum(abs(correctionsDy) > 0.5);
precentCorrected = nCorrected/length(correctionsDx);
save(correctMotionFname,'correctionsDx','correctionsDy','medianPrecentDy','medianPrecentDx','nCorrected','nCorrectedDx','nCorrectedDy','precentCorrected');%,'transDx','transDy'
end

%%
% medianPDx - precent of patches in the median +- 1 range, should be high!
function [correctDx, medianPDx] = getCorrection(dxs,ROI)
xsBackground = dxs(~ROI);
xsBackground = xsBackground(~isnan(xsBackground));
nXsBackground = length(xsBackground);
medianXsBackground = median(xsBackground(:));

sumMedian0 = sum(xsBackground == (medianXsBackground-1));
sumMedian1 = sum(xsBackground == medianXsBackground);
sumMedian2 = sum(xsBackground == (medianXsBackground+1));
allSumMedian = sumMedian0 + sumMedian1 + sumMedian2;

correctDx = 0;
if (allSumMedian > 0.6 * nXsBackground)
    correctDx = -(((sumMedian0 * (medianXsBackground-1)) + (sumMedian1 * medianXsBackground) + (sumMedian2 * (medianXsBackground+1)))/allSumMedian);
end

medianPDx = allSumMedian/nXsBackground;
end