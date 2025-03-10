addpath('/store/users/skukies/TonalLang/lib/eeglab')
eeglab redraw
sub = 30
folder = sprintf('/store/data/non-bids/WLFO/VP%i/preprocessed/',sub)
EEG = pop_loadset('filename',fullfile(folder,sprintf('3_ITW_WLFO_subj%i_channelrejTriggersXensor.set',sub)));

EEG = pop_select(EEG,'nochannel',find({EEG.chanlocs.labels}=="AUX1"));
EEG = pop_select(EEG,'nochannel',find({EEG.chanlocs.labels}=="AUX2"));
%EEG = pop_select(EEG,'nochannel',find({EEG.chanlocs.labels}=="VEOG"));
%EEG = pop_select(EEG,'nochannel',find({EEG.chanlocs.labels}=="HEOG"));
mods = loadmodout15(sprintf('/store/data/non-bids/WLFO/VP%i/preprocessed/amica',sub));

model_index = 1;
EEG.icawinv = mods.A(:,:,model_index);
EEG.icaweights = mods.W(:,:,model_index);
EEG.icasphere = mods.S(1:size(mods.W,1),:);
EEG.icachansind = 1:size(EEG.data,1);
%%
% plot IC topoplots
pop_topoplot(EEG, 0, [1:10] ,'',[4 3] ,0,'electrodes','off');

EEG =eeg_checkset(EEG,'eventconsistency');


%% plot saccades: first define parameters

amp_range = [9.5 15.5]; 
is_L_saccade = {EEG.event.type} == "L_saccade"; % L_saccade means it is a saccade with the left eye
amps_in_range = [EEG.event.sac_amplitude]<=amp_range(2) & [EEG.event.sac_amplitude]>=amp_range(1);
valid_endtime = [EEG.event.endtime] < length(EEG.times); % some of the saccades have invalid endtimes beyond the range of the recording


% horizontal saccades
center_range_horiz = [1900 1940]; % center 1920
vertdiff_max = 500;
small_vertical = abs(([EEG.event.sac_startpos_y] -[EEG.event.sac_endpos_y]))<vertdiff_max;
start_center_horizontal = [EEG.event.sac_startpos_x]>=center_range_horiz(1) & [EEG.event.sac_startpos_x]<=center_range_horiz(2);

% vertical saccades
center_range_vert = [1040 1120]; % center 1080
horizdiff_max = 500;
small_horizontal = abs(([EEG.event.sac_startpos_x] -[EEG.event.sac_endpos_x]))<horizdiff_max;
start_center_vertical = [EEG.event.sac_startpos_y]>=center_range_vert(1) & [EEG.event.sac_startpos_y]<=center_range_vert(2);
% find(start_center & small_vertical & amps_in_range & is_L_saccade)

% to plot topoplot at specific index
% ix = 7481; figure,topoplot(EEG.data(:,round(EEG.event(ix).latency + 200))-EEG.data(:,round(EEG.event(ix).latency-200)),EEG.chanlocs)



%% plot horizontal saccades (with small vertical movement)

start_center = start_center_horizontal;
i_sac = start_center & small_vertical & amps_in_range & is_L_saccade & valid_endtime; idx_sac = find(i_sac)
figure
sgtitle(strcat("Horizontal saccades", " sub=", num2str(sub), " vert diff<=", num2str(vertdiff_max) ))
k =1; rows=ceil(sum(i_sac)/3); row=1; col=1;
for ix = idx_sac
    ax = subplot(rows,3,k);
    titletext = strcat("E" , num2str(ix) , "; start ", num2str(EEG.event(ix).sac_startpos_x), " ampl=", num2str(EEG.event(ix).sac_amplitude), ", xdiff=", num2str(EEG.event(ix).sac_endpos_x - EEG.event(ix).sac_startpos_x), "; ydiff= ", num2str(EEG.event(ix).sac_endpos_y - EEG.event(ix).sac_startpos_y))
    %titletext = strcat("E" , num2str(ix) , "; start ", num2str(EEG.event(ix).sac_startpos_x), " ampl=", num2str(EEG.event(ix).sac_amplitude), ", xdiff=", num2str(EEG.event(ix).sac_endpos_x - EEG.event(ix).sac_startpos_x), "; ydiff= ", num2str(EEG.event(ix).sac_endpos_y - EEG.event(ix).sac_startpos_y))
    topoplot(EEG.data(:,round(EEG.event(ix).endtime))-EEG.data(:,round(EEG.event(ix).latency)),EEG.chanlocs); title(textwrap(titletext,40))
    k=k+1
    ax.Position(2) = ax.Position(2)*0.85;
end


%% plot vertical saccades (with small horizontal movement)
start_center = start_center_vertical;
i_sac = start_center & small_horizontal & amps_in_range & is_L_saccade & valid_endtime; idx_sac = find(i_sac)
figure
sgtitle(strcat("vertical saccades", "; sub=", num2str(sub), "; horiz diff<=", num2str(horizdiff_max) ))
k =1;
for ix = idx_sac
    ax = subplot(ceil(sum(i_sac)/3),3,k);  
    titletext = strcat("E" , num2str(ix) , "; start ", num2str(EEG.event(ix).sac_startpos_y), " ampl=", num2str(EEG.event(ix).sac_amplitude), ", xdiff=", num2str(EEG.event(ix).sac_endpos_x - EEG.event(ix).sac_startpos_x), "; ydiff= ", num2str(EEG.event(ix).sac_endpos_y - EEG.event(ix).sac_startpos_y))
    topoplot(EEG.data(:,round(EEG.event(ix).endtime))-EEG.data(:,round(EEG.event(ix).latency)),EEG.chanlocs); title(titletext)
    k=k+1
    ax.Position(2) = ax.Position(2)*0.85;
end
