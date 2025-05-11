function bidirectional_sync_files(folderA, folderB)
% BIDIRECTIONAL_SYNC_FILES Bidirectionally synchronize two folders including subfolders.
%
%   BIDIRECTIONAL_SYNC_FILES(FOLDERA, FOLDERB) ensures both folders contain the
%   same files. It recursively compares file names and sizes. If files exist in only
%   one folder, they are copied to the other. If a file with the same name exists in both
%   but has different sizes, the newer file (based on modification time) is copied.
%
%   Features:
%     - All file types are included
%     - Subfolders are created as needed (empty folders are ignored)
%     - Skips files with identical name and size
%     - Automatically resolves conflicts based on last modified time
%
%   Inputs:
%     folderA - full path to the first folder (string or char)
%     folderB - full path to the second folder (string or char)
%
%   Example:
%     bidirectional_sync_enhanced('C:\MyLocal', 'C:\MyOneDrive');
%   May 10, 2025; yanjuns@stanford.edu

    % Normalize paths
    folderA = fullfile(folderA, filesep);
    folderB = fullfile(folderB, filesep);

    % Get all files with relative paths
    filesA = getAllFiles(folderA);
    filesB = getAllFiles(folderB);

    % Map: relative path -> file info (keeping the original case)
    mapA = createFileMap(filesA);
    mapB = createFileMap(filesB);

    % All unique relative paths (case-insensitive comparison)
    allFiles = unique([mapA.keys, mapB.keys]);

    for ii = 1:length(allFiles)
        relPath = allFiles{ii};

        % Case-insensitive check for file existence
        inA = false;
        inB = false;
        keyA = '';
        keyB = '';

        % Check in mapA
        keysA = mapA.keys;
        for jj = 1:length(keysA)
            if strcmpi(keysA{jj}, relPath)
                inA = true;
                keyA = keysA{jj};  % Exact key in mapA
                break;
            end
        end

        % Check in mapB
        keysB = mapB.keys;
        for jj = 1:length(keysB)
            if strcmpi(keysB{jj}, relPath)
                inB = true;
                keyB = keysB{jj};  % Exact key in mapB
                break;
            end
        end

        % Case: file only in A
        if inA && ~inB
            src = fullfile(folderA, keyA);
            dst = fullfile(folderB, keyA);
            ensureFolderExists(fileparts(dst));
            copyfile(src, dst);
            fprintf('Copied %s → B\n', keyA);

        % Case: file only in B
        elseif inB && ~inA
            src = fullfile(folderB, keyB);
            dst = fullfile(folderA, keyB);
            ensureFolderExists(fileparts(dst));
            copyfile(src, dst);
            fprintf('Copied %s → A\n', keyB);

        % Case: file in both
        elseif inA && inB
            fileA = mapA(keyA);
            fileB = mapB(keyB);

            if fileA.bytes == fileB.bytes
                % Files are the same → skip
                continue;
            else
                % Sizes differ → use newer file
                if fileA.datenum > fileB.datenum
                    src = fullfile(folderA, keyA);
                    dst = fullfile(folderB, keyA);
                    ensureFolderExists(fileparts(dst));
                    copyfile(src, dst);
                    fprintf('Updated %s → B (newer in A)\n', keyA);
                else
                    src = fullfile(folderB, keyB);
                    dst = fullfile(folderA, keyB);
                    ensureFolderExists(fileparts(dst));
                    copyfile(src, dst);
                    fprintf('Updated %s → A (newer in B)\n', keyB);
                end
            end
        end
    end

    disp('Bidirectional sync complete.');
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