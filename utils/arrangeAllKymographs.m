function [allExpKymoFPath] = arrangeAllKymographs(mainFolder, allFilesPaths)
    allExpKymoFPath = [mainFolder 'AllExperimentsKymographs' filesep];
    [status, message] = rmdir(allExpKymoFPath, 's');
    mkdir(allExpKymoFPath);
    for fileIDX = 1 : length(allFilesPaths)
        dirFName = allFilesPaths(fileIDX);
        [mainDirname, expname, ext] = fileparts(dirFName{1});
        mkdir([allExpKymoFPath expname]);
        mkdir([allExpKymoFPath expname filesep 'kymographs']);
%         for all measures
        mkdir([allExpKymoFPath expname filesep 'kymographs' filesep 'speed']);
        mkdir([allExpKymoFPath expname filesep 'kymographs' filesep 'directionality']);
%         mkdir([allExpKymoFPath expname 'kymographs' filesep 'coordination']);
%         copy all kymograph to their new location
        copyfile([mainDirname filesep 'kymographs' filesep 'speed' filesep sprintf('%s_speedKymograph.mat', expname)], [allExpKymoFPath expname filesep 'kymographs' filesep 'speed'], 'f');
        copyfile([mainDirname filesep 'kymographs' filesep 'directionality' filesep sprintf('%s_directionalityKymograph.mat', expname)], [allExpKymoFPath expname filesep 'kymographs' filesep 'directionality'], 'f');
%         copyfile([mainDirname filesep 'kymographs' filesep 'coordination' sprintf('%s_coordinationKymograph.mat', expname)], [allExpKymoFPath expname 'kymographs' filesep 'coordination'], 'f');
    end
end

