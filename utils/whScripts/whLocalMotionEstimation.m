function [] = whLocalMotionEstimation(params,dirs)

if exist([dirs.vfDataOrig filesep '001_vf.mat'],'file') && params.always   
    % unix(sprintf('rm %s',[dirs.vfDataOrig '*.mat']));
    delete([dirs.vfDataOrig '*.mat']);    
end

if exist([dirs.vfData filesep '001_vf.mat'],'file') && params.always    
    % unix(sprintf('rm %s',[dirs.vfData '*.mat']));    
    delete([dirs.vfData '*.mat']);
end

for t = params.minNFrames : params.nTime
    vfFname = [dirs.vfData sprintf('%03d',t) '_vf.mat'];
    
    if exist(vfFname,'file') && ~params.always
        fprintf(sprintf('fetching velocity estimation frame %d\n',t));
        continue;
    end
        
    fprintf(sprintf('velocity estimation frame %d\n',t));
    imgFname0 = [dirs.images sprintf('%03d',t) '.tif'];
    imgFname1 = [dirs.images sprintf('%03d',t+params.frameJump) '.tif'];
    I0 = imread(imgFname0);
    
    if ~exist(imgFname1,'file') % create from previous 
        % unix(sprintf('cp %s %s',imgFname0,imgFname1));
        copyfile(imgFname0, imgFname1);
    end
    
    I1 = imread(imgFname1);
    
    % Assumeing 3 same channels
    if size(I0,3) > 1
        tmp = I0(:,:,1) - I0(:,:,2);
        assert(sum(tmp(:)) == 0);
        I0 = I0(:,:,1);
        I1 = I1(:,:,1);
    end
    
    [dydx, dys, dxs, scores] = blockMatching(I0, I1, params.patchSize,params.searchRadiusInPixels,true(size(I0))); % block width, search radius,
    
    if params.fixGlobalMotion
        meanDxs = mean(dxs(~isnan(dxs)));
        meanDys = mean(dxs(~isnan(dxs)));
        if abs(meanDxs) > 0.5
            dxs = dxs - meanDxs;
        end
        if abs(meanDys) > 0.5
            dys = dys - meanDys;
        end
    end
    
    save(vfFname,'dxs', 'dys','scores');
    if params.showScoreHeatMaps
        figure;
        imagesc(scores); title(sprintf('frame %d match score',t));
        caxis([0.995,1]); colorbar;
        disp('Exporting figure via MATLAB print -dpdf (instead of export_fig)');
        outputFile = [dirs.vfScores sprintf('%03d',t) '_score'];
        print(outputFile, '-dpdf')
    end
    %     eval(sprintf('print -djpeg %s', outputFile));
    % if isunix
    %     outputFile = [dirs.vfScores sprintf('%03d',t) '_score.eps'];
    %     export_fig_biohpc(outputFile);
    % else
    
    % end
    close all;
end
end