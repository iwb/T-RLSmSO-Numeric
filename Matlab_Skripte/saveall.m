if (strcmp(getenv('COMPUTERNAME'), 'POONS'))
    mphsave(model, 'E:\DA_Heins\transfer\model.mph');
    clearvars ans model Solver geometry cone;

    save('E:\DA_Heins\transfer\workspace.mat');  
else
    mphsave(model, 'C:\Users\Julius\SkyDrive\DA_Transfer\model.mph');
    clearvars ans model Solver geometry cone;

    save('C:\Users\Julius\SkyDrive\DA_Transfer\workspace.mat');    
end