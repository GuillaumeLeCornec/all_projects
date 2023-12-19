% storing out from Signal_Merger.m (merged channels) in appropriate folders
% Way to run this script: 1. select event as 'delta' or 'spindle'- then just
% run for all days as it is, 2. select event as ripple and only run for hpc
% for all days again
clearvars
cd /vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/scripts1-4/
addpath /vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/scripts1-4/
addpath("/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/scripts1-4")

sleep_stages = {'post_sleep'};

dates_dir_r1_4= '/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_OpenEphysRecordings_R1-4';

date_r1_4_ch = 'Rat_HM_Ephys_TD_R1-4_';

new_dates_common = {20220923, 20220926, 20220927,20220929,20221003,20221006,...
     20221010,20221012,20221013,20221014,20221018,20221021,20221024,20221025,...
     20221026,20221028,20221031,20221101,20221103,20221110,20221111}; %Rat1

% new_dates_common = {20220923, 20220926, 20220927, 20220929,20221003,20221006,...
%     20221010,20221012,20221013,20221014,20221018,20221021,20221024,20221025,...
%     20221026,20221028,20221031,20221101,20221103,20221110,20221111,20221115,...
%     20221116,20221117}; %Rat2

% new_dates_common = q{20220923, 20220926, 20220927,20220929,20221003,20221006,...
%     20221010,20221012,20221013,20221014,20221018,20221021,20221024,20221025,...
%     20221026,20221028,20221031,20221101,20221103,20221110,20221111,20221115,...
%     20221116,20221117,20221122,20221123,20221124,20221128,20221201,20221206,...
%     20221207,20221208,20221209,20221212}; %Rat3&4

% no need to modify
new_dates_common = cellfun(@num2str,new_dates_common,'UniformOutput',false);

for i = 1:length(new_dates_common)
    new_dates_common{i} = strcat(date_r1_4_ch,new_dates_common{i});

    % checking if all dates are valid
    dir_i = strcat(dates_dir_r1_4,'/',new_dates_common{i});
    cd(dir_i)
end

date_preset1_4_vec = new_dates_common;

rats = linspace(1,8,8);
rats1_4 = rats(1:4);

result_dir_HPC = '/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/brain_regions1-4/HPC';
result_dir_PL = '/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/brain_regions1-4/PL';
result_dir_RSC = '/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/brain_regions1-4/RSC';


%% ONLY section that needs manipulation
rats_chosen = rats1_4;
regions = {'PL', 'RSC', 'HPC'};
event = 'spindle';


if strcmpi(event, 'ripple')
    regions = {'HPC'};
end

%%
for date_ind = 1:length(date_preset1_4_vec)
    dates_chosen = dates_dir_r1_4;
    date_preset_chosen = date_preset1_4_vec{date_ind};
    disp('beginning channel storing for date');
    disp(date_preset_chosen)

    for reg_ind = 1:length(regions)
        region = regions{reg_ind}; 
        if strcmpi(region,'HPC')
            result_dir_chosen = result_dir_HPC;
        elseif strcmpi(region,'PL')
            result_dir_chosen = result_dir_PL;
        else
            result_dir_chosen = result_dir_RSC;
        end

        dir_folders = getfolder();

        disp(strcat('starting process for:',region))
        for i2=1:length(rats_chosen)
            Rat = rats_chosen(i2);
            disp('saving channels for rat');
            disp(Rat)

            for i3 = 1:length(sleep_stages)
                ss = sleep_stages{i3};

                disp('storing concatenated channels for')
                disp(ss)

                [ss_concat_channel,channel_name] = Signal_Merger(Rat, region, event, ss, date_preset_chosen);
                chan_spl = regexp(channel_name,'.continuous','split');

                acq_fhz = 20000;
                ds_fhz = 600;

                %% Downsampling the channel before saving it
                % we dont low pass ripple channels as they were concatenated
                % in the ripple range

                if strcmpi(region,'HPC') && strcmpi(event,'ripple')
                    Data = ss_concat_channel;
                    downsamp_ch = downsample(Data,floor(acq_fhz/ds_fhz));
                    % delta and spindle events are low pass filtered
                else
                    % Design of low pass filter (we low pass to 300Hz for cortical regions only - hpc is already BPFed in the 100-300 Hz range)
                    Wn = ds_fhz/acq_fhz;       % Cutoff=fs_new/2 Hz.
                    [b,a] = butter(3,Wn);       % Filter coefficients for LPF.

                    Data = filtfilt(b, a, ss_concat_channel);
                    downsamp_ch = downsample(Data,floor(acq_fhz/ds_fhz));
                end

                ss_concat_channel = downsamp_ch;
                
                
                %%
                cd(result_dir_chosen)
                rat_dir = strcat(result_dir_chosen,'/',num2str(Rat));
                mkdir(rat_dir);
                cd(rat_dir)

                date_only = regexp(date_preset_chosen,'_','split');
                date_dir = strcat(rat_dir,'/',date_only{end});
                mkdir(date_dir);
                cd(date_dir)

                ss_dir = strcat(date_dir,'/',ss);
                mkdir(ss_dir);
                cd(ss_dir)
                tic
                disp('channel name is')
                disp(chan_spl{1})

                %% raw channels are named for delta and spindles; the other ones are ripple bandpassed
                if ~strcmpi(event,'ripple')
                    chan_spl{1} = strcat(chan_spl{1},'_raw');
                end
                save(chan_spl{1},"ss_concat_channel",'-v7.3')
                toc;
                disp('finished storing downsampled channel for');
                disp(ss)
            end
        end
    end
end
