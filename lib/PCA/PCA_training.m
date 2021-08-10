% Developed by Wenfei Tang, Galban Lab
% Adapted version of former code "Demo_myData_rgb.m"

function PCA_training()
% ==== PCANet Demo =======
% T.-H. Chan, K. Jia, S. Gao, J. Lu, Z. Zeng, and Y. Ma, 
% "PCANet: A simple deep learning baseline for image classification?" 
% IEEE Trans. Image Processing, vol. 24, no. 12, pp. 5017-5032, Dec. 2015. 

% Tsung-Han Chan [chantsunghan@gmail.com]
% Please email me if you find bugs, or have suggestions or questions!
% ========================
tic
clear all; close all; clc; 
% completed in train_model.m
% addpath('Utils/');
% addpath('Liblinear/');
% make;

%% Load data
% Under the folder "model/data.mat"
load('model/data.mat');

%% Loading data from segmented image patches
TrnSize = train_num;
ImgSize = 20; % TODO: patchSize(ImgSize) 

TrnData = TrainSet.X;
TrnLabels = (TrainSet.y)'; 
TestData = TestSet.X;
TestLabels = (TestSet.y)';

ImgFormat = 'color'; %'color';

%% For this demo, we subsample the Training and Testing sets 
% plz comment out the following four lines for a complete test.
% when you want to do so, please ensure that your computer memory is more than 64GB. 
% training linear SVM classifier on large amount of high dimensional data would 
% requires lots of memory. 
TrnData = TrnData(:,1:5:end);  % sample around 33505/10 training samples
TrnLabels = TrnLabels(1:5:end); % 
TestData = TestData(:,1:1:end);  % use the full testing dataset
TestLabels = TestLabels(1:1:end); 
%%%%%%%%%%%%%%%%%%%%%%%%
nTestImg = length(TestLabels);
% TODO: change the downsampling size


%% PCANet parameters (they should be tuned based on validation set; i.e., ValData & ValLabel)
PCANet.NumStages = 2;
PCANet.PatchSize = [5 5];
PCANet.NumFilters = [45 9]; % [30 6] [35 7] [45 9] [50 10]
PCANet.HistBlockSize = [8 8]; % [6 6] [8 8] [10 10]
PCANet.BlkOverLapRatio = 0.5;
PCANet.Pyramid = [4 2 1];

fprintf('\n ====== PCANet Parameters ======= \n')
PCANet

%% PCANet Training with 10000 samples
fprintf('\n ====== PCANet Training ======= \n')
TrnData_ImgCell = mat2imgcell(double(TrnData),ImgSize,ImgSize,ImgFormat); % convert columns in TrnData to cells 
tic; 
[ftrain, V, BlkIdx] = PCANet_train(TrnData_ImgCell,PCANet,1); % BlkIdx serves the purpose of learning block-wise DR projection matrix; e.g., WPCA
PCANet_TrnTime = toc;

% READ THE SCRIPT!!!!!!!! GO THRU THE SCRIPT!
%% PCA hashing over histograms
c = 10; 
fprintf('\n ====== Training Linear SVM Classifier ======= \n')
display(['now testing c = ' num2str(c) '...'])
tic;
models = train(TrnLabels, ftrain', ['-s 1 -c ' num2str(c) ' -q']); % we use linear SVM classifier (C = 10), calling liblinear library
LinearSVM_TrnTime = toc;


%% PCANet Feature Extraction and Testing 

TestData_ImgCell = mat2imgcell(TestData,ImgSize,ImgSize,ImgFormat); % convert columns in TestData to cells 
clear TestData; 

fprintf('\n ====== PCANet Testing ======= \n')

nCorrRecog = 0;

nCorrRecog_1 = 0;
nCorrRecog_2 = 0;
totalRec_1 = 0;
totalRec_2 = 0;

RecHistory = zeros(nTestImg,1);

tic; 
for idx = 1:1:nTestImg
    ftest = PCANet_FeaExt(TestData_ImgCell(idx),V,PCANet); % extract a test feature using trained PCANet model 

    [xLabel_est, accuracy, decision_values] = predict(TestLabels(idx),...
        sparse(ftest'), models, '-q');
    
    if xLabel_est == TestLabels(idx) 
        RecHistory(idx) = 1;
        nCorrRecog = nCorrRecog + 1;
    end
    
    % calculate the correct recog separately
    if TestLabels(idx) == 1 % non-cancerous
        totalRec_1 = totalRec_1 + 1;
        if xLabel_est == TestLabels(idx)
            nCorrRecog_1 = nCorrRecog_1 + 1; % true negative
        end
    end
    
    if TestLabels(idx) == 2 % cancerous
        totalRec_2 = totalRec_2 + 1;
        if xLabel_est == TestLabels(idx)
            nCorrRecog_2 = nCorrRecog_2 + 1; % true positive
        end
    end
    
    TestData_ImgCell{idx} = [];
    
end

Averaged_TimeperTest = toc/nTestImg;
Accuracy = nCorrRecog/nTestImg; 

Accuracy_1 = nCorrRecog_1/totalRec_1;
Accuracy_2 = nCorrRecog_2/totalRec_2;

ErRate = 1 - Accuracy;

%% Save model
model_filename = date + '-trained-model.mat';
save(model_filename);
% trained_model_20_5_1_8.mat
% 20: patch size
% 5_1: down sampling size is 5:1
% 8: HistBlockSize [8 8]

%% Results display
fprintf('\n ===== Results of PCANet, followed by a linear SVM classifier =====');
fprintf('\n     PCANet training time: %.2f secs.', PCANet_TrnTime);
fprintf('\n     Testing accuracy: %.2f%%', 100*Accuracy);
fprintf('\n     Testing accuracy for non-cancerous: %.2f%%', 100*Accuracy_1);
fprintf('\n     Testing accuracy for cancerous: %.2f%%', 100*Accuracy_2);
fprintf('\n     Average testing time %.2f secs per test sample. \n\n',Averaged_TimeperTest);
end