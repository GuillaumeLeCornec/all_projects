%% ||| Pyramidal and Below-Pyramidal Data Preprocessing ||| %%
addpath '/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/scripts1-4'
clearvars

sleep_stages = {'postsleep'};

%dates 1-4 and 5-8
dates_dir_r1_4 = '/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_OpenEphysRecordings_R1-4';

date_r1_4_ch = '/Rat_HM_Ephys_TD_R1-4_';

new_dates_common = {20220923, 20220926, 20220927,20220929,20221003,20221006,...
     20221010,20221012,20221013,20221014,20221018,20221021,20221024,20221025,...
     20221026,20221028,20221031,20221101,20221103,20221110,20221111}; %Rat1

% new_dates_common = {20220923, 20220926, 20220927,20220929,20221003,20221006,...
%     20221010,20221012,20221013,20221014,20221018,20221021,20221024,20221025,...
%     20221026,20221028,20221031,20221101,20221103,20221110,20221111,20221115,...
%     20221116,20221117}; %Rat2

% new_dates_common = {20220923, 20220926, 20220927,20220929,20221003,20221006,...
%     20221010,20221012,20221013,20221014,20221018,20221021,20221024,20221025,...
%     20221026,20221028,20221031,20221101,20221103,20221110,20221111,20221115,...
%     20221116,20221117,20221122,20221123,20221124,20221128,20221201,20221206,...
%     20221207,20221208,20221209,20221212}; %Rat3&4

new_dates_common = cellfun(@num2str,new_dates_common,'UniformOutput',false);


for i=1:length(new_dates_common)
    new_dates_common{i} = strcat(date_r1_4_ch,new_dates_common{i});

    % % checking if all dates are valid
    dir_i = strcat(dates_dir_r1_4,'/',new_dates_common{i});
    cd(dir_i)
end

date_preset1_4 = new_dates_common;

rats = linspace(1,8,8);
rats1_4 = rats(1:4);


%%
regions = '/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/brain_regions1-4/';

bin_size = 1; % no time dependent effect
states_dirpath ='/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/sleep_states1-4/';


%% in cleandataset.m just for the purpose of testing thresholds, we need RAW hpc. modify this in the signalmerger script until u find the correct threshold then change it back

threshold_HPC_ripple = [2600,2000,2500,2400];
threshold_HPC_nonripple = [2600,1900,2500,2500]; % nonripple events
threshold_PL = [2500,2500,2400,2500]; % delta and spindle events - these channels were not bandpass filtered
threshold_RSC = [2500,2500,2400,2500];


%% Sharpwaves - Preprocessing: Cleaning %%
event = 'ripple'; %'delta' & 'spindle' has same preprocessing; ripple will change stuff since a different stored channel will be loaded
selected_regions = {'HPC','PL','RSC'};

if event == "ripple"
    selected_regions = {'HPC'};
end

