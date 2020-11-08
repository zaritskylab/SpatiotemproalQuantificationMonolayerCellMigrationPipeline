%% CalcMonolayerMigrationMeasures
% Using the segmentation from the previous steps, calculates the fraction of
% cellular foreground from the entire image in each frame.
% Saves the healing rate plot in .jpg .eps and a .mat structure file 
% an implementation of step #3 in the book chapter.
% 
% Input:
%   params - a structure map of the experiments parameters.
% 
%   dirs - a structure map of the created directories and files used for
%       analysis.
%
% For examples see 'exampleOfEntireWorkflow.m' @step #1
% 
% 
% Yishaia Zabary, Jun. 2020 (Adapted for the Bioimage Data Analysis Workflows - Advanced Components
% and Methods Book from Zaritsky et. al. 2017 http://doi.org/10.1083/jcb.201609095)
function [] = CalcMonolayerMigrationMeasures(params,dirs)

% healing µm path
healingUmFname = [dirs.monolayerMigrationMeasures dirs.expname '_healingUm.eps'];
healingUmMetaFname = [dirs.monolayerMigrationMeasures dirs.expname '_healingUm.mat'];
healingUmCSVFname = [dirs.monolayerMigrationMeasures dirs.expname '_healingUm.csv'];
% healing rate path
healingRateFname = [dirs.monolayerMigrationMeasures dirs.expname '_healingRate.eps'];
healingRateMetaFname = [dirs.monolayerMigrationMeasures dirs.expname '_healingRate.mat'];
healingRateCSVFname = [dirs.monolayerMigrationMeasures dirs.expname '_healingRate.csv'];

if exist(healingRateFname,'file') && exist(healingRateMetaFname,'file') && ~params.always
     return;
end

time = params.minNFrames : params.nTime - 1; % -1 because segmentation is based on motion
ntime = length(time);


healingUm = nan(1,ntime);
healingRate = nan(1,ntime);
averageHealingRate = nan(1,ntime);

load([dirs.roiData sprintf('%03d', params.minNFrames) '_roi.mat']); % ROI
sumInitROI = sum(ROI(:)); clear ROI;

fprintf('calculating healing rate\n');

for t = time
    load([dirs.roiData sprintf('%03d',t) '_roi.mat']); % ROI
    ROI0 = ROI; clear ROI;
    load([dirs.roiData sprintf('%03d',t+1) '_roi.mat']); % ROI
    ROI1 = ROI; clear ROI;
    
    nDiffPixels = sum(ROI1(:)) - sum(ROI0(:));
    nDiffPixelsMeta = sum(ROI1(:)) - sumInitROI;
    if params.isDx
        healingUm(t) = params.pixelSize * nDiffPixels;
        healingRate(t) = params.toMuPerHour * nDiffPixels / size(ROI0,1);
        averageHealingRate(t) = params.toMuPerHour * nDiffPixelsMeta / (size(ROI0,1) * t);
    else
        warning('currently supporting only dx, continuing with dx...');
        healingUm(t) = params.pixelSize * nDiffPixels;
        healingRate(t) = params.toMuPerHour * nDiffPixels / size(ROI0,2);
        averageHealingRate(t) = params.toMuPerHour * nDiffPixelsMeta / (size(ROI0,2) * t);
    end
end

maxTime = ntime * params.timePerFrame;
maxTimeMod = (maxTime - mod(maxTime,100));
maxSpeed = params.maxSpeed; % um / hour


plotAndSaveHealingData(healingRate, maxSpeed, maxTime, maxTimeMod, dirs, 'Rate');
plotAndSaveHealingData(healingUm, maxSpeed, maxTime, maxTimeMod, dirs, 'Um');

save(healingRateMetaFname,'healingRate','healingRate');
save(healingUmMetaFname,'healingUm','healingRate');
writematrix(healingRate, healingRateCSVFname);
writematrix(healingUm, healingUmCSVFname);
end

function [] = plotAndSaveHealingData(healingData, maxSpeed, maxTime, maxTimeMod, dirs, type)
    hold on;
    h = figure; 
    timeVector = 1: length(healingData);
    if strcmp(type, 'Rate')
%         plotregression(timeVector,healingData,'Regression');
        plot(timeVector, healingData,'or','MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',10);
        ylabel('Healing rate (\mum hour{-1})','FontSize',32);
    else
        plot(timeVector, healingData,'or','MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',10);
        ylabel('Healing advancement (\mum)','FontSize',32);
    end
    xlabel('Time (minutes)','FontSize',32); 
    
    haxes = get(h,'CurrentAxes');
    set(haxes,'XLim',[0, length(timeVector)]);
    set(haxes,'XTick',0:round(maxTimeMod/5):maxTimeMod);
    set(haxes,'XTickLabel',0:round(maxTimeMod/5):maxTimeMod);
    set(haxes,'YLim',[0, max([maxSpeed, max(healingData)])]);
    set(haxes,'YTick',0:round(max(maxSpeed, max(healingData))/5): max(maxSpeed, max(healingData)));
    set(haxes,'YTickLabel',0:round(max(maxSpeed, max(healingData))/5): max(maxSpeed, max(healingData)));
    set(haxes,'FontSize',10);
    legend('Location','northeastoutside')
    
    saveas(h, [dirs.monolayerMigrationMeasures dirs.expname sprintf('healing%sPlot.jpg', type)]);
    saveas(h, [dirs.monolayerMigrationMeasures dirs.expname sprintf('healing%sPlot.eps', type)],'epsc');
    savefig(gcf, [dirs.monolayerMigrationMeasures dirs.expname sprintf('healing%sPlot.fig', type)]);

    hold off;
end
