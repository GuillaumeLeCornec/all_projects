% Central Idea
% This is the event characteristics script. For the consolidation events (ripple,spindle,delta) we
% are looking for in this pipeline, this script will help us find specific
% properties of those events. The properties are entropy, frequency,
% amplitude and duration.
%
% Code walkthrough:
% The code runs for the study days or dates of interest for all rats. Within the script, you will find loops for regions as well.
% For this project, the sleeping period was about 4 hours long and hence, the characteristics are found in four 1 hr bins.
% Apart from changing the directories, the main input data you need is the raw downsampled channel and the detection file for the events.
%
% Note: This script relies heavily on the data organization of the Genzel
% lab and results are stored according to the experimental paradigm

clearvars;
cd /vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/scripts1-4/

% sampling freq
fn = 600;
regions = {'HPC','PL', 'RSC'};

%bin size and number
bin_size = 60*60*fn;
bin_num = 4; % this will depend on the duration of your recording

for i_reg = 1:length(regions)
    reg = regions{i_reg};

    ripple_all_rats = [];
    spindle_all_rats = [];
    delta_all_rats = [];
    rats_all_reg_i = [];

    for i_rat=1:4
        if i_rat == 1
            new_dates_common = {20220923, 20220926, 20220927, 20220929,20221003,20221006,...
            20221010,20221012,20221013,20221014,20221018,20221021,20221024,20221025,...
            20221026,20221028,20221031,20221101,20221103,20221110,20221111};
        elseif i_rat == 2
            new_dates_common = {20220923, 20220926, 20220927, 20220929,20221003,20221006,...
            20221010,20221012,20221013,20221014,20221018,20221021,20221024,20221025,...
            20221026,20221028,20221031,20221101,20221103,20221110,20221111, 20221115,20221116,...
            20221117};
        else
            new_dates_common = {20220923, 20220926, 20220927, 20220929,20221003,20221006,...
            20221010,20221012,20221013,20221014,20221018,20221021,20221024,20221025,...
            20221026,20221028,20221031,20221101,20221103,20221110,20221111, 20221115,20221116,...
            20221117,20221122,20221123,20221124,20221128,20221201,20221206,20221207,...
            20221208,20221209,20221212};
        end
        new_dates_common = cellfun(@num2str,new_dates_common,'UniformOutput',false);
        rat = i_rat;
        detections_dir_rat = strcat("/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/Detections/",num2str(rat)); cd(detections_dir_rat);

        processed_dir_rat = strcat("/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/processed_data/Rat",num2str(rat));


        rat_i_all_dates=[];

        for date_ind = 1:length(new_dates_common)
            date = new_dates_common{date_ind};

            for i_sl = 1%:length(sleep_stages)
                sleep_stage = 'postsleep';

                %loading processed signal and detections for all events

                % processed signal (processed: artefacts removed)
                proc_dir_date_ss = (strcat(processed_dir_rat,'/',date,'/',sleep_stage)); 
                cd(proc_dir_date_ss)
                reg_file_names = {dir(proc_dir_date_ss).name}; 
                reg_file = reg_file_names{contains(reg_file_names,reg,'IgnoreCase',true)};

                %broadband signal/ downsampled channel
                proc_sig = load(reg_file).signals;

                % filtering the signal
                [a,b] = butter(3,[100/(fn/2) 299/(fn/2)]);%ripple
                [c,d] = butter(3, [9/(fn/2) 20/(fn/2)]);%spindle
                [e,f] = butter(3, [0.5/(fn/2) 4/(fn/2)]);%delta

                sig_filt_ripple = filtfilt(a,b,proc_sig);
                sig_filt_spindle = filtfilt(c,d,proc_sig);
                sig_filt_delta = filtfilt(e,f,proc_sig);

                %detection file for all events
                det_dir_ss = (strcat(detections_dir_rat,'/',date,'/',sleep_stage)); 
                cd(det_dir_ss)
                det_file_names = {dir(det_dir_ss).name}; 
                det_file = det_file_names{contains(det_file_names,reg,'IgnoreCase',true)};
                %load(det_file); 

                tab_i = [];
                if strcmpi(reg,'HPC')
                    for i = 1:length(det_file_names)
                        if contains(det_file_names(1, i), 'ripple')
                            ripple_dets = load(string(det_file_names(1, i)));
                            ripple_dets = ripple_dets.oscil_table;
                        end 
                    end
                else
                    ripple_dets = [];
                end

                for i = 1:length(det_file_names)
                    if contains(det_file_names(1, i), 'spindle')
                        if contains(det_file_names(1,i), reg)
                            spindle_dets = load(string(det_file_names(1, i)));
                            spindle_dets = spindle_dets.oscil_table;
                        end
                    end 
                end

                for i = 1:length(det_file_names)
                    if contains(det_file_names(1, i), 'delta')
                        if contains(det_file_names(1,i), reg)
                            delta_dets = load(string(det_file_names(1, i)));
                            delta_dets = delta_dets.oscil_table;
                        end
                    end 
                end

                % seperating detections in bins
                mask_all = [];
                for i_bin = 1:bin_num
                    % detections within the bins
                    if ~isempty(ripple_dets)
                        mask_ripple = ripple_dets(:,3) > bin_size*(i_bin-1) & ripple_dets(:,3) < bin_size*i_bin;
                    else
                        mask_ripple = [];
                    end

                    mask_spindle = spindle_dets(:,3) > bin_size*(i_bin-1) & spindle_dets(:,3) < bin_size*i_bin;
                    mask_delta = delta_dets(:,3) > bin_size*(i_bin-1) & delta_dets(:,3) < bin_size*i_bin;
                    if strcmpi(reg, 'HPC')
                        try
                            mask_ripple = table2array(mask_ripple); 
                        catch
                            continue
                        end
                    end

                    mask_spindle = table2array(mask_spindle); 
                    mask_delta = table2array(mask_delta);

                    if strcmpi(reg, 'HPC')
                        result_ripple = ripple_dets(mask_ripple, :);
                        result_ripple = result_ripple{:,:};
                    else
                        result_ripple={};
                    end

                    result_spindle = spindle_dets(mask_spindle, :);
                    result_spindle = result_spindle{:,:};
                    result_delta = delta_dets(mask_delta, :);
                    result_delta = result_delta{:,:};

                    % waveforms for selected bin
                    waveforms_ripples = {}; 
                    waveforms_spindles = {};
                    waveforms_deltas = {};

                    
                    if ~isempty(result_ripple)
                        for c = 1:size(result_ripple,1)
                            if result_ripple(c,4) >= length(sig_filt_ripple) % avoiding length errors and not losing much info
                                result_ripple(c,4) = length(sig_filt_ripple)-1;
                            end
                            waveforms_ripples{c,1} = sig_filt_ripple(int32(result_ripple(c,2)+1):int32(result_ripple(c,4)+1));
                        end
                    end

                    if ~isempty(result_spindle)
                        for c = 1:size(result_spindle,1)
                            if result_spindle(c,4) >= length(sig_filt_spindle) % avoiding length errors and not losing much info
                                result_spindle(c,4) = length(sig_filt_spindle)-1;
                            end
                            waveforms_spindles{c,1} = sig_filt_spindle(int32(result_spindle(c,2)+1):int32(result_spindle(c,4)+1));
                        end
                    end

                    if ~isempty(result_delta)
                        for c=1:size(result_delta,1)
                            if result_delta(c,4) >=length(sig_filt_delta) % avoiding length errors and not losing much info
                                result_delta(c,4) = length(sig_filt_delta)-1;
                            end
                            waveforms_deltas{c,1} = sig_filt_delta(int32(result_delta (c,2)+1):int32(result_delta (c,4)+1));
                        end
                    end

                    %% characteristics for selected waveforms
                    %% entropy
                    % ripples
                    ent_ripples = cellfun(@(equis) entropy(equis),waveforms_ripples,'UniformOutput',false);
                    ent_ripples_bin(i_bin) = {vertcat(ent_ripples{:})};

                    % spindles
                    ent_spindles = cellfun(@(equis) entropy(equis),waveforms_spindles,'UniformOutput',false);
                    ent_spindles_bin(i_bin) = {vertcat(ent_spindles{:})};

                    % deltas
                    ent_deltas = cellfun(@(equis) entropy(equis),waveforms_deltas,'UniformOutput',false);
                    ent_deltas_bin(i_bin) = {vertcat(ent_deltas{:})};

                    %% frequency
                    % ripples
                    freq_ripples = cellfun(@(equis) (meanfreq(equis,fn)),waveforms_ripples,'UniformOutput',false);
                    freq_ripples_bin(i_bin) = {vertcat(freq_ripples{:})};

                    % spindles
                    freq_spindles = cellfun(@(equis) (meanfreq(equis,fn)), waveforms_spindles,'UniformOutput',false);
                    freq_spindles_bin(i_bin) = {vertcat(freq_spindles{:})};

                    % deltas
                    freq_deltas = cellfun(@(equis) (meanfreq(equis,fn)), waveforms_deltas,'UniformOutput',false);
                    freq_deltas_bin(i_bin) = {vertcat(freq_deltas{:})};

                    %% amplitude
                    % ripples
                    amp_ripples = cellfun(@(equis) max(abs(hilbert(equis))), waveforms_ripples,'UniformOutput',false);
                    amp_ripples_bin(i_bin) = {vertcat(amp_ripples{:})};


                    % spindles
                    amp_spindles = cellfun(@(equis) max(abs(hilbert(equis))), waveforms_spindles,'UniformOutput',false);
                    amp_spindles_bin(i_bin) = {vertcat(amp_spindles{:})};

                    % deltas
                    amp_deltas = cellfun(@(equis) max(abs(hilbert(equis))), waveforms_deltas,'UniformOutput',false);
                    amp_deltas_bin(i_bin) = {vertcat(amp_deltas{:})};

                    %% duration
                    %ripples
                    dur_ripples = (cellfun('length',waveforms_ripples)/fn);

                    dur_ripples_bin(i_bin) = {dur_ripples};

                    %spindles
                    dur_spindles = (cellfun('length',waveforms_spindles)/fn);
 
                    dur_spindles_bin(i_bin) = {dur_spindles};

                    %deltas
                    dur_deltas = (cellfun('length',waveforms_deltas)/fn);

                    dur_deltas_bin(i_bin) = {dur_deltas};

                end
            end

            %% ripple characteristics table

            if ~isempty(ent_ripples_bin)
                length_ev = cellfun(@length ,ent_ripples_bin);
                ripples_tab = [];
                % the variation in size of events is going be the same for each characteristic
                for i = 1:length(length_ev)
                    struct_temp.('Rat') = repmat(rat,length_ev(i),1);

                    struct_temp.('Date') = repmat(str2num(date),length_ev(i),1);
                    struct_temp.('Event_Type') = repmat('rip',length_ev(i),1);
                    struct_temp.('Bin') = repmat(strcat('Bin',num2str(i)),length_ev(i),1);
                    struct_temp.('Ent') = [ent_ripples_bin{i}];
                    struct_temp.('Frq') = [freq_ripples_bin{i}];
                    struct_temp.('Dur') = [dur_ripples_bin{i}];
                    struct_temp.('Amp') = [amp_ripples_bin{i}];
                    ripples_tab = [ripples_tab; struct2table(struct_temp)];
                    clear struct_temp
                end
            end

            %% spindles characteristics table
            spindles_tab = [];
            if ~isempty(ent_spindles_bin)
                length_ev = cellfun(@length ,ent_spindles_bin); % the variation in size of events is going be the same for each characteristic
                for i=1:length(length_ev)
                    struct_temp.('Rat') = repmat(rat,length_ev(i),1);
                    struct_temp.('Date') = repmat(str2num(date),length_ev(i),1);
                    struct_temp.('Event_Type') = repmat('spi',length_ev(i),1);
                    struct_temp.('Bin') =repmat(strcat('Bin',num2str(i)),length_ev(i),1);
                    struct_temp.('Ent') = [ent_spindles_bin{i}];
                    struct_temp.('Frq') = [freq_spindles_bin{i}];
                    struct_temp.('Dur') = [dur_spindles_bin{i}];
                    struct_temp.('Amp') = [amp_spindles_bin{i}];
                    spindles_tab = [spindles_tab; struct2table(struct_temp)];
                    clear struct_temp
                end
            end

            %% deltas characteristics table
            deltas_tab = [];
            if ~isempty(ent_deltas_bin)
                length_ev = cellfun(@length ,ent_deltas_bin); % the variation in size of events is going be the same for each characteristic
                for i = 1:length(length_ev)
                    struct_temp.('Rat') = repmat(rat,length_ev(i),1);
                    struct_temp.('Date') = repmat(str2num(date),length_ev(i),1);
                    struct_temp.('Event_Type') = repmat('del',length_ev(i),1);
                    struct_temp.('Bin') = repmat(strcat('Bin',num2str(i)),length_ev(i),1);
                    struct_temp.('Ent') = [ent_deltas_bin{i}];
                    struct_temp.('Frq') = [freq_deltas_bin{i}];
                    struct_temp.('Dur') = [dur_deltas_bin{i}];
                    struct_temp.('Amp') = [amp_deltas_bin{i}];
                    deltas_tab = [deltas_tab; struct2table(struct_temp)];
                    clear struct_temp
                end
            end

            if strcmpi(reg,'HPC')
                events_combined = [ripples_tab;spindles_tab;deltas_tab];
            else
                events_combined = [spindles_tab;deltas_tab];
            end

            disp('saving data for date')
            disp(date_ind)
            rat_i_all_dates = [rat_i_all_dates; events_combined];

        end

        rats_all_reg_i = [rats_all_reg_i; rat_i_all_dates];

    end

    %save file for region
    cd('/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/Characteristics')

    file_name = 'Chars_Current_Dates.xlsx';
    writetable(rats_all_reg_i,file_name,'Sheet',reg)

end