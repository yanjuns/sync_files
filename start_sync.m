%% BIDIRECTIONAL SYNC FILES
%sync files in both folder, resulting in an identical two folders
folderA = 'C:\Users\Yanjun Sun\Desktop\K01';
folderB = 'C:\Users\Yanjun Sun\OneDrive - Stanford\Writing_grants\K01';
bidirectional_sync_files(folderA, folderB);

%% ONE DIRECTIONAL SYNC FILES
%only copy files in one folder to another folder
folderA = 'C:\Users\Yanjun Sun\Desktop\FolderA';
folderB = 'C:\Users\Yanjun Sun\Desktop\FolderB';
onedirectional_sync_files(folderA, folderB);