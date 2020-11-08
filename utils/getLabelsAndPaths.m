%% GETLABELSANDPATHS Lists all kymograph labels and their paths
%   to use in step 4 demonstration. 
function [experimentsLabels, kymographsPaths] = getLabelsAndPaths(mainDirectory, measureToProcess)
    allSubDirectories = dir(fullfile([mainDirectory measureToProcess filesep], '*.mat'));
    experimentsLabels = {};
    kymographsPaths = {};
    foundFileIDX = 1;
    for fileIDX = 1 : length(allSubDirectories)
        if allSubDirectories(fileIDX).name == '.'
           continue;
        elseif allSubDirectories(fileIDX).name == ".."
           continue;
        end
        if ~isfile([mainDirectory measureToProcess filesep allSubDirectories(fileIDX).name]) || strcmp(allSubDirectories(fileIDX).name, '.DS_Store')
            continue;
        end
       kymographsPaths{foundFileIDX} = [mainDirectory measureToProcess filesep allSubDirectories(fileIDX).name];
       experimentsLabels{foundFileIDX} = allSubDirectories(fileIDX).name;
       foundFileIDX = foundFileIDX + 1;
    end
    temp = kymographsPaths;
    kymographsPaths = strings(length(kymographsPaths), 1);
    kymographsPaths = char(temp);
    temp = experimentsLabels;
    experimentsLabels = strings(length(experimentsLabels), 1);
    experimentsLabels = char(temp);
end