for date_ind=1:length(date_preset1_4)

    date_preset_chosen = date_preset1_4{date_ind};
    date_preset = date_preset_chosen;
    date_spl = regexp(date_preset,'_','split');
    for ind = 1:length(rats1_4)

        Rat = rats1_4(ind);

        for i1 = 1:length(sleep_stages)

            sleep_stage = sleep_stages{i1};
            for i3 = 1:length(selected_regions)
                reg = selected_regions{i3};

                % Visually found artifact thresholds per rat
                if strcmpi(sleep_stage,'presleep')
                    threshold = 1300;
                else
                    if strcmpi(event,'ripple')
                        threshold = threshold_HPC_ripple(Rat);
                    elseif strcmpi(reg,'HPC') && (strcmpi(event,'spindle')|| strcmpi(event,'delta'))
                        threshold = threshold_HPC_nonripple(Rat);
                    elseif strcmpi(reg,'PL')
                        threshold = threshold_PL(Rat);
                    elseif strcmpi(reg,'RSC')
                        threshold = threshold_RSC(Rat);
                    end
                end

                switch i3
                    case 1
                        % path to directory where cleaned data will be saved
                        results_dir ='/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/cleaned_data/cleaned_data_HPC';
                        cd(results_dir);

                        rat_dir = strcat('Rat',num2str(Rat));mkdir(rat_dir);

                        cd(rat_dir); date_dir = date_spl{end}; mkdir(date_dir);cd(date_dir)

                        mkdir(sleep_stage); results_dir_fin=strcat(results_dir,'/',rat_dir,'/',date_dir,'/',sleep_stage);

                        disp('beginning preprocessing for HPC')

                        clean_dataset_test_rat(regions, selected_regions(i3),event, results_dir_fin, Rat, threshold, sleep_stage, date_preset); % sleep stage and date preset

                        %% Sharpwaves - Preprocessing: Alignment %%
                        region_dirpath = results_dir_fin;
                        [signals, sleep_states, signals_indexes, bins_num] = align_dataset_test_rat(region_dirpath,event, bin_size,Rat,sleep_stage, date_preset);

                        %% path to directory where processed  data will be saved
                        results_dir_align = strcat('/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/processed_data/Rat',...,
                            num2str(Rat),'/', date_dir,'/',sleep_stage);

                        mkdir(results_dir_align); cd(results_dir_align)

                        if ~strcmpi(event,'ripple')
                            save(fullfile(results_dir_align, ['processed_' ,selected_regions{i3}, num2str(Rat),'_raw','.mat']), 'signals', 'sleep_states', 'signals_indexes', 'bins_num', '-v7.3');
                        else
                            save(fullfile(results_dir_align, ['processed_' ,selected_regions{i3}, num2str(Rat),'.mat']), 'signals', 'sleep_states', 'signals_indexes', 'bins_num', '-v7.3');
                        end
                        
                        disp(['results saved for ',selected_regions{i3}])

                    case 2

                        results_dir ='/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/cleaned_data/cleaned_data_PL';

                        cd(results_dir);

                        rat_dir=strcat('Rat',num2str(Rat));
                        mkdir(rat_dir);

                        cd(rat_dir); 
                        date_dir=date_spl{end}; 
                        mkdir(date_dir);
                        cd(date_dir)

                        mkdir(sleep_stage); 
                        cd(sleep_stage)

                        results_dir_fin=strcat(results_dir,'/',rat_dir,'/',date_dir,'/',sleep_stage);

                        disp('beginning preprocessing for PL')

                        clean_dataset_test_rat(regions, selected_regions(i3),event, results_dir_fin, Rat, threshold,sleep_stage, date_preset); % sleep stage and date preset

                        %% Sharpwaves - Preprocessing: Alignment %%
                        
                        region_dirpath = results_dir_fin;
                        
                        [signals, sleep_states, signals_indexes, bins_num] = align_dataset_test_rat(region_dirpath,event, bin_size,Rat,sleep_stage, date_preset);

                        results_dir_align = strcat('/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/processed_data/Rat',...,
                            num2str(Rat),'/', date_dir,'/',sleep_stage);

                        mkdir(results_dir_align); 
                        cd(results_dir_align)

                        save(fullfile(results_dir_align, ['processed_' ,selected_regions{i3}, num2str(Rat) '.mat']), 'signals', 'sleep_states', 'signals_indexes', 'bins_num', '-v7.3');

                        disp(['results saved for ', selected_regions{i3}])

                    case 3
                        results_dir ='/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/cleaned_data/cleaned_data_RSC';

                        cd(results_dir);

                        rat_dir = strcat('Rat',num2str(Rat));
                        mkdir(rat_dir);

                        cd(rat_dir); 
                        date_dir=date_spl{end}; 
                        mkdir(date_dir);
                        cd(date_dir)

                        mkdir(sleep_stage); 
                        cd(sleep_stage)

                        results_dir_fin=strcat(results_dir,'/',rat_dir,'/',date_dir,'/',sleep_stage);

                        disp('beginning preprocessing for RSC')

                        clean_dataset_test_rat(regions, selected_regions(i3), event, results_dir_fin, Rat, threshold, sleep_stage, date_preset); % sleep stage and date preset

                        %% Sharpwaves - Preprocessing: Alignment %%

                        region_dirpath = results_dir_fin;
                        
                        [signals, sleep_states, signals_indexes, bins_num] = align_dataset_test_rat(region_dirpath, event, bin_size, Rat, sleep_stage, date_preset);

                        results_dir_align = strcat('/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/processed_data/Rat',...,
                            num2str(Rat),'/', date_dir,'/',sleep_stage);

                        mkdir(results_dir_align); 
                        cd(results_dir_align)

                        save(fullfile(results_dir_align, ['processed_', selected_regions{i3}, num2str(Rat) '.mat']), 'signals', 'sleep_states', 'signals_indexes', 'bins_num', '-v7.3');

                        disp(['results saved for ', selected_regions{i3}])
                end
            end
        end
    end
end

beep