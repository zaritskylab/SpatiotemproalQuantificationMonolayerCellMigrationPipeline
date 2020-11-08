%% renderVelocityFieldVideo 
% For a given time frame, averages patches of velocity fields (by the resolution parameter)
% and overlays representing arrows on the image frame itself.
% The function disragardes all velocity field detectd passed the cellular
% foreground edge (By utilizing segmentation results).
% Saves the plot in both .esp and .jpg format to vfVis directory.
% 
% Input:
%   params - a structure map of the experiments parameters.
% 
%   dirs - a structure map of the created directories and files used for
%       analysis.
% 
%   renderUpToFrameNo - positive int (enforced), the time frame number you wish to
%       visualize velocity fields up to including.
% 
%   resolution - [non-mandatory] double, (defaultife value 0.08) the resolution of velocity fields
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
function [] = renderVelocityFieldVideo(params, dirs, resolution, arrowScale)
    if nargin < 5 || isempty(arrowScale)
        arrowScale = 20;
    end
    if nargin <4 || isempty(resolution)
        resolution = 0.08;
    end
    
    fprintf('Started Visualization of %s\n', dirs.expname);
    
    vwriter = VideoWriter([dirs.vfVis 'VisualizedVelocityVectors.avi']);
    vwriter.FrameRate = 3;
    open(vwriter);

    W = nan; H = nan;
    for t = params.minNFrames : params.nTime
        vfFname = [dirs.vfData sprintf('%03d',t) '_vf.mat']; % dxs, dys
        imageName = [dirs.images sprintf('%03d',t) '.tif'];
        if ~exist(vfFname,'file')
            throw(MException('visualizeVelocityFields:inputError', sprintf('vf file for frame No. %d was not found!\nPlease run EstimateVeloctyFields function @Step#1\n', t)));
        elseif ~exist(imageName,'file')
            throw(MException('visualizeVelocityFields:inputError', ssprintf('image file for frame No. %d was not found!\nPlease run EstimateVeloctyFields function @Step#1\n', t)));
        else
            load(vfFname);
            I = imread(imageName, 'tif');
            
            % Assumeing 3 same channels
            if size(I,3) > 1
                tmp = I(:,:,1) - I(:,:,2);
                assert(sum(tmp(:)) == 0);
                I = I(:,:,1);
            end

            [dxs, dys] = reduceResolution(dxs, dys, resolution, t, dirs);
    %         with cells brightfield image
%             hold on; 
            h =figure('visible','off'); imagesc(I); colormap(gray); 
            hold on;
            quiver(dxs, dys, arrowScale); 

            text(size(I,1)-500,size(I,2)-100,sprintf('%d minutes',round(t*params.timePerFrame)),'color','w','FontSize',15);
            haxes = get(h,'CurrentAxes');
            set(haxes,'XTick',[]);
            set(haxes,'XTickLabel',[]);
            set(haxes,'YTick',[]);
            set(haxes,'YTickLabel',[]);            
            movieFrame = getframe(h);
            
            if isnan(W)
                [H,W,~] = size(movieFrame.cdata);
                minH = H;
                maxH = H;
                minW = W;
                maxW = W;
            end
            
            if H ~= size(movieFrame.cdata,1) || W ~= size(movieFrame.cdata,2)
                minH = min(H,size(movieFrame.cdata,1));
                maxH = max(H,size(movieFrame.cdata,2));
                minW = min(W,size(movieFrame.cdata,1));
                maxW = max(W,size(movieFrame.cdata,2));
            end
            movieFrameResized = uint8(zeros(H,W,3));
            movieFrameResized(:,:,1) = imresize(movieFrame.cdata(:,:,1),[H,W]);
            movieFrameResized(:,:,2) = imresize(movieFrame.cdata(:,:,2),[H,W]);
            movieFrameResized(:,:,3) = imresize(movieFrame.cdata(:,:,3),[H,W]);
            movieFrame.cdata = movieFrameResized;

            writeVideo(vwriter,movieFrame);
            
            saveas(gcf, [dirs.vfVis sprintf('frameNo_%d_VelocityFields.esp', t)],'epsc');
            saveas(gcf, [dirs.vfVis sprintf('frameNo_%d_VelocityFields.jpg', t)]);
            hold off;
            %         without cells brightfield image
            h =figure('visible','off');
            hold on;
            quiver(dxs, dys, arrowScale); 

            text(size(I,1)-500,size(I,2)-100,sprintf('%d minutes',round(t*params.timePerFrame)),'color','w','FontSize',15);
            haxes = get(h,'CurrentAxes');
            set(haxes,'XTick',[]);
            set(haxes,'XTickLabel',[]);
            set(haxes,'YTick',[]);
            set(haxes,'YTickLabel',[]);
            savefig(gcf, [dirs.vfVis sprintf('frameNo_%d_VelocityFieldsNBF.fig', t)]);
            saveas(gcf, [dirs.vfVis sprintf('frameNo_%d_VelocityFieldsNBF.esp', t)],'epsc');
            hold off;
            fprintf('Finished Processing time frame No. %d\n', t);
        end
    end
    close(vwriter);
end

function [dxs, dys] = reduceResolution(orgDxs, orgDys, resolution, t, dirs)
    dxs = NaN(length(orgDxs(:,1)), length(orgDxs(1,:)));
    dys = NaN(length(orgDxs(:,1)), length(orgDxs(1,:)));
    rowTileSizeToAvg = uint16(length(orgDxs(:,1)) * resolution);
    colTileSizeToAvg = uint16(length(orgDxs(1,:)) * resolution);
    ROI = load([dirs.roiData sprintf('%03d',t) '_roi.mat']); % ROI
    rowIDX = 1;
    while rowIDX + rowTileSizeToAvg < length(orgDxs(:,1))
        colIDX = 1;
        while colIDX + colTileSizeToAvg < length(orgDxs(1,:)) 
            isCellularForeground = sum(ROI.ROI(rowIDX:rowIDX+rowTileSizeToAvg, colIDX:colIDX + colTileSizeToAvg), 'all');
            if isCellularForeground > 0
                tileToAvg = orgDxs(rowIDX: rowIDX+rowTileSizeToAvg, colIDX: colIDX+colTileSizeToAvg);
                tileAvg = mean(tileToAvg, 'all', 'omitnan');
                tileToAvg = NaN(length(tileToAvg(:,1)), length(tileToAvg(1,:)));
                tileToAvg(uint16(length(tileToAvg(:,1))/2), uint16(length(tileToAvg(1,:))/2)) = tileAvg;
                dxs(rowIDX: rowIDX+rowTileSizeToAvg, colIDX: colIDX+colTileSizeToAvg) = tileToAvg;

                tileToAvg = orgDys(rowIDX: rowIDX+rowTileSizeToAvg, colIDX: colIDX+colTileSizeToAvg);
                tileAvg = mean(tileToAvg, 'all', 'omitnan');
                tileToAvg = NaN(length(tileToAvg(:,1)), length(tileToAvg(1,:)));
                tileToAvg(uint16(length(tileToAvg(:,1))/2), uint16(length(tileToAvg(1,:))/2)) = tileAvg;
                dys(rowIDX: rowIDX+rowTileSizeToAvg, colIDX: colIDX+colTileSizeToAvg) = tileToAvg;
            end
            colIDX = colIDX + colTileSizeToAvg;
        end
        rowIDX = rowIDX + rowTileSizeToAvg;
    end
    
end
