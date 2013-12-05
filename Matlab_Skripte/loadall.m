clear all;

if (strcmp(getenv('COMPUTERNAME'), 'POONS'))    
    load('E:\DA_Heins\transfer\workspace.mat');
    clearvars model Solver geometry;

    model = mphload('E:\DA_Heins\transfer\model.mph');
else
    load('C:\Users\Julius\SkyDrive\DA_Transfer\workspace.mat');
    clearvars model Solver geometry;

    model = mphload('C:\Users\Julius\SkyDrive\DA_Transfer\model.mph');
    
end
