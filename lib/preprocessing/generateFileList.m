% Developed by Wenfei Tang, Galban Lab, University of Michigan
% Description:
% This file generates lung masks from the images given and provides file
% lists used in model training/testing. The list of filenames is generated
% without the specified path.
% Input: 
% mode: mode == 1, training file list
% mode == 2, testing file list

function [noncancer_flist1, noncancer_flist2, ...
    cancer_flist1, cancer_flist2, cancer_flist3] = generateFileList(mode)

    % add path
    if (mode == 1)
        % generate file list for training
        data_path = '../../training_data';
    else
        % generate file list for testing
        data_path = '../../testing_data';
    end
    addpath(data_path);
    
    % Init
    noncancer_flist1 = {}; % paths for lung masks
    noncancer_flist2 = {}; % paths for original images
    cancer_flist1 = {}; % paths for lung masks
    cancer_flist2 = {}; % paths for original images
    cancer_flist3 = {}; % paths for binary maps
    % Read from file
    input_file = 'file_list.txt';
    fid = fopen(input_file);
    num_noncancer = str2double(fgetl(fid));
    
    for i = 1 : num_noncancer
        filename = strcat('noncancer-mask-' , num2str(i), '.png'); % filename for lung mask
        noncancer_flist1{i} = filename;
        noncancer_flist2{i} = fgetl(fid);      
        
        % Generate lung masks
        input_path = strcat(data_path, '/noncancer_images/real_images/', noncancer_flist2{i});
        output_path = strcat(data_path, '/noncancer_images/lung_masks/', filename); % filepath for lung mask
        buildMasks(input_path, output_path);
    end
    
    num_cancer = str2double(fgetl(fid));
    for i = 1 : num_cancer
        filename = strcat('cancer-mask-' , num2str(i), '.png'); % filename for lung mask
        cancer_flist1{i} = filename;
        cancer_flist2{i} = fgetl(fid);
        
        % Generate lung masks
        input_path = strcat(data_path, '/cancer_images/real_images/', cancer_flist2{i});
        output_path = strcat(data_path, '/cancer_images/lung_masks/', filename); % filepath for lung mask
        buildMasks(input_path, output_path);        
    end

    for i = 1 : num_cancer
        cancer_flist3{i} = fgetl(fid);
    end
    
    fclose(fid);
end

% buildMasks.m
% written by Wenfei
% Given the file path, generate masks of lung region for all images
% Run this on C1 and C2 images
function buildMasks(filepath, filename)
    I = imread(filepath);
    I2 = I;
    % resize down the image resolution
    I_LR = imresize(I, [512 512]);
    % convert rgb img to gray img
    I_LR2 = rgb2gray(I_LR);
    m = ones(size(I_LR2));
    m = m - imdilate(bwperim(m),ones(5));
    seg_LR = activecontour(I_LR,m,1000);
    seg_LR2 = bwareaopen(seg_LR, 100);
    seg = imresize(seg_LR2, [size(I2,1), size(I2,2)]);
    imwrite(seg, filename);
end
