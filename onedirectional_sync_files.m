function onedirectional_sync_files(folderA, folderB)
    % Normalize paths
    folderA = fullfile(folderA, filesep);
    folderB = fullfile(folderB, filesep);

    % Get file lists
    filesA = getAllFiles(folderA);
    filesB = getAllFiles(folderB);

    % Create maps
    mapA = createFileMap(filesA);
    mapB = createFileMap(filesB);

    keysB = mapB.keys;

    for i = 1:length(filesA)
        fileA = filesA(i);
        relPath = fileA.relative;

        matchKey = findMatchingKey(keysB, relPath);
        if isempty(matchKey)
            % File does not exist in B → copy
            src = fullfile(folderA, relPath);
            dst = fullfile(folderB, relPath);
            ensureFolderExists(fileparts(dst));
            copyfile(src, dst);
            fprintf('Copied %s → B (new)\n', relPath);
        else
            fileB = mapB(matchKey);

            % Same name/type but different size → compare date
            if fileA.bytes ~= fileB.bytes
                if fileA.datenum > fileB.datenum
                    src = fullfile(folderA, relPath);
                    dst = fullfile(folderB, fileB.relative);  % use original case in B
                    ensureFolderExists(fileparts(dst));
                    copyfile(src, dst);
                    fprintf('Updated %s → B (newer in A)\n', relPath);
                end
            end
        end
    end

    disp('One-way sync with update complete.');
end

function matchKey = findMatchingKey(keys, targetKey)
    % Case-insensitive key match
    matchKey = '';
    for i = 1:length(keys)
        if strcmpi(keys{i}, targetKey)
            matchKey = keys{i};
            return;
        end
    end
end

function fileList = getAllFiles(baseDir)
    files = dir(fullfile(baseDir, '**', '*'));
    files = files(~[files.isdir]);

    excludePatterns = {
        '^\.DS_Store$'       % macOS hidden files
        '^~\$.*'             % temporary Office files
        '^Thumbs\.db$'       % Windows thumbnail cache
    };

    keep = true(1, length(files));
    for ii = 1:length(files)
        name = files(ii).name;
        for jj = 1:length(excludePatterns)
            if ~isempty(regexp(name, excludePatterns{jj}, 'once'))
                keep(ii) = false;
                break;
            end
        end
    end
    files = files(keep);

    for ii = 1:length(files)
        relPath = strrep(fullfile(files(ii).folder, files(ii).name), baseDir, '');
        relPath = regexprep(relPath, '^\\|/', ''); % remove leading slash
        files(ii).relative = relPath;
    end
    fileList = files;
end

function fileMap = createFileMap(fileList)
    fileMap = containers.Map();
    for ii = 1:length(fileList)
        fileMap(fileList(ii).relative) = fileList(ii);
    end
end

function ensureFolderExists(folderPath)
    if ~exist(folderPath, 'dir')
        mkdir(folderPath);
    end
end