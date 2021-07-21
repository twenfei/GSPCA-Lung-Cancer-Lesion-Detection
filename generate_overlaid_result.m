% This function uses the pre-trained model 
% and generates the overlaid prediction result on the original images

% Generate prediction results for images from the input folder 
% An example folder dataset has been provided under "\imaging_data"
% Developed by: Wenfei Tang

function generate_overlaid_result()
tic
% Obtain target folder
flist1 = {}; % input image path
flist2 = {}; % output image path: overlaid visualization
flist3 = {}; % output image path: binay maps

myDir = uigetdir; %gets directory
addpath(myDir);

mkdir(char(myDir), 'pred_result');
mkdir(char(myDir), 'binary_maps')

% Read images from Images folder
numFile = 1;
Imgs = dir(myDir);
for j=1:length(Imgs)
    thisname = Imgs(j).name;
    thisfile = fullfile(myDir, thisname);
    try
        Img = imread(thisfile);  % try to read image   
        fullFileName1 = fullfile(myDir, thisname);
        fullFileName2 = fullfile(myDir, 'pred_result', thisname);
        fullFileName3 = fullfile(myDir, 'binary_maps', thisname);
        fprintf(1, 'Now reading %s\n', thisname);
        flist1{numFile} = fullFileName1;
        flist2{numFile} = fullFileName2;
        flist3{numFile} = fullFileName3;
        numFile = numFile + 1;
    catch
   end
end

% myFiles = dir(fullfile(myDir,'*.jpg')); %gets all jpg files in struct
% for k = 1:length(myFiles)
%   baseFileName = myFiles(k).name;
%   fullFileName1 = fullfile(myDir, baseFileName);
%   fullFileName2 = fullfile(myDir, 'pred_result', baseFileName);
%   fprintf(1, 'Now reading %s\n', baseFileName);
%   flist1{k} = fullFileName1;
%   flist2{k} = fullFileName2;
% end

patchSize = 20;

% It should run under the directory of Histology project with folder PCANet
addpath('./lib/PCA/');
addpath('./lib/PCA/Utils/');
addpath('./lib/PCA/Liblinear/');
make;

for i = 1 : numel(flist1)
    filename = flist1{i};
    % Segment the img into patches
    TestData = []; % 1200 * n feature vector

    img_real = imread(filename);

    %[rows, columns, numberOfColorChannels] = size(img_real);
    [height, width, ~] = size(img_real);

    id_patch = 1; % records the total number of patches
    for c = 1: patchSize: width - patchSize + 1
        for r = 1: patchSize: height - patchSize + 1
            % extract the patch
            rows = r: r + patchSize - 1;
            cols = c: c + patchSize - 1;

            patch = img_real(rows, cols, :);
            patch_r = patch(:, :, 1);
            patch_g = patch(:, :, 2);
            patch_b = patch(:, :, 3);

            % concat to feature vector
            TestData = [TestData, [patch_r(:); patch_g(:); patch_b(:)]];

            id_patch = id_patch + 1;
        end
    end

    id_patch = id_patch - 1;

    % load trained models 

    % These two param should match the model's param
    ImgSize = 20; % TODO: modify the image size
    ImgFormat = 'color';

    load('model/trained_model_20_5_1_8_45_9_updated.mat', 'V', 'PCANet', 'models'); % TODO: load the correct model

    %% PCANet Feature Extraction and Testing 

    TestData_ImgCell = mat2imgcell(TestData,ImgSize,ImgSize,ImgFormat); % convert columns in TestData to cells 
    clear TestData; 

    fprintf('\n ====== PCANet Testing ======= \n')

    PredHistory = zeros(id_patch,1); % store the predicted label for each patch
    TestLabels = rand( id_patch, 1 ,'double'); % a dummy vector of randomly generated double values

    for idx = 1:1:id_patch
        ftest = PCANet_FeaExt(TestData_ImgCell(idx),V,PCANet); % extract a test feature using trained PCANet model 

        % [xLabel_est, accuracy, decision_values]
        [xLabel_est, ~, ~] = predict(TestLabels(idx),...
            sparse(ftest'), models, '-q');

        % xLabel_est == 1: non-cancerous
        % xLabel_est == 2: cancerous
        PredHistory(idx) = xLabel_est;

        TestData_ImgCell{idx} = [];

    end

%     save overlaid_results/pred_res.mat
% 
%     %% generate bw mask
%     clear;
%     load('overlaid_results/pred_res.mat');

    mask = zeros(height, width);

    idx = 1; % indexing from predhistory
    for c = 1: patchSize: width - patchSize + 1
        for r = 1: patchSize: height - patchSize + 1
            % extract the patch
            rows = r: r + patchSize - 1;
            cols = c: c + patchSize - 1;

            if PredHistory(idx) == 2
                mask(rows, cols) = 1;
            end

            idx = idx + 1;
        end
    end

    % display the overlaid result

    % BW = bwperim(mask);
    % overlaid = imoverlay(img_real, imdilate(BW, ones(3)), 'yellow');
    % imshow(overlaid); 

    % under imoverlay folder
    res = imoverlay(img_real,mask,'colormap',[0,1,0.5],'facealpha',0.3,'zeroalpha',0);
    % figure; imshow(res);
    imwrite(res, flist2{i}); % write overlaid result
    imwrite(mask, flist3{i}); % write mask
end
toc
end
