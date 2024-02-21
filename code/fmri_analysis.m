%% fMRI analysis script for:
%% The transformation of sensory to perceptual braille letter representations 
%% in the visually deprived brain

% Marleen Haupt and Monika Graumann
% 22.02.2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preprocessed fMRI data has to be downloaded to data folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;

% paths
addpath(genpath('../code/'));

tic

% roi labels
rois = {'EVC','V4','LOC','LFA_10mm','VWFA_10mm','S1','S2','aIPS','pIPS','insula'};

% subjects
subjects = {1 2 3 4 5 6 7 8 9 10 12 13 15 16 17};

% preallocate matrices
allacross     = nan(length(subjects),length(rois));
allwithin     = nan(length(subjects),length(rois));


%% Run decoding for all subjects and regions of interest
for iroi = 1:length(rois)   
    %define roi
    roi = rois{iroi};
    
    for isub = 1:length(subjects)
        %define subject
        subject = subjects{isub};
        
        %%ROI decoding
        [results]=decoding_roi(subject,roi);
        %within-hand
        allwithin(isub,iroi) = results.within;
        %across-hand
        allacross(isub,iroi) = results.across;
        %difference
        alldiff(isub,iroi) = results.within - results.across;
        %RDM
        RDM(isub,iroi,:,:,:,:) = results.RDM;
    end
    
    %% Signrank test
    %within-hand
    [p_w(iroi), h_w(iroi),stats_w(iroi)] = signrank(allwithin(:,iroi),0,'tail','right');
    %across-hand
    [p_a(iroi), h_a(iroi),stats_a(iroi)] = signrank(allacross(:,iroi),0,'tail','right');
    %within-across hand
    [p_d(iroi), h_d(iroi),stats_d(iroi)] = signrank(alldiff(:,iroi),0,'tail','right');
    
end

%% save RDM for RSA
save('../output/MRI_RDM.mat','RDM');

%% FDR correction
%within-hand
[mask_w, crit_p_w, adj_ci_w, adj_p_w] = fdr_bh(p_w,0.049,'pdep');
%across-hand
[mask_a, crit_p_a, adj_ci_a, adj_p_a] = fdr_bh(p_a,0.049,'pdep');
%within-across hand
[mask_d, crit_p_d, adj_ci_d, adj_p_d] = fdr_bh(p_d,0.049,'pdep');

toc

%% save csv files for plotting in R
csvwrite('../output/allroi_within.csv',allwithin)
csvwrite('../output/allroi_across.csv',allacross)
csvwrite('../output/allroi_diff.csv',alldiff)
