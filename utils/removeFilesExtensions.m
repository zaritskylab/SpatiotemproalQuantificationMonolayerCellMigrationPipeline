function [filenamesNoExt] = removeFilesExtensions(fileFNames)
    for fileIDX = 1 : length(fileFNames)
        filepath = char(fileFNames(fileIDX));
        [path, filename, ext] = fileparts(filepath);
        fileFNames(fileIDX) = cellstr(filename);
    end
    filenamesNoEx t = fileFNames;
end
