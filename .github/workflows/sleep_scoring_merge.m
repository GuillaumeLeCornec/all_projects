function sleep_scoring_merge(Rat,date_preset)
% saves the appropriate sleep scoring files based on rat and date provided
% Usage: sleep_scoring_merge(1,'20221024')
% output is the concatenated sleep scoring file which is stored in the
% results_dir

d_main = '/vol/genzel/Rat/HM/Rat_HM_Ephys_TD'; %all rat data
results_dir = "/vol/genzel/Rat/HM/Rat_HM_Ephys_TD/Rat_HM_Ephys_TD_Analysis_RM/rats1-4/sleep_states1-4/";

if (Rat >=1 && Rat <=4)
    txt = 'Rat_HM_Ephys_TD_OpenEphysRecordings_R1-4';
    Rat_str = strcat('Rat',num2str(Rat));
else
    txt = 'Rat_HM_Ephys_TD_OpenEphysRecordings_R5-8';
    Rat_str = strcat('Rat',num2str(Rat));
end

%% Getting to the right main directory
d_main_rat = strcat(d_main,'/',txt);

d_main_rat_date = strcat(d_main_rat,'/Rat_HM_Ephys_TD_R1-4_',date_preset);

folders = dir(d_main_rat_date); 
folders = {folders.name};
all_rat_ss_ind = contains(folders,'.mat'); 
all_rat_ss_files = folders(all_rat_ss_ind);

% finding both pre and post sleep scoring files for all rats
Rat_ind = contains(all_rat_ss_files,Rat_str); 
Rat_files = all_rat_ss_files(Rat_ind);

current_rat = Rat_files;

pre_s_ind = contains(current_rat,'presleep'); 
pre_s_files = current_rat(pre_s_ind);
post_s_ind = contains(current_rat,'postsleep'); 
post_s_files = current_rat(post_s_ind);

%Merging presleep (save as you merge in the ss directory)
cd(d_main_rat_date)
presleep = [];
for i3 = 1:length(pre_s_files)
    x = pre_s_files{i3};
    if contains(x,'._')
        x = x(3:end);
    end
    presleep = [presleep load(x).states];
end

presleep_final = corrected_states(presleep); %this is the version we will store
disp('presleep file concatenated and corrected')

%Merging Postsleep/post trial files
postsleep = [];
for i3 = 1:length(post_s_files)
    x = post_s_files{i3};
    if contains(x,'._')
        x = x(3:end);
    end
    postsleep = [postsleep load(x).states];
end

postsleep_final = corrected_states(postsleep);
disp('postsleep file concatenated and corrected')

%% saving the files in the right place
cd(results_dir)
rat_dir = strcat(results_dir,'/',num2str(Rat));
mkdir(rat_dir);
cd(rat_dir);
date_spl = regexp(date_preset,'_','split');
date_dir = date_spl{end};
mkdir(date_dir);
cd(date_dir)

save(sprintf("Rat%d_presleep",Rat),"presleep_final")
save(sprintf("Rat%d_postsleep",Rat),"postsleep_final")

disp('files successfully saved')
end