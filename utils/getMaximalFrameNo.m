function [maximalFrameNo] = getMaximalFrameNo(mainDirectory)
    allImageStacks = dir(mainDirectory);
    [allFilesPaths, filteredFileNames]= listDirs(mainDirectory, allImageStacks);
    
    maximalFrameNo = 0;
    for fileIDX = 1: length(allFilesPaths)
        fileFName = allFilesPaths(fileIDX);
        fileFName = fileFName{1};
        [filepath, filename, ext] = fileparts(fileFName);
        numOfFramesInFile = getFrameNo(filepath, filename, ext);
        if maximalFrameNo < numOfFramesInFile
            maximalFrameNo = numOfFramesInFile;
        end
    end
    
end

