% Developed by Wenfei Tang, Galban Lab, University of Michigan
% Description:
% Use this script to train a new model using your own dataset

function train_model()
%% Add paths
addpath('lib/PCA/');
addpath('lib/PCA/Utils/');
addpath('lib/PCA/Liblinear/');
addpath('lib/preprocessing/');
addpath('model/');
make;

%% Initialization
%     noncancer_flist1: paths for non-cancerous lung masks
%     noncancer_flist2: paths for non-cancerous original images
%     cancer_flist1: paths for cancerous lung masks
%     cancer_flist2: paths for cancerous original images
%     cancer_flist3: paths for cancerous binary maps

filename = 'model/data.mat'; % Data saved path

class_num = 2;
train_num = 0;
test_num  = 0;
TrainSet.X = [];
TrainSet.y = [];
TestSet.X = [];
TestSet.y = [];


%% Generate Train Set
% Call generateFileList to generate lung masks and get file lists
[noncancer_flist1, noncancer_flist2,...
    cancer_flist1, cancer_flist2, cancer_flist3] = generateFileList(1);
noncancer_flist3 = {};

% TODO: Generate the right file path
for n = 1 : numel(noncancer_flist1)
    noncancer_flist1{n} = "training_data/noncancer_images/lung_masks/" + noncancer_flist1{n};
    noncancer_flist2{n} = "training_data/noncancer_images/real_images/" + noncancer_flist2{n};
end

for n = 1 : numel(cancer_flist1)
    cancer_flist1{n} = "training_data/cancer_images/lung_masks/" + cancer_flist1{n};
    cancer_flist2{n} = "training_data/cancer_images/real_images/" + cancer_flist2{n};
    cancer_flist3{n} = "training_data/cancer_images/binary_maps/" + cancer_flist3{n};
end

% Process patches
mode = 0; % training
option = 0; % not using the flist3, for class 1, non-cancerous image
process_patch(noncancer_flist1, noncancer_flist2, noncancer_flist3, option, mode); 

% For class 2, cancerous image
option = 1; % using flist3 as cancerous mask
process_patch(cancer_flist1, cancer_flist2, cancer_flist3, option, mode);

%% Generate Test Set
% Call generateFileList to generate lung masks and get file lists
[noncancer_flist1, noncancer_flist2,...
    cancer_flist1, cancer_flist2, cancer_flist3] = generateFileList(2);
noncancer_flist3 = {};

% TODO: Generate the right file path
for n = 1 : numel(noncancer_flist1)
    noncancer_flist1{n} = "testing_data/noncancer_images/lung_masks/" + noncancer_flist1{n};
    noncancer_flist2{n} = "testing_data/noncancer_images/real_images/" + noncancer_flist2{n};
end

for n = 1 : numel(cancer_flist1)
    cancer_flist1{n} = "testing_data/cancer_images/lung_masks/" + cancer_flist1{n};
    cancer_flist2{n} = "testing_data/cancer_images/real_images/" + cancer_flist2{n};
    cancer_flist3{n} = "testing_data/cancer_images/binary_maps/" + cancer_flist3{n};
end

% Process patches
mode = 1; % testing
option = 0; % not using the flist3, for class 1, non-cancerous image
process_patch(noncancer_flist1, noncancer_flist2, noncancer_flist3, option, mode); 

% For class 2, cancerous image
option = 1; % using flist3 as cancerous mask
process_patch(cancer_flist1, cancer_flist2, cancer_flist3, option, mode);

%% Save Training/Testing Data in .mat file
save(filename, 'class_num', 'test_num', 'train_num');
save(filename, 'TestSet', '-append');
save(filename, 'TrainSet', '-append');

%% Run PCA training from Demo_myData_rgb
% Call PCA trainig script from Utils
PCA_training();

%% Process patches function
% option = 0 : for non-cancerous region, not using flist3
% option = 1 : for cancerous region, using flist3
% mode = 0 : for training data
% mode = 1 : for testing data
    function process_patch(flist1, flist2, flist3, option, mode)    
        for i = 1 : numel(flist1)
            file1 = flist1{i};
            file2 = flist2{i};
            
            if (option == 1)
                file3 = flist3{i};
            else
                file3 = '';
            end
            
            % TODO: modify patchSize
            if (mode == 0)
                [patches, patchNum, labels_arr] = ...
                buildPatchesFile_overlapping(file1, file2, file3, 20, option);
            else
                [patches, patchNum, labels_arr] = ...
                buildPatchesFile_non_overlapping(file1, file2, file3, 20, option);
            end
            
            patchSize = size(patches, 2);
            
%             G = rgb2gray(patches);
            G = patches;
            
            % X is a tmp to store TrainSet
            X = zeros(patchSize^2 * 3, patchNum);
            Y = zeros(1, patchNum);
            
            for j = 1 : patchNum
                train_num = train_num + 1;
                
                top = (j - 1) * patchSize;
                bottom = j * patchSize;
                
%                 img = G(top + 1 : bottom, : );
%                 
%                 X(:, j) = img(:);          
                img_r = G(top + 1 : bottom, : ,1);
                img_g = G(top + 1 : bottom, : ,2);
                img_b = G(top + 1 : bottom, : ,3);

                X(1:patchSize^2, j)                        = img_r(:);
                X(patchSize^2 + 1:patchSize^2 * 2, j)      = img_g(:);
                X(patchSize^2 * 2 + 1: patchSize^2 * 3, j) = img_b(:);
                Y(1, j) = labels_arr(j);
            end
            
            if (mode == 0)
                TrainSet.X = [TrainSet.X X];
                TrainSet.y = [TrainSet.y Y];
            else
                TestSet.X = [TestSet.X X];
                TestSet.y = [TestSet.y Y];
            end
        end
    end
end