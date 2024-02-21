%% RSA EEG-behavior script for:
%% The transformation of sensory to perceptual braille letter representations 
%% in the visually deprived brain

% Marleen Haupt and Monika Graumann
% 22.02.2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RDMs are located in output folder
% (as a default setting or because they were generated
% in previous analysis steps)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;

% path
addpath(genpath('../code/'));

method     = 'Spearman';
alpha      = 0.05; % for correction
chance     = 0; % for cluster permutation test


%% load data
% load behavioural data (averaged over participants)
load('../output/behavior_subavg_avghand.mat');

% load EEG data
% data dimensions: 11 subjects x 110 time points x 2 x 2 x 8 x 8
EEG=load('../output/EEG_RDM.mat');

% load indexing matrices
load('../code/helpers/indicator_across.mat'); 
load('../code/helpers/indicator_within.mat');

% across-hands: average across both decoding directions
A_hand1 = indicator_across;
A_hand1(1,2,:,:)=0;
A_hand2 = indicator_across;
A_hand2(2,1,:,:)=0;

eeg_A_hand1 = EEG.RDM(:,:,A_hand1);
eeg_A_hand2 = EEG.RDM(:,:,A_hand2);
eeg_A = permute(((eeg_A_hand1 + eeg_A_hand2)/2),[3,2,1]);

% within-hands: average across both decoding directions
W_hand1 = indicator_within;
W_hand1(1,1,:,:)=0;
W_hand2 = indicator_within;
W_hand2(2,2,:,:)=0;

eeg_W_hand1 = EEG.RDM(:,:,W_hand1);
eeg_W_hand2 = EEG.RDM(:,:,W_hand2);
eeg_W = permute(((eeg_W_hand1 + eeg_W_hand2)/2),[3,2,1]);

% difference
eeg_D= eeg_W - eeg_A;

%% RSA

% preallocate matrices
within = nan(size(eeg_W,3), size(eeg_W,2));
across = nan(size(eeg_A,3), size(eeg_A,2));
diff = nan(size(eeg_D,3), size(eeg_D,2));

for isub = 1:size(eeg_W,3)

    within(isub,:) = corr(beh_avg,eeg_W(:,:,isub),'Type',method);
    across(isub,:) = corr(beh_avg,eeg_A(:,:,isub),'Type',method);
    diff(isub,:) = corr(beh_avg,eeg_D(:,:,isub),'Type',method);
   
end

bootstrapping_onsets_rsa(within,across,diff);