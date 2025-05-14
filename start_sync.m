%% BIDIRECTIONAL SYNC FILES
%sync files in both folder, resulting in an identical two folders
folderA = 'C:\Users\Yanjun Sun\Desktop\Writing_grants\Simons';
folderB = 'C:\Users\Yanjun Sun\OneDrive - Stanford\Writing_grants\SCGB_TTI_2024';
bidirectional_sync_files(folderA, folderB);

%% ONE DIRECTIONAL SYNC FILES
%only copy files in one folder to another folder (from A to B)
folderA = 'C:\Users\Yanjun Sun\Desktop\FolderA';
folderB = 'C:\Users\Yanjun Sun\Desktop\FolderB';
onedirectional_sync_files(folderA, folderB);