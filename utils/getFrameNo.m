function [numberOfFrames] = getFrameNo(mainDirname,expname,ext)
    fname = [mainDirname filesep expname ext];
    if (strcmp(ext, '.tif'))
        info = imfinfo(fname);
        numberOfFrames = numel(info);
    elseif (strcmp(ext, '.zvi'))
        fname = [mainDirname name '.zvi'];
        data = bfopen(fname);
        images = data{1};
        numberOfFrames = size(images,1);
    elseif (strcmp(ext,'.lsm'))
        fname = [mainDirname name '.lsm'];
        stack = tiffread29(fname);
        numberOfFrames = length(stack);
    else
        numberOfFrames = 0;
    end
end