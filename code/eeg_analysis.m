%% EEG analysis script for:
%% The transformation of sensory to perceptual braille letter representations 
%% in the visually deprived brain

% Marleen Haupt and Monika Graumann
% 22.02.2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preprocessed EEG data has to be downloaded to data folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;

% path
addpath(genpath('../code/'));

subjects = {'02' '07' '10_pooled' '13_pooled' '14_pooled' '15' '16_pooled' '17_pooled' '18_pooled' '19_pooled' '20_pooled'};

for isub = 1:length(subjects)
    
    subject = subjects{isub};
        
    %%EEG decoding
    [results]=decoding_time(subject);
    %within-hand results (after baseline)
    within(isub,:) = results.within(:,1);
    %across-hand results
    across(isub,:) = results.across(:,1);
    %difference
    diff(isub,:) = results.within(:,1)-results.across(:,1);
    %RDM
    RDM(isub,:,:,:,:,:)=results.RDM;
end

%% save RDM for RSA
save('../output/EEG_RDM.mat','RDM');

%% statistics and plotting
bootstrapping_onsets_timedec(within,across,diff);