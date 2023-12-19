%% This script creates an excel sheet containing the event counts for spindles, delta (and ripples) within all regions.
% The script also contains a "barcode" specifying the study day, whether or
% not it was a homecage session, etc. 

clearvars
cd /vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats5-8/Scripts/;
cd('/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/');
sheet = readtable('barcode.xlsx');

% sampling freq and binsize for counts
fn = 600;
bin_size = 60*60*fn; % 1 hour bins
bin_num = 4; % this will depend on the duration of your recording
rats = [1,2,3,4]; %,5,6,7,8];
rats_str = {'Rat1','Rat2', 'Rat3', 'Rat4',}; %'Rat5', 'Rat6', 'Rat7', 'Rat8'};

regions = {"HPC","PL","RSC"};
event_type = 'big';

if strcmpi(event_type,'big')
    detections_dir ="/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/Big_Detections/";
    results_dir = "/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/counts/Big_Det_counts/";
else
    detections_dir = "/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/Detections/";
    results_dir = "/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/counts/Test_Results/";
end


for i_region = 1:length(regions)
    reg = regions{i_region};
    % load the processed signal here
    for rat_i = 1:length(rats)
        if rat_i == 1
            new_dates_common = {20220923, 20220926, 20220927, 20220929,20221003,20221006,...
                20221010,20221012,20221013,20221014,20221018,20221021,20221024,20221025,...
                20221026,20221028,20221031,20221101,20221103,20221110,20221111};
            new_dates_common = cellfun(@num2str,new_dates_common,'UniformOutput',false);
            dates_str = new_dates_common;
        elseif rat_i == 2
            new_dates_common = {20220923, 20220926, 20220927, 20220929,20221003,20221006,...
                20221010,20221012,20221013,20221014,20221018,20221021,20221024,20221025,...
                20221026,20221028,20221031,20221101,20221103,20221110,20221111,20221115,...
                20221116,20221117};
            new_dates_common = cellfun(@num2str,new_dates_common,'UniformOutput',false);
            dates_str = new_dates_common;
        else
            new_dates_common = {20220923, 20220926, 20220927,20220929,20221003,20221006,...
                20221010,20221012,20221013,20221014,20221018,20221021,20221024,20221025,...
                20221026,20221028,20221031,20221101,20221103,20221110,20221111,20221115,...
                20221116,20221117,20221122,20221123,20221124,20221128,20221201,20221206,...
                20221207,20221208,20221209,20221212};
            new_dates_common = cellfun(@num2str,new_dates_common,'UniformOutput',false);
            dates_str = new_dates_common;
        end

        for i_date = 1:length(dates_str)
            date_current = dates_str{i_date};
            detections_dir_rat_date = strcat(detections_dir,'/',num2str(rats(rat_i)),'/',date_current,'/postsleep');
            cd(detections_dir_rat_date);
            fold_names = {dir(detections_dir_rat_date).name};
            ind = contains(fold_names,reg);
            disp(ind)
            for i = 1:length(ind)
                if ind(1,i) == 1
                    if contains(fold_names(i),'ripple')
                        oscil_table_ripple = load(string(fold_names(i)));
                    elseif contains(fold_names(i), 'spindle')
                        oscil_table_spindle = load(string(fold_names(i)));
                    elseif contains(fold_names(i), 'delta')
                        oscil_table_delta = load(string(fold_names(i)));
                    end
                end
            end

            final_var = (fold_names(i));

            detections_tables.(['Rat' num2str(rat_i)]) = final_var; %'final var' is the name of the struct that was loaded in the prev line
            
            %loading sleep scoring files
            event = 'no ripple'; %only needed for the Channel_Finder2.m script
            cd('/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/scripts1-4')
            ss_date_file = Channel_Finder2(rat_i,'postsleep',event, date_current).postsleep_final;
            
            %truncating the file for 4 hr bins
            hr = 60*60; % hr in seconds
            ss_date_file = ss_date_file(1:4*hr-4);
            ss_bin1 = ss_date_file(1:hr);
            ss_bin2 = ss_date_file(hr+1:2*hr);
            ss_bin3 = ss_date_file(2*hr+1:3*hr);
            ss_bin4 = ss_date_file(3*hr+1:end);
            ss_bins = {ss_bin1,ss_bin2,ss_bin3,ss_bin4};
            NREM_duration = cellfun(@(x) sum(x==3),ss_bins);
            
            %broadband signal/downsampled channel
            counts = struct();
            fields = rats_str;
            events_all = ["Ripples", "Spindles", "Deltas"];

            if strcmpi(reg,"HPC")
                events = events_all;
            else
                events = [events_all(2),events_all(3)];
            end

            % Finally doing the counting
            for i = 1:length(events)
                event = events(i);
                counts.(event).('Rat') = rats_str{rat_i};
                counts.(event).('Date') = date_current;
                for j = 1:bin_num
                    bin = ['bin' num2str(j)];
                    counts.(events(i)).(bin) = [];
                    %sleep scoring segment for this bin (for duration of
                    %NREM sleep)
                    duration_bin_mins = NREM_duration(j)/60;
                    field = rats_str{rat_i};
                    disp(field)
                    % this is where the detection file is used for each rat
                    rat_event = detections_tables.(field);
                    disp ('rat event')
                    disp (rat_event)
                    switch event
                        case "Ripples"
                            if strcmpi(event_type,'big')
                                disp('no ripples this time')
                                result = 0;
                            else %if contains(fold_names(i),'ripple')
                                disp('ok')
                                disp(oscil_table_ripple)
                                ripple_all=oscil_table_ripple.oscil_table;
                                % ripple_all = rat_event.ripple;
                                count_mask = ripple_all.Peak > bin_size*(j-1) & ripple_all.Peak < bin_size*j ;
                                result = height(ripple_all(count_mask, :));
                                % finding duration of NREM in this bin/hour
                                dets_bin_i= ripple_all(count_mask,:);
                                starts = dets_bin_i.Start;
                                ends = dets_bin_i.End;
                                if result == 0
                                    result = 0;
                                end
                            end
                        case "Spindles"
                            % spindle_all = rat_event.spindle;
                            spindle_all = oscil_table_spindle.oscil_table;
                            count_mask = spindle_all.Peak > bin_size*(j-1) & spindle_all.Peak < bin_size*j ;
                            result = height(spindle_all(count_mask, :));
                            % finding duration of NREM in this bin/hour
                            dets_bin_i= spindle_all(count_mask,:);
                            starts = dets_bin_i.Start;
                            ends = dets_bin_i.End;
                            if result == 0
                                result = 0;
                            end
                        case "Deltas"
                            % delta_all = rat_event.delta;
                            delta_all=oscil_table_delta.oscil_table;
                            count_mask = delta_all.Peak > bin_size*(j-1) & delta_all.Peak < bin_size*j;
                            result = height(delta_all(count_mask, :));
                            % finding duration of NREM in this bin/hour
                            dets_bin_i= delta_all(count_mask,:);
                            starts = dets_bin_i.Start;
                            ends = dets_bin_i.End;
                            if result == 0
                                result = 0;
                            end
                    end
                    counts.(events(i)).(bin)(end + 1,1) = result; %/duration_bin_mins; %rate of events
                    % counts.(events(i)).(bin)(end + 1) = sum(durations);
                end
            end
            count_rats(rat_i,i_date) = counts;
            % count_rats(rat_i,i_date) = durations;
        end
    end
    
    %% saving just durations (when saving durations of NREM; it doesn't matter what region or event so we picked one table  on random
    spindles = [count_rats.Spindles];
    sp_tab = struct2table(spindles); sp_tab = sortrows(sp_tab,'Rat');
    cd('/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis/Analysis_SN/Counts/Test_Results')
    writetable(sp_tab,'NREM_Rates_Dates.xlsx','Sheet','NREM_Rates(m)');
    
    %% in this part we save the events in an excel sheet
    if strcmpi(reg,'HPC') % all events are present
        if ~strcmp(event_type, 'big')
            ripples = [count_rats.Ripples];
        end

        spindles = [count_rats.Spindles];
        deltas = [count_rats.Deltas];

        if strcmp(event_type,'big')
            cd("/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/counts/Big_Det_counts/")
        else
            cd("/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/counts/Test_Results/")
        end
        file_name = strcat('Counts_Events_In_',reg,'.xlsx');
        if ~strcmp(event_type, 'big')
            rip_tab = struct2table(ripples);
            rip_tab = sortrows(rip_tab,'Rat');
            rip_tab.study_day = zeros(size(rip_tab, 1), 1);
            rip_tab.goal_location = zeros(size(rip_tab, 1), 1);
            rip_tab.session = zeros(size(rip_tab, 1), 1);
            rip_tab.homecage = zeros(size(rip_tab, 1), 1);
            rip_tab.homecage_number = zeros(size(rip_tab, 1), 1);
        end

        sp_tab = struct2table(spindles);
        sp_tab = sortrows(sp_tab,'Rat');
        del_tab = struct2table(deltas);
        del_tab = sortrows(del_tab,'Rat');

        sp_tab.study_day = zeros(size(sp_tab, 1), 1);
        sp_tab.goal_location = zeros(size(sp_tab, 1), 1);
        sp_tab.session = zeros(size(sp_tab, 1), 1);
        sp_tab.homecage = zeros(size(sp_tab, 1), 1);
        sp_tab.homecage_number = zeros(size(sp_tab, 1), 1);

        for k = 1:height(sp_tab)
            for l = 1:size(rats_str, 2)
                for m = 1:size(new_dates_common, 2)
                    if strcmp(sp_tab.Date(k), new_dates_common(m))
                        if strcmp(sp_tab.Rat(k), rats_str(l))
                            index = find(strcmp(sheet.file_name, strcat(rats_str(l), '_', new_dates_common(m))));
                            sp_tab.study_day(k) = sheet.study_day(index);
                            sp_tab.goal_location(k) = sheet.goal_location(index);
                            sp_tab.session(k) = sheet.session(index);
                            sp_tab.homecage(k) = sheet.homecage(index);
                            sp_tab.homecage_number(k) = sheet.homecage_number(index);
                        else
                            continue
                        end
                    else
                        continue
                    end
                end
            end
        end

        del_tab.study_day = zeros(size(del_tab, 1), 1);
        del_tab.goal_location = zeros(size(del_tab, 1), 1);
        del_tab.session = zeros(size(del_tab, 1), 1);
        del_tab.homecage = zeros(size(del_tab, 1), 1);
        del_tab.homecage_number = zeros(size(del_tab, 1), 1);

        for k = 1:height(del_tab)
            for l = 1:size(rats_str, 2)
                for m = 1:size(new_dates_common, 2)
                    if strcmp(del_tab.Date(k), new_dates_common(m))
                        if strcmp(del_tab.Rat(k), rats_str(l))
                            index = find(strcmp(sheet.file_name, strcat(rats_str(l), '_', new_dates_common(m))));
                            del_tab.study_day(k) = sheet.study_day(index);
                            del_tab.goal_location(k) = sheet.goal_location(index);
                            del_tab.session(k) = sheet.session(index);
                            del_tab.homecage(k) = sheet.homecage(index);
                            del_tab.homecage_number(k) = sheet.homecage_number(index);
                        else
                            continue
                        end
                    else
                        continue
                    end
                end
            end
        end

        if ~strcmp(event_type, 'big')
            for k = 1:height(rip_tab)
                for l = 1:size(rats_str, 2)
                    for m = 1:size(new_dates_common, 2)
                        if strcmp(rip_tab.Date(k), new_dates_common(m))
                            if strcmp(rip_tab.Rat(k), rats_str(l))
                                index = find(strcmp(sheet.file_name, strcat(rats_str(l), '_', new_dates_common(m))));
                                rip_tab.study_day(k) = sheet.study_day(index);
                                rip_tab.goal_location(k) = sheet.goal_location(index);
                                rip_tab.session(k) = sheet.session(index);
                                rip_tab.homecage(k) = sheet.homecage(index);
                                rip_tab.homecage_number(k) = sheet.homecage_number(index);
                            else
                                continue
                            end
                        else
                            continue
                        end
                    end
                end
            end
            writetable(rip_tab,file_name,'Sheet','Ripple_Counts');
        end
        writetable(sp_tab,file_name,'Sheet','Spindle_Counts');
        writetable(del_tab,file_name,'Sheet','Delta_Counts')
    else % for PL and RSC we only see spindles and deltas
        spindles = [count_rats.Spindles];
        deltas = [count_rats.Deltas];
        if strcmp(event_type,'big')
            cd("/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/counts/Big_Det_counts/")
        else
            cd("/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/counts/Test_Results/")
        end
        file_name = strcat('Counts_Events_In_',reg,'.xlsx');
        sp_tab = struct2table(spindles);
        sp_tab = sortrows(sp_tab,'Rat');
        del_tab = struct2table(deltas);
        del_tab = sortrows(del_tab,'Rat');

        sp_tab.study_day = zeros(size(sp_tab, 1), 1);
        sp_tab.goal_location = zeros(size(sp_tab, 1), 1);
        sp_tab.session = zeros(size(sp_tab, 1), 1);
        sp_tab.homecage = zeros(size(sp_tab, 1), 1);
        sp_tab.homecage_number = zeros(size(sp_tab, 1), 1);

        for k = 1:height(sp_tab)
            for l = 1:size(rats_str, 2)
                for m = 1:size(new_dates_common, 2)
                    if strcmp(sp_tab.Date(k), new_dates_common(m))
                        if strcmp(sp_tab.Rat(k), rats_str(l))
                            index = find(strcmp(sheet.file_name, strcat(rats_str(l), '_', new_dates_common(m))));
                            sp_tab.study_day(k) = sheet.study_day(index);
                            sp_tab.goal_location(k) = sheet.goal_location(index);
                            sp_tab.session(k) = sheet.session(index);
                            sp_tab.homecage(k) = sheet.homecage(index);
                            sp_tab.homecage_number(k) = sheet.homecage_number(index);
                        else
                            continue
                        end
                    else
                        continue
                    end
                end
            end
        end

        del_tab.study_day = zeros(size(del_tab, 1), 1);
        del_tab.goal_location = zeros(size(del_tab, 1), 1);
        del_tab.session = zeros(size(del_tab, 1), 1);
        del_tab.homecage = zeros(size(del_tab, 1), 1);
        del_tab.homecage_number = zeros(size(del_tab, 1), 1);

        for k = 1:height(del_tab)
            for l = 1:size(rats_str, 2)
                for m = 1:size(new_dates_common, 2)
                    if strcmp(del_tab.Date(k), new_dates_common(m))
                        if strcmp(del_tab.Rat(k), rats_str(l))
                            index = find(strcmp(sheet.file_name, strcat(rats_str(l), '_', new_dates_common(m))));
                            del_tab.study_day(k) = sheet.study_day(index);
                            del_tab.goal_location(k) = sheet.goal_location(index);
                            del_tab.session(k) = sheet.session(index);
                            del_tab.homecage(k) = sheet.homecage(index);
                            del_tab.homecage_number(k) = sheet.homecage_number(index);
                        else
                            continue
                        end
                    else
                        continue
                    end
                end
            end
        end

        writetable(sp_tab,file_name,'Sheet','Spindle_Counts');
        writetable(del_tab,file_name,'Sheet','Delta_Counts');
    end
    clear count_rats
end

beep