function [ROIdec]=decoding_roi(subject,roi)
% ROI decoding of Braille letter within-hand and across-hand
% Marleen Haupt and Monika Graumann
% 22-02-2024

% Input:
%   subject: number, e.g. 1
%   roi: string, e.g. 'EVC'

tic

% paths
addpath(genpath('../code/'));
addpath(genpath('../toolboxes/libsvm'));

% define classification parameters
chance_level = 50;

% load preprocessed data per subject and ROI
% data dimensions: 5 pseudoruns x 16 Braille letters x voxels
load(sprintf('../data/fMRI_preprocessed/sub%02d_%s.mat',subject,roi))

% set the labels for SVM
labels_train = [ones(1,(size(data,1))-1) 2*ones(1,(size(data,1))-1)]; % labels for training; class names 1 and 2 by
labels_test  = [1 2]; % labels for the left out run
letters      = 8; % data has dimensions 16x1 but here we use 2x8 because we decode across hand
hands        = 2;

% load RDM for indexing conditions from helpers folder
load('../code/helpers/index_matrix.mat');

% preallocate result matrix
run_wise_accuracy = nan(size(data,1),hands,hands,letters,letters);

for iRun = 1:size(data,1)
    % index to runs for training (all except one)
    iTrainRun = find([1:size(data,1)]~=iRun);  
    % index to run for testing (the one left out)
    iTestRun  = iRun;                         
    
    for HandA = 1:hands
        for HandB = 1:hands
            
            for LettersA = 1:letters
                for LettersB = 1:letters
                    
                    % output numbers between 1-16 to index data
                    trainA = find(X_DM(:,1)==LettersA & X_DM(:,2)==HandA);
                    trainB = find(X_DM(:,1)==LettersB & X_DM(:,2)==HandA);
                    
                    testA  = find(X_DM(:,1)==LettersA & X_DM(:,2)==HandB);
                    testb  = find(X_DM(:,1)==LettersB & X_DM(:,2)==HandB);
                    
                    data_train = [squeeze(data(iTrainRun,trainA,:));...
                                  squeeze(data(iTrainRun,trainB,:))];
                    
                    data_test  = [squeeze(data(iTestRun,testA,:))';...
                                  squeeze(data(iTestRun,testb,:))'];
                    
                    model = svmtrain(labels_train',data_train,'-s 0 -t 0 -q');
                    
                    [predicted_label, accuracy, ~] = svmpredict(labels_test', data_test, model);
                    
                    run_wise_accuracy(iRun,HandA,HandB,LettersA,LettersB) = accuracy(1);
                    
                end
            end
        end
    end
end

% average across pseodoruns and store 2x2x8x8 RDM
ROIdec.RDM = squeeze(nanmean(run_wise_accuracy,1))-chance_level;

% extract result for decoding of letters
% average across upper-diagonal
DA = nanmean(ROIdec.RDM(:,:,triu(ones(8,8),1)==1),3);

% take off-diagonal for across
ROIdec.across = nanmean(DA(eye(2,2)==0));

% take diagonal for within
ROIdec.within = nanmean(DA(eye(2,2)==1));

toc