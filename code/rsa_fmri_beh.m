%% RSA fMRI-behavior script for:
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

% load fMRI data
% data dimensions: 15 subjects x 10 ROIs x 2 x 2 x 8 x 8
MRI=load('../output/MRI_RDM.mat');

% load indexing matrices
load('../code/helpers/indicator_across.mat'); 
load('../code/helpers/indicator_within.mat');

% across-hands: average across both decoding directions
A_hand1 = indicator_across;
A_hand1(1,2,:,:)=0;
A_hand2 = indicator_across;
A_hand2(2,1,:,:)=0;

mri_A_hand1 = MRI.RDM(:,:,A_hand1);
mri_A_hand2 = MRI.RDM(:,:,A_hand2);
mri_A = permute(((mri_A_hand1 + mri_A_hand2)/2),[3,2,1]);

% within-hands: average across both decoding directions
W_hand1 = indicator_within;
W_hand1(1,1,:,:)=0;
W_hand2 = indicator_within;
W_hand2(2,2,:,:)=0;

mri_W_hand1 = MRI.RDM(:,:,W_hand1);
mri_W_hand2 = MRI.RDM(:,:,W_hand2);
mri_W = permute(((mri_W_hand1 + mri_W_hand2)/2),[3,2,1]);

% difference
mri_D= mri_W - mri_A;

%% RSA

% preallocate matrices
within = nan(size(mri_W,3), size(mri_W,2));
across = nan(size(mri_A,3), size(mri_A,2));
diff = nan(size(mri_D,3), size(mri_D,2));

for isub = 1:size(mri_W,3)

    within(isub,:) = corr(beh_avg,mri_W(:,:,isub),'Type',method);
    across(isub,:) = corr(beh_avg,mri_A(:,:,isub),'Type',method);
    diff(isub,:) = corr(beh_avg,mri_D(:,:,isub),'Type',method);
   
end

%% Statistics

% Wilcoxon signed rank test

for iroi = 1:size(within,2)  
    [p_W(iroi), h_W(iroi)] = signrank(within(:,iroi),0,'tail','right');
    [p_A(iroi), h_A(iroi)] = signrank(across(:,iroi),0,'tail','right');
    [p_D(iroi), h_D(iroi)] = signrank(diff(:,iroi),0,'tail','right');   
end

% FDR correction
[mask_W, crit_p_W, adj_ci_W, adj_p_W] = fdr_bh(p_W,0.05,'pdep');
[mask_A, crit_p_A, adj_ci_A, adj_p_A] = fdr_bh(p_A,0.05,'pdep');
[mask_D, crit_p_D, adj_ci_D, adj_p_D] = fdr_bh(p_D,0.05,'pdep');

%% save csv files for plotting in R
csvwrite('../output/rsa_within.csv',within)
csvwrite('../output/rsa_across.csv',across)
csvwrite('../output/rsa_diff.csv',diff)