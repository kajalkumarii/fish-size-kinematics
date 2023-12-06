clearvars
close all
clc

%% Add path

pathName = 'ADD_PATH_TO_DATA_FOLDER_HERE';
addpath pathName
folder = dir(pathName);
sorted_folder = natsortfiles(folder(3:end)); % Use third-party function to get the files sorted (see function help)
addpath(genpath('ADD_PATH_TO_THE_FOLDER_I_SENT_YOU')) 

%% Load datasets and create data structures
clc

for ifile = 1:numel(sorted_folder)
    disp(['Compressing data file number ',num2str(ifile),' ...'])
    if sorted_folder(ifile).bytes<150000000 % if the file is less than 15 MB, skip it
        warning('File size is less than 15 MB. Skipped.')
        continue
    end
    thisFile = readtable(sorted_folder(ifile).name);
    rawdata = table2struct(thisFile,'ToScalar',true);
    dt = 0.01;

    fishNum = ifile; % !!!!!!!!! GET A UNIQUE NUMBER FOR EACH FISH DEPENDING ON THE TOTAL NUMBER OF FILES

temp_sessCode = rawdata.exp_uuid(1);
sessCode = {temp_sessCode{:}(1:10)};

    fs = 100;
    smoothingWin = 10;
    time = (1:numel(rawdata.real_fish_x))/fs;
    % 5-point stencil and bout detection:
    [pks,plocs,bls,blocs,smoothSp] =...
        detect_bouts(rawdata.real_fish_x,rawdata.real_fish_y,dt,fs,smoothingWin);
    [v_pks,v_plocs,v_bls,v_blocs,v_smoothSp] =...
        detect_bouts(rawdata.osg_fish1_x,rawdata.osg_fish1_y,dt,fs,smoothingWin,1);

    % Generate data structure with information aligned to each burst of the
    % real fish and of the virtual fish:

    if exist('sessCode','var') % create field "sessCode" only if there is a session code
        % Real fish:
        temp_fdata = create_fish_structure(rawdata,time,pks,plocs,bls,blocs,v_smoothSp,fishNum,sessCode);
        % Virtual fish:
%         temp_vdata = create_fish_structure(rawdata,time,v_pks,v_plocs,v_bls,v_blocs,smoothSp,fishNum,sessCode);
    else
        % Real fish:
        temp_fdata = create_fish_structure(rawdata,time,pks,plocs,bls,blocs,v_smoothSp,fishNum);
        % Virtual fish:
%         temp_vdata = create_fish_structure(rawdata,time,v_pks,v_plocs,v_bls,v_blocs,smoothSp,fishNum);
    end

    if temp_fdata.brs.ts(end)>time(end)
        warning('!!!!!!!!!!!!!!!!!TIMESTAMPS ARE BEYOND THE TIME RANGE!!!!!!!!!!!!!!!!!!')
    end

    % Concatenate:
    if ifile>1
        fdata = cat_struct(fdata,temp_fdata);
%         vdata = cat_struct(vdata,temp_vdata);
    elseif ifile==1
        fdata = temp_fdata;
%         vdata = temp_vdata;
    end
end

save('PATH_WHERE_YOU_WANT_TO_SAVE_AND_NAME_OF_OUTPUT_FILE','fdata')
