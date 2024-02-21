function [EEGdec]=decoding_time(subject)
% EEG decoding of Braille letters within-hand and across-hand
% Marleen Haupt and Monika Graumann
% 22.02.2024

% Input:
%   subject: string, e.g. '02'

% start timer
tic

% paths
addpath(genpath('../code/'));
addpath(genpath('../toolboxes/libsvm'));

% load timepoints in data to time in ms converter
load('../code/helpers/timepoints.mat');

% load preprocessed data per subject
% data dimensions: 16 letters x 170 trials x 63 channels x 1100 timepoints
%CHANGE
load(sprintf('../data/EEG_preprocessed/s%s_ConditionEEGV3.mat',subject))

% remove potential additional eye channels (available for some subjects)
data = data(:,:,[1:63],:);

% define which time points to analyze
steps = 10; %steps for downsampling, 1=no downsampling
timewindow = 1:steps:length(timepoints);
data       = data(:,:,:,timewindow);

% define bins for pseudotrials
bins         = 5;
binsize      = round(size(data,2)/bins);

% classification parameters
chance_level = 50;
permutations = 5; %instead of 100 in original code
letters      = 8; 
hands        = 2;
train_col    = 1:bins-1;
test_col     = bins;
labels_train = vertcat(ones(length(train_col),1),2*ones(length(train_col),1) ); % label vectors for libsvm
labels_test  = vertcat(ones(length(test_col),1),2*ones(length(test_col),1));

% load RDM for indexing conditions from helpers folder
load('../code/helpers/index_matrix.mat');

% preallocate result matrix
RDM = single(nan(permutations,hands,hands,letters,letters,length(timewindow)));

% start decoding loop
for iperm =1:permutations
    
    % before each permutation, bin the data with random assignment of trials to bins
    perm_data   = data(:,randperm(size(data,2)),:,:); % randomize trial order
    binned_data = reshape(perm_data, [size(perm_data,1) binsize bins size(perm_data,3) size(perm_data,4)] ); clear perm_data
    binned_data = squeeze(nanmean(binned_data,2)); % average trials in bins to get new pseudo-trials
    
    % multivariate noise normalization and whitening
    [white_data] = mvnn_whitening(binned_data,1:bins-1); clear binned_data
    
    for handA = 1:hands
        for handB = 1:hands
            
            for letterA = 1:letters
                for letterB = 1:letters
                    
                    % output numbers between 1-16 to index data based on DM
                    trainA = find(X_DM(:,1)==letterA & X_DM(:,2)==handA);
                    trainB = find(X_DM(:,1)==letterB & X_DM(:,2)==handA);
                    
                    testA  = find(X_DM(:,1)==letterA & X_DM(:,2)==handB);
                    testB  = find(X_DM(:,1)==letterB & X_DM(:,2)==handB);
                    
                    % use to index conditions
                    traindataA = squeeze(white_data(trainA,:,:,:));
                    traindataB = squeeze(white_data(trainB,:,:,:));
                    
                    testdataA  = squeeze(white_data(testA,:,:,:));
                    testdataB  = squeeze(white_data(testB,:,:,:));
                    
                    [RDM(iperm,handA,handB,letterA,letterB,:)] = ...
                     traintest(traindataA,traindataB,testdataA,testdataB,timewindow,labels_train,labels_test,train_col);
                    
                end
            end
        end
    end
end

% average across permutations
EEGdec.RDM = squeeze(nanmean(RDM,1))-chance_level;

% move time to first dimension
EEGdec.RDM = permute(EEGdec.RDM,[5 1 2 3 4]);

% extract result for decoding of letters
% average across upper-diagonal
DA = nanmean(EEGdec.RDM(:,:,:,triu(ones(8,8),1)==1) ,4);

% take off-diagonal for across
EEGdec.across = nanmean(DA(:,eye(2,2)==0),2);

% take diagonal for within
EEGdec.within = nanmean(DA(:,eye(2,2)==1),2);

toc