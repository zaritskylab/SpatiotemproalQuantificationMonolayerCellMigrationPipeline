%% coordinationClustersVisualizer
% In each frame, using the precalculated velocity fields, 
% clusters similiarly behaving regions in the frame using
% Region Growing Segmentation technique.
% 
% Input:
%   params - a structure map of meta parameters for feature extraction
% 
%   dirs - a structure map of the created directories and files used for
%       analysis.
% 
%
% For examples see 'exampleOfEntireWorkflow.m' @step #1
% 
% 
% Yishaia Zabary, Jun. 2020 (Adapted for the Bioimage Data Analysis Workflows - Advanced Components
% and Methods Book from Zaritsky et. al. 2017 http://doi.org/10.1083/jcb.201609095)
function [] = coordinationClustersVisualizer(params,dirs)

    time = 1 : params.nTime;

    fprintf('starting coordination\n');
    vidWriterObj = VideoWriter([dirs.coordination 'VisualizedCoordinationClusters.avi']);
    vidWriterObj.FrameRate = 3;
    W = nan; H = nan;
    open(vidWriterObj);
    for t = time
        fprintf(sprintf('Processing coordination for frame No. %d\n', t));
        coordinationFname = [dirs.coordination sprintf('%03d',t) '_coordination.mat'];

        if exist(coordinationFname,'file') && ~params.always
            fprintf(sprintf('fetching frame %d precalculated clusters\n', t));
            load(coordinationFname,'clusters','ROIclusters','clustersMask','outImgDx1','outImgDy1');
        else
            mfFname = [dirs.mfData sprintf('%03d',t) '_mf.mat']; % dxs, dys
            if ~exist(mfFname,'file')
                throw(MException(sprintf('mf file for frame No. %d was not found!\nPlease run EstimateVeloctyFields function @Step#1\n', t)))
            end
            load(mfFname);
            [clusters,ROIclusters,clustersMask,outImgDx1,outImgDy1] = doRegionGrowingSegmentCoordination(dxs,dys,params);    
        end  

        % Frame masking with clusters
        I = imread([dirs.images sprintf('%03d',t) '.tif'], 'tif');

        if clusters.nclusters > 0 
            allClustersMasks = zeros(length(clusters.allClusters{1,1}(:, 1)), length(clusters.allClusters{1,1}), 3);
            for clusterIDX = 1 : clusters.nclusters
                clusterColor = 30 * (clusterIDX^2);
                clusterMask = zeros(length(clusters.allClusters{1,1}(:, 1)), length(clusters.allClusters{1,1}), 3);
                clust = clusters.allClusters{1, clusterIDX};
                for imRowIDX = 1: length(clusters.allClusters{1,1}(:, 1))
                    for imColIDX = 1: length(clusters.allClusters{1,1})
                        if clust(imRowIDX, imColIDX) > 0
                            I(imRowIDX, imColIDX) = I(imRowIDX, imColIDX) + clusterColor;
                        end
                    end
                end
                allClustersMasks = allClustersMasks + clusterMask;
            end
        end

        if size(I,3) > 1
            tmp = I(:,:,1) - I(:,:,2);
            assert(sum(tmp(:)) == 0);
            I = I(:,:,1);
        end
        hold on; 
        h = figure('visible','off'); imagesc(I); colormap(gray);
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


        writeVideo(vidWriterObj, im2uint8(movieFrame.cdata));
        save(coordinationFname,'clusters','ROIclusters','clustersMask','outImgDx1','outImgDy1');
        hold off;
    end
    close(vidWriterObj);

end
