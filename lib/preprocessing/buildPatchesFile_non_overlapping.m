
% written by Wenfei
% July 29, 2019

% Please call this function
% This function does segmentation for one image

% It loads needed info into 'boundingBoxInfo.mat'

% file1: lung mask
% file2: real image
% file3: cancerous mask

% label == 1: non-cancerous patch
% label == 2: cancerous patch

% option == 1: cancerous images (containing both cancerous and non-cancerous patches)
% option == 0: non-cancerous images (containing only non-cancerous patches)
	
% This file generates non-overlapping patches for the whole image
% This generate mode is used for TestSet Only

% label_arr: label of each patch
% img_arr: img number of each patch

% BB_val: BoundingBox values of each patch
function [X, patchNum, labels_arr] = ...
    buildPatchesFile_non_overlapping(file1, file2, file3, patchSize, option)
        patchJump = patchSize;
        
%         X1 = zeros(patchSize^2, 0);
%         X2 = zeros(patchSize^2, 0);
%         X3 = zeros(patchSize^2, 0);
        X1 = [];
        X2 = [];
        X3 = [];
        
        id_patch = 0;

        img = imread(file1);
        img = logical(img);

        img_real = imread(file2);
        
        if (option == 1) % it's an image containing cancerous region
            img_cancer = imread(file3);
            img_cancer = logical(img_cancer);
        end
        
        [h, w] = size(img);
        
        if( h < patchSize || w < patchSize)
            X = [];
            patchNum = 0;
            return;
        end
        
        BW = bwareafilt(img, [patchSize^2 size(img,1)*size(img,2)]);%segregates only patches area patchSize^2 to size of image
        
        s = regionprops(BW, 'BoundingBox');%Bounding box struct has format [left, top, width, height]
        
%         num_width = 0;
%         num_height = 0;

%         BB_val(1) = s(1).BoundingBox(1); % left
%         BB_val(2) = s(1).BoundingBox(2); % top
%         BB_val(3) = s(1).BoundingBox(3); % width
%         BB_val(4) = s(1).BoundingBox(4); % height

        for amount=1:size(s,1)  %properties of all regions specified by bwearefilt
            
            for c = ceil(s(amount).BoundingBox(1)) : patchJump :...
                    ceil(s(amount).BoundingBox(1)) +  (s(amount).BoundingBox(3) - patchSize + 1)
                
%                 num_width = num_width + 1;
                
                for r = ceil(s(amount).BoundingBox(2)) : patchJump : ...
                        ceil(s(amount).BoundingBox(2)) +  (s(amount).BoundingBox(4)- patchSize + 1) %gets patches from bounding box
                    
%                     num_height = num_height + 1; % should be divided by num_width to get the real heigh num
                    
                    rows = r : r+patchSize - 1;
                    cols = c : c+patchSize - 1;
                                                       
                    % TODO: two layers of filters
                    % 1st step: filter out the all-white patches 
                    % 2nd step: to decide the label of this patch
                    
                    % 1st step:
                    patch = img(rows, cols);
                    if sum(patch(:)) < patchSize ^ 2 - 1
                        continue; % skip this patch
                    end
                    
                    % increase the id_patch by 1
                    id_patch = id_patch + 1;
                    
                    % 2nd step:
                    if (option == 1) % images including cancerous regions
                        patch_cancer = img_cancer(rows, cols);
                        if sum(patch_cancer(:)) < 0.5 * patchSize ^ 2
                            labels_arr(id_patch) = 1; % non-cancerous
                        else
                            labels_arr(id_patch) = 2; % cancerous
                            
                            % for debugging
                            % imshow(img_real(rows, cols, : ));
                        end
                    else % images not including canceorus regions
                        labels_arr(id_patch) = 1; % non-cancerous
                    end
                    
                    imdata_patch = img_real(rows, cols, : );
                    
                    % X1(:,idpatch) = imdata_patch(:);
                    X1 = [X1 ; imdata_patch(:,:,1)];
                    X2 = [X2 ; imdata_patch(:,:,2)];
                    X3 = [X3 ; imdata_patch(:,:,3)];
                    
                end
                
            end
        end
        
%         % save num_width, num_height, left, top to .mat file
%         num_height = num_height/num_width;
%         left = s(1).BoundingBox(1);
%         top = s(1).BoundingBox(2);
%         save('boundingBoxInfo.mat', 'num_width', 'num_height', 'left', 'top');
   
        X(:,:,1) = X1;
        X(:,:,2) = X2;
        X(:,:,3) = X3;
    
    patchNum = id_patch;
    
end
