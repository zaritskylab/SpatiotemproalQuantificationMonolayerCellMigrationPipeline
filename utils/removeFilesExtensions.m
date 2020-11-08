function [filenamesNoExt] = removeFilesExtensions(fileFNames)
    for fileIDX = 1 : length(fileFNames)
        [path, filename, ext] = fileparts(fileFNames(fileIDX));
        fileFNames(fileIDX) = filename;
    end
    filenamesNoExt = fileFNames;
end
