% This script helps us use the preprocessed data and find detections for events of interest. For this Project
% % these are Ripples, Spindles and Deltas. Each event is detected using a separate function. The end result is
% % a table containing start peak and end points of these events. The points are in samples (time * sampling freq)

clear
cd /vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/scripts1-4
addpath /vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/scripts1-4/External_Functions/FMAToolbox-master/General/;
addpath /vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/scripts1-4/External_Functions/FMAToolbox-master/Analyses/;
addpath /vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/scripts1-4;
addpath /vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/scripts1-4/External_Functions/FMAToolbox-master/Helpers/;


% Results Dir
results_dir = "/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/Detections/";
regions = {'HPC','PL','RSC'};

sleep_stages = {'postsleep'}; %{'presleep','postsleep';

ripple_thresholds = 4; % [4.6, 5.25, 5, 4.7, 4.5, 4.9105, 5, 4.5, 5, 4.9105, 5, 5, 5, 4.7, 5, 5, 5, 5.35, 5];
spindle_thresholds = 2.5; % this is what the Zugaro script uses as default
delta_thresholds = [2, 1, 1.5, 0];

fn = 600; %sampling frequency

% rat ranges
rats = linspace(1,8,8);
rats1_4 = rats(1:4);

dates_dir_r1_4 = '/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_OpenEphysRecordings_R1-4';

% date presets
date_preset1_4=regexp('Rat_HM_Ephys_TD_1-4_20220929','_','split');

%% ONLY section that needs manipulation
region_chosen = 'HPC'; %to do: 'PL', 'RSC'

event_size = 'all'; %all or big

if strcmpi(event_size,'big')
    results_dir = "/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/Big_Detections/";
    % elseif strcmpi(event_size,'small')
    %     results_dir = "/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/Small_Detections/";
else
    results_dir= "/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/Detections/";%
end


for irat = 1:length(rats1_4)
    Rat = rats1_4(irat);
    disp('Running detection analysis for rat');
    disp(Rat);

    if irat == 1
        new_dates_common = {20220923, 20220926, 20220927, 20220929,20221003,20221006,...
            20221010,20221012,20221013,20221014,20221018,20221021,20221024,20221025,...
            20221026,20221028,20221031,20221101,20221103,20221110,20221111};
        new_dates_common = cellfun(@num2str,new_dates_common,'UniformOutput',false);
    elseif irat == 2
        new_dates_common = {20220923, 20220926, 20220927, 20220929,20221003,20221006,...
            20221010,20221012,20221013,20221014,20221018,20221021,20221024,20221025,...
            20221026,20221028,20221031,20221101,20221103,20221110,20221111,20221115,...
            20221116,20221117};
        new_dates_common = cellfun(@num2str,new_dates_common,'UniformOutput',false);
    else
        new_dates_common = {20220923, 20220926, 20220927,20220929,20221003,20221006,...
            20221010,20221012,20221013,20221014,20221018,20221021,20221024,20221025,...
            20221026,20221028,20221031,20221101,20221103,20221110,20221111,20221115,...
            20221116,20221117,20221122,20221123,20221124,20221128,20221201,20221206,...
            20221207,20221208,20221209,20221212};
        new_dates_common = cellfun(@num2str,new_dates_common,'UniformOutput',false);
    end

    for date_ind = 1:length(new_dates_common)


        date_preset = new_dates_common{date_ind};
        disp(date_preset)

        for i2=1:length(sleep_stages)

            sleep_stage=sleep_stages{i2};

            % getting pyramidal file for ripples
            direc="/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/processed_data/";
            rat_date_dir=strcat(direc,'Rat',num2str(Rat),'/',date_preset); cd(rat_date_dir);

            %sleep stage dir
            rat_ss = strcat(rat_date_dir,'/',sleep_stage);
            cd(rat_ss)
            file_names = {dir(rat_ss).name};
            HPC_ind = contains(file_names,'HPC');
            PL_ind = contains(file_names,'PL');
            RSC_ind = contains(file_names,'RSC');


            %%% major changes needed here, region is selected %%%%%%%
            if strcmpi(region_chosen,'HPC')
                range = [1 2 3];
                all_files = {file_names{HPC_ind}};
                processed_file = load(all_files{1});
                processed_file_raw = load(all_files{2});

            elseif strcmpi(region_chosen,'PL')
                range = [2 3];
                processed_file = load(file_names{PL_ind});

            elseif strcmpi(region_chosen,'RSC')
                range = [2 3];
                processed_file = load(file_names{RSC_ind});
            end

            disp('creating detections file for'); 
            disp(region_chosen)

            sigs_len = length(processed_file.signals);

            bins_num = 1;
            final_var = [];

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%% have cortico-hippocampal + FMA from zugaro lab in the directory %%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%
            for i1 = 1:length(range)
                ind = range(i1);
                switch ind
                    %% use STEM to use detection files over the signal v_sig_cat with v_time_cat; stem(delta peaks) ; drag and browse // deltas more
                    case 1 % we are now detecting ripples
                        event = 'ripple';
                        chosen_channel = processed_file;
                        disp('starting ripple detection')
                        
                        % Ripple detection
                        lims = chosen_channel.signals_indexes(1,:);
                        sig_pre = chosen_channel.signals(1, lims(1):lims(2));
                        
                        %%% incorporate thresholds for dates HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        % getting NREM concatenated states and output needed for
                        % Ripple detection
                        [~,~,Ripple_Out, detection_thresholds_ripples]= NREM_formatting(sig_pre,ripple_thresholds,Rat,sleep_stage,date_preset,'ripple');
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % tab_thresholds_ripples=[tab_thresholds_ripples, detection_thresholds_ripples];

                        S = Ripple_Out(:,1); E= Ripple_Out(:,2); M = Ripple_Out(:,3);

                        % [S, E, M] = findRipplesLisa(v_sig_cat, v_time_cat, detection_threshold, (detection_threshold)*(1/2), 600 ); % findLisaRipples is updated
                        r_spe = [S*fn, M*fn, E*fn] + lims(1);
                        r_num = length(M);

                        r_mark = ones(r_num,1)+1;

                        Type = cat(1,r_mark);
                        Start = cat(1, r_spe(:,1));
                        Peak = cat(1, r_spe(:,2));
                        End = cat(1, r_spe(:,3));

                        %%%% ask how this changes for spindles and deltas
                        Six_Start = Peak - 1800;
                        Six_Start = Start - Six_Start;
                        Six_End = Peak + 1800;
                        Six_End = 3601 - (Six_End - End);
                        Sleep_State = processed_file.sleep_states(1,int64(Peak))';
                        Bin = ceil(Peak /(sigs_len / bins_num));
                        oscil_table = table(Type, Start, Peak, End, Six_Start, Six_End, Sleep_State, Bin);
                        oscil_table = sortrows(oscil_table, 3);

                        final_var.ripple = oscil_table;

                        results_dir_rat_date = strcat(results_dir,'/',num2str(Rat),'/',date_preset);
                        mkdir(results_dir_rat_date); 
                        cd(results_dir_rat_date);
                        ss_dir = strcat(results_dir_rat_date,'/',sleep_stage); 
                        mkdir(ss_dir); 
                        cd(ss_dir)

                        result_file = [num2str(Rat),'_', region_chosen,'_', event,'_', '.mat'];
                        save(fullfile(ss_dir, result_file), 'oscil_table');

                        disp('ripple detection file now saved')

                    case 2 % we are now detecting spindles

                        disp('we are now detecting spindles')
                        event = 'spindle';
                        if strcmpi(region_chosen,'HPC')
                            chosen_channel = processed_file_raw;
                        else
                            chosen_channel = processed_file;
                        end

                        lims = chosen_channel.signals_indexes(1,:);

                        %%%%%%%%%%%%%%%%%%% Should the signal below be bandpassed in the spindle range %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %% Big Events
                        event_size = 'big';
                        sig_pre = chosen_channel.signals(1, lims(1):lims(2));
                        sig_pre = bandpass(sig_pre, [9 20], 600);

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% change thresholds with respect to dates here %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        [v_time_cat, v_sig_cat,~] = NREM_formatting(sig_pre,0,Rat,sleep_stage,date_preset,event);
                        sig_pre_big = sig_pre;

                        %% use STEM to use detection files over the signal v_sig_cat with v_time_cat; stem(delta peaks) ; drag and browse // deltas more
                        filtered_spindle = [v_time_cat v_sig_cat];

                        [Spind_detect] = FindSpindlesChronic(filtered_spindle, spindle_thresholds, event_size);


                        Spind_detect = FindSpindlesChronic(filtered_spindle, spindle_thresholds, event_size);
                        disp(numel(Spind_detect))
                        Spind_detect(:,4) = [];
                        Spind_detect = Spind_detect*fn;

                        spind_spe = Spind_detect + lims(1);
                        spind_num = length(Spind_detect(:,2));

                        spind_mark = ones(spind_num,1)+1;

                        Type = cat(1,spind_mark);
                        Start = cat(1, spind_spe(:,1));
                        Peak = cat(1, spind_spe(:,2));
                        End = cat(1, spind_spe(:,3));

                        oscil_table = table(Type, Start, Peak, End);
                        oscil_table = sortrows(oscil_table, 3);

                        for i = 1:size(oscil_table, 1)
                            if oscil_table.End(i) >= size(sig_pre_big)
                                oscil_table(i, :) = [];
                            end
                        end

                        final_var.spindleBig = oscil_table;


                        results_dir = "/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/Big_Detections";
                        results_dir_rat_date = strcat(results_dir,'/',num2str(Rat),'/',date_preset);
                        mkdir(results_dir_rat_date); 
                        cd(results_dir_rat_date);
                        ss_dir = strcat(results_dir_rat_date,'/',sleep_stage); 
                        mkdir(ss_dir); 
                        cd(ss_dir)

                        result_file = [num2str(Rat),'_', region_chosen,'_', event,'_', '.mat'];
                        save(fullfile(ss_dir, result_file), 'oscil_table');
                        disp('Big spindle detection file now saved')

                        sig_pre_spindle_ind = [1:size(sig_pre, 2)];
                        [v_time_cat, v_sig_cat,~ ] = NREM_formatting(sig_pre_spindle_ind,0,Rat,sleep_stage,date_preset,event);
                        filtered_spindle_ind = [v_sig_cat];
                        filtered_spindle_small = filtered_spindle;
                        filtered_spindle_small(:, 3) = filtered_spindle_ind;
                        start = [];
                        stop = [];

                        for q = 1:height(oscil_table)
                            try
                                start(q) = find(filtered_spindle_small(:, 3) == int32(oscil_table.Start(q)));
                            catch
                                start(q) = find(filtered_spindle_small(:, 3) == int32(oscil_table.Start(q)+1));
                            end

                            try
                                stop(q) = find(filtered_spindle_small(:, 3) == int32(oscil_table.End(q)));
                            catch
                                stop(q) = find(filtered_spindle_small(:, 3) == int32(oscil_table.End(q)+1)); 
                            end

                            filtered_spindle_small(start(q):stop(q), :) = [];
                        end

                        filtered_spindle_small(:, 3) = [];

                        event_size = 'all';
                        % find new threshold
                        threshold_small_real = mean(filtered_spindle_small(:, 2)) + 2.5*std(filtered_spindle_small(:, 2));
                        threshold_spindles_new = (threshold_small_real - mean(filtered_spindle(:, 2)))/std(filtered_spindle(:, 2));
                        
                        [~, used_threshold] = FindSpindlesChronic(filtered_spindle,threshold_spindles_new, event_size);

                        Spind_detect = FindSpindlesChronic(filtered_spindle,threshold_spindles_new, event_size);
                        disp(numel(Spind_detect))
                        Spind_detect(:,4) = [];
                        Spind_detect = Spind_detect*fn;

                        spind_spe = Spind_detect + lims(1);
                        spind_num = length(Spind_detect(:,2));
                        
                        spind_mark = ones(spind_num,1)+1;

                        Type = cat(1,spind_mark);
                        Start = cat(1, spind_spe(:,1));
                        Peak = cat(1, spind_spe(:,2));
                        End = cat(1, spind_spe(:,3));

                        oscil_table = table(Type, Start, Peak, End);
                        oscil_table = sortrows(oscil_table, 3);

                        final_var.AllSpindles = oscil_table;

                        results_dir = "/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/Detections";
                        results_dir_rat_date = strcat(results_dir,'/',num2str(Rat),'/',date_preset);
                        mkdir(results_dir_rat_date); 
                        cd(results_dir_rat_date);
                        ss_dir=strcat(results_dir_rat_date,'/',sleep_stage); 
                        mkdir(ss_dir); 
                        cd(ss_dir)

                        result_file = [num2str(Rat),'_', region_chosen,'_', event,'_', '.mat'];
                        save(fullfile(ss_dir, result_file), 'oscil_table');

                        disp('spindle detection file now saved')

                    case 3 % deltas
                        %% use STEM to use detection files over the signal v_sig_cat with v_time_cat; stem(delta peaks) ; drag and browse // deltas more
                        event = 'delta';
                        disp('we are now detecting delta waves')
                        event_size='big';

                        if strcmpi(region_chosen,'HPC')
                            chosen_channel = processed_file_raw;
                        else
                            chosen_channel = processed_file;
                        end

                        lims = chosen_channel.signals_indexes(1,:);

                        %%%%%%%%%%%%%%%%%%% Should the signal below be bandpassed in the spindle range %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        sig_pre_delta = chosen_channel.signals(1, lims(1):lims(2));

                        % BPFering sig in delta range

                        sig_pre_delta=bandpass(sig_pre_delta,[0.5 4],600);

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        [v_time_cat, v_sig_cat,~ ] = NREM_formatting(sig_pre_delta,0,Rat,sleep_stage,date_preset,event);
                        sig_pre_delta_big = sig_pre_delta;

                        filtered_delta = [v_time_cat v_sig_cat];

                        [delta_detect] = FindDeltaWavesChronic([2 1 1.5 0],filtered_delta,event_size);

                        delta_detect(:,4)=[];  % we don't need the 4th column
                        delta_detect =  delta_detect*fn; % conversion to samples

                        delta_num = length(delta_detect(:,2));

                        delta_spe = delta_detect + lims(1);

                        delta_mark = ones(delta_num,1)+1;

                        Type = cat(1,delta_mark);
                        Start = cat(1, delta_spe(:,1));
                        Peak = cat(1, delta_spe(:,2));
                        End = cat(1, delta_spe(:,3));

                        %%%% ask how this changes for deltales and deltas
                        oscil_table = table(Type, Start, Peak, End);
                        oscil_table = sortrows(oscil_table, 3);

                        final_var.deltaBig = oscil_table;

                        results_dir = "/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/Big_Detections";
                        results_dir_rat_date = strcat(results_dir,'/',num2str(Rat),'/',date_preset);
                        mkdir(results_dir_rat_date); 
                        cd(results_dir_rat_date);
                        ss_dir = strcat(results_dir_rat_date,'/',sleep_stage); 
                        mkdir(ss_dir); 
                        cd(ss_dir)

                        result_file = [num2str(Rat),'_', region_chosen,'_', event,'_', '.mat'];
                        save(fullfile(ss_dir, result_file), 'oscil_table');



                        sig_pre_delta_ind = [1:size(sig_pre_delta, 2)];
                        [v_time_cat, v_sig_cat,~ ] = NREM_formatting(sig_pre_delta_ind,0,Rat,sleep_stage,date_preset,event);
                        filtered_delta_ind = [v_sig_cat];
                        filtered_delta_small = filtered_delta;
                        filtered_delta_small(:, 3) = filtered_delta_ind;
                        start = [];
                        stop = [];

                        for q = 1:height(oscil_table)
                            try
                                start(q) = find(filtered_delta_small(:, 3) == int32(oscil_table.Start(q)));
                            catch
                                start(q) = find(filtered_delta_small(:, 3) == int32(oscil_table.Start(q)+1)); %add 1 because indices in oscil_table are shifted by 1
                            end
                            try
                                stop(q) = find(filtered_delta_small(:, 3) == int32(oscil_table.End(q)));
                            catch
                                if strcmpi(date_preset, '20221018')
                                    stop(q) = find(filtered_delta_small(:, 3) == int32(oscil_table.End(q)-1));
                                else
                                    stop(q) = find(filtered_delta_small(:, 3) == int32(oscil_table.End(q)+1)); %add 1 because indices in oscil_table are shifted by 1
                                end
                            end

                            filtered_delta_small(start(q):stop(q), :) = [];
                        end

                        filtered_delta_small(:, 3) = [];
                        
                        %% Detect all with adapted thresholds
                        event_size = 'all';
                        tab_thresholds_delta_small_real = [];
                        tab_thresholds_delta_new = [];
                        for i = 1:length(delta_thresholds)
                            threshold_delta_small_real = mean(filtered_delta_small(:, 2))+(delta_thresholds(i))*std(filtered_delta_small(:, 2));
                            threshold_delta_new = (threshold_delta_small_real - mean(filtered_delta(:, 2)))/std(filtered_delta(:, 2));
                        end
                       
                        event_size = "small";

                        [~] = FindDeltaWavesChronic(tab_thresholds_delta_new,filtered_delta, event_size);

                        Delta_detect = FindDeltaWavesChronic(tab_thresholds_delta_new,filtered_delta, event_size);
                        disp(numel(Delta_detect))
                        Delta_detect(:,4) = [];
                        Delta_detect = Delta_detect*fn;

                        Delta_spe = Delta_detect + lims(1);
                        Delta_num = length(Delta_detect(:,2));

                        Delta_mark = ones(Delta_num,1)+1;

                        Type = cat(1,Delta_mark);
                        Start = cat(1, Delta_spe(:,1));
                        Peak = cat(1, Delta_spe(:,2));
                        End = cat(1, Delta_spe(:,3));

                        oscil_table = table(Type, Start, Peak, End);
                        oscil_table = sortrows(oscil_table, 3);

                        final_var.AllDelta = oscil_table;

                        results_dir = "/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/Detections";

                        results_dir_rat_date = strcat(results_dir,'/',num2str(Rat),'/',date_preset);
                        mkdir(results_dir_rat_date); 
                        cd(results_dir_rat_date);
                        ss_dir = strcat(results_dir_rat_date,'/',sleep_stage); 
                        mkdir(ss_dir); 
                        cd(ss_dir)

                        result_file = [num2str(Rat),'_', region_chosen,'_', event,'_', '.mat'];
                        save(fullfile(ss_dir, result_file), 'oscil_table');

                        disp('delta detection file now saved')
                end
            end
        end
    end
end

beep