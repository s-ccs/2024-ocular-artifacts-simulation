addpath('/store/users/skukies/TonalLang/lib/eeglab')
eeglab redraw
sub = 23
folder = sprintf('/store/data/non-bids/WLFO/VP%i/preprocessed/',sub)
EEG = pop_loadset('filename',fullfile(folder,sprintf('3_ITW_WLFO_subj%i_channelrejTriggersXensor.set',sub)));

% tmp = load(fullfile(folder,'causal',sprintf('3_ITW_WLFO_subj%i_channelrejTriggersXensor.mat',sub)));

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

% plot IC over time
pop_eegplot( EEG, 0, 1, 1);

% plot data voer time
pop_eegplot( EEG, 1, 1, 1);

%%
params = checkBlinkerDefaults(struct(), getBlinkerDefaults(EEG));
params.signalTypeIndicator = 'UseLabels';
params.signalLabels={'heog','veog','fp1'  'f1'  'fp2'  'fz'  'fpz'  'f3'  'f4'  'f2'}

[EEG, com, blinks, blinkFits, blinkProperties, blinkStatistics, params] = pop_blinker(EEG,params);


EEG.old_event = EEG.event;
myCellArray = num2cell(blinks.signalData.blinkPositions(1,:)); % Convert to cell array
myStructArray = cell2struct(myCellArray, {'latency'}); % Create struct array

for e  = 1:length(myStructArray)
    myStructArray(e).type = 'blink';
end
EEG.event = myStructArray';
EEG =eeg_checkset(EEG,'eventconsistency');
EEGep = pop_epoch( EEG, {  }, [-0.3           1], 'newname', 'blinks', 'epochinfo', 'yes');

EEGep = pop_select(EEGep,'nochannel',find({EEGep.chanlocs.labels}=="VEOG"));

erp = trimmean(EEGep.data,20,'round',3);

erp_bslcorrected = erp - mean(erp(:,1:100),2);
erp_bslcorrected_normed = erp_bslcorrected./std(erp_bslcorrected);
erp_normed = erp./std(erp);
%%
t_ix = [100 137 151 164 175 186 221 260 480]
figure
subplot(2,2,1)
plot(erp')
xline(t_ix)
title("erp")
subplot(2,2,2)
plot(erp_bslcorrected')
xline(t_ix)
title("erp+bslcorrect")

subplot(2,2,3)
plot(erp_normed')
xline(t_ix)
title("erp std-normed")
subplot(2,2,4)
plot(erp_bslcorrected_normed')
xline(t_ix)
title("erp+bslcorrect std-normed")
%%


erp_plot = erp_bslcorrected_normed;
%erp_plot = erp_normed;
figure
k =1
for t = t_ix
    subplot(2,9,k)  
    
topoplot(erp_plot(:,t),EEG.chanlocs);
if t == 186
    k = k+1
    continue
end
subplot(2,9,k+9)  
k = k+1;

topoplot(erp_plot(:,t)-erp_plot(:,186),EEG.chanlocs);

end

%%
[coeff,score,latent,tsquared,explained,mu] = pca(erp');
explained(1:5)
figure
for p = 1:5
    subplot(1,5,p)
    topoplot(coeff(:,p),EEG.chanlocs);
end
%%
erp_ica = trimmean(EEGep.icaact,20,'round',3);
pop_topoplot(EEG, 0, [1:10] ,'blnks',[3 4] ,0,'electrodes','off');

figure,plot(erp_ica([1,2,3,4,5],:)')

%% find closest fixatio or saccade for x/y position
fix_events = EEG.old_event({EEG.old_event.type} == "L_fixation");
latlist_fix = [fix_events.latency];

for e = 1:length(EEG.event)
    blink_ev = EEG.event(e);
    [dist,ix] = min(blink_ev.latency - latlist_fix(latlist_fix<blink_ev.latency));
    if dist < EEG.srate*2  % X seconds distance is still fine
        e
        EEG.event(e).x = fix_events(ix).fix_avgpos_x;
        EEG.event(e).y = fix_events(ix).fix_avgpos_y;
    else
        EEG.event(e).x = NaN;
        EEG.event(e).y = NaN;
    end
end


%%
right_trials = [EEG.event.x]>2000;

left_trials = [EEG.event.x]<2000;
sum(right_trials)
sum(left_trials)


erp_ica_right = trimmean(EEGep.icaact(:,:,right_trials),20,'round',3);
erp_ica_left = trimmean(EEGep.icaact(:,:,left_trials),20,'round',3);
pop_topoplot(EEG, 0, [1:10] ,'blnks',[3 4] ,0,'electrodes','off');

figure,plot(erp_ica_right([1,2,3,4,5],:)')
figure,plot(erp_ica_left([1,2,3,4,5],:)')



%% plot left / right saccades (without vertical movement)


small_vertical = abs(([EEG.event.sac_startpos_y] -[EEG.event.sac_endpos_y]))<10;
is_saccade = {EEG.event.type} == "L_saccade";
amps = [EEG.event.sac_amplitude];

find(small_vertical & amps>15 & is_saccade)


ix = 7481; figure,topoplot(EEG.data(:,round(EEG.event(ix).latency + 200))-EEG.data(:,round(EEG.event(ix).latency-200)),EEG.chanlocs)