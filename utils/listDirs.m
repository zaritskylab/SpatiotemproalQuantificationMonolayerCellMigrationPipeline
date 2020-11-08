function [paths, filteredNames] = listDirs(pathToFolder, filesNames)
    paths = {}; % strings(length(fileNames));
    filteredNames = {};
    foundFileIDX = 1;
    for fileIDX = 1 : length(filesNames)
       if filesNames(fileIDX).name == '.'
           continue;
       elseif filesNames(fileIDX).name == ".."
               continue;
       end
       if ~isfile([pathToFolder filesNames(fileIDX).name]) || strcmp(filesNames(fileIDX).name, '.DS_Store')
           continue;
       end
       paths{foundFileIDX} = [pathToFolder filesNames(fileIDX).name];
       filteredNames{foundFileIDX} = filesNames(fileIDX).name;
       foundFileIDX = foundFileIDX + 1;
    end
    temp = paths;
    paths = strings(length(paths), 1);
    paths = temp;
    temp = filteredNames;
    filteredNames = strings(length(filteredNames), 1);
    filteredNames = temp;
end