%% visualizeVelocityFields 
% For a given time frame, averages patches of velocity fields (by the resolution parameter)
% and overlays representing arrows on the image frame itself.
% The function disragardes all velocity field detectd passed the cellular
% foreground edge (By utilizing segmentation results).
% Saves the plot in both .esp and .jpg format to mfVis directory.
% 
% Input:
%   params - a structure map of the experiments parameters.
% 
%   dirs - a structure map of the created directories and files used for
%       analysis.
% 
%   timeFrameToVisualize - positive int (enforced), the time frame number you wish to
%       visualize its velocity fields.
% 
%   resolution - [non-mendatory] double, (defaultife value 0.02) the resolution of velocity fields
%       to show. e.g. if resolution=0.1 the averaged patches of velocity
%       fields will be tenth the size of the frame.
% 
%   arrowScale - [non-mendatory] double ≥ 1, (defaultife value 20), the scale of the arrow head compared to its
%        true size.
% 
%
% For examples see 'exampleOfEntireWorkflow.m' @ Bonus step
% 
% 
% Yishaia Zabary, Jun. 2020 (Adapted for the Bioimage Data Analysis Workflows - Advanced Components
% and Methods Book from Zaritsky et. al. 2017 http://doi.org/10.1083/jcb.201609095)
function [] = visualizeVelocityFields(params, dirs, timeFrameToVisualize, resolution, arrowScale)
    timeFrameToVisualize = abs(uint16(timeFrameToVisualize));
    if nargin < 5 || isempty(arrowScale)
        arrowScale = 20;
    end
    if nargin < 4 || isempty(resolution)
        resolution = 0.02;
    end
    fprintf('Started Visualization of Frame No. %d\n', timeFrameToVisualize);
    mfFname = [dirs.mfData sprintf('%03d',timeFrameToVisualize) '_mf.mat']; % dxs, dys
    imageName = [dirs.images sprintf('%03d',timeFrameToVisualize) '.tif'];
    if ~exist(mfFname,'file')
        throw(MException('visualizeVelocityFields:inputError', sprintf('mf file for frame No. %d was not found!\nPlease run EstimateVeloctyFields function @Step#1\n', t)));
    elseif ~exist(imageName,'file')
        throw(MException('visualizeVelocityFields:inputError', ssprintf('image file for frame No. %d was not found!\nPlease run EstimateVeloctyFields function @Step#1\n', t)));
    else
        load(mfFname);
        I = imread(imageName, 'tif');
        
        [dxs, dys] = reduceResolution(dxs, dys, resolution, timeFrameToVisualize, dirs);
%         with cells brightfield image
        h =figure('visible','off'); imagesc(I); colormap(gray); 
        hold on;
        quiver(dxs, dys, arrowScale); 
        
        text(size(I,1)-500,size(I,2)-100,sprintf('%d minutes',round(timeFrameToVisualize*params.timePerFrame)),'color','w','FontSize',15);
        haxes = get(h,'CurrentAxes');
        set(haxes,'XTick',[]);
        set(haxes,'XTickLabel',[]);
        set(haxes,'YTick',[]);
        set(haxes,'YTickLabel',[]);
        saveas(gcf, [dirs.mfVis sprintf('frameNo_%d_VelocityFields.esp', timeFrameToVisualize)],'epsc');
        saveas(gcf, [dirs.mfVis sprintf('frameNo_%d_VelocityFields.jpg', timeFrameToVisualize)]);
        hold off;
        %         without cells brightfield image
        h =figure('visible','off');
        hold on;
        quiver(dxs, dys, arrowScale); 
        
        text(size(I,1)-500,size(I,2)-100,sprintf('%d minutes',round(timeFrameToVisualize*params.timePerFrame)),'color','w','FontSize',15);
        haxes = get(h,'CurrentAxes');
        set(haxes,'XTick',[]);
        set(haxes,'XTickLabel',[]);
        set(haxes,'YTick',[]);
        set(haxes,'YTickLabel',[]);
        saveas(gcf, [dirs.mfVis sprintf('frameNo_%d_VelocityFieldsNBF.esp', timeFrameToVisualize)],'epsc');
        hold off;
        fprintf('Finished Processing time frame No. %d', timeFrameToVisualize);
    end
    
end

