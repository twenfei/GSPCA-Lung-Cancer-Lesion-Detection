
% written by Wenfei
% Aug 1, 2019
% This function does segmentation for one image
% The segmentation is used for training set


% Input:
% file1: lung mask
% file2: real image
% file3: cancerous mask

% option == 1: cancerous images (containing both cancerous and non-cancerous patches)
% option == 0: non-cancerous images (containing only non-cancerous patches)

% label == 1: non-cancerous
% label == 2: cancerous
	
% This file generates overlapping patches for the whole image
% This generate mode is used for TrainSet Only
function [X, patchNum, labels_arr] = buildPatchesFile_overlapping(file1, file2, file3, patchSize, option)
    if (option == 0) % non-cancerous images, get random patches only
%         % Npatches specifies the total number of patches extacted
%         % from one image
%         % TODO: modify Npatches & patchSize
%         Npatches = 1000;
%         %         patchSize = 10;
%         %         patchJump = patchSize;
%         
%         X1 = [];
%         X2 = [];
%         X3 = [];
%         
%         % All the labels should be 
% 
%         %         numFiles       = numel(file1);
%         %         for i = 1: numFiles
%         % Reading in the labeled files
%         % Read in png files
%         img = imread(file1); % lung mask
%         img = logical(img);
%         %Reading in the real images
%         img_real = imread(file2);
% 
%         [h, w] = size(img);
% 
%         if( h < patchSize || w < patchSize)
%             X = [];
%             patchNum = 0;
%             return;
%         end
% 
%         BW = bwareafilt(img, [patchSize^2 size(img,1)*size(img,2)]);%segregates only patches area patchSize^2 to size of image
% 
%         s = regionprops(BW, 'BoundingBox');%Bounding box struct has format [left, top, width, height]
% 
%         id_patch = 0;
%         patchPerRegion = floor(Npatches/size(s, 1)) + 1;
% 
%         for amount=1:size(s,1)  %properties of all regions specified by bwearefilt
% 
%             %                 patch_count = 1;
% 
%             for num = 1 : patchPerRegion
%                 %                 while(patch_count ~= patchPerRegion)
%                 if (id_patch == Npatches)
%                     continue;
%                 end
% 
%                 c = ceil(s(amount).BoundingBox(1)) + round(rand .* s(amount).BoundingBox(3));
%                 r = ceil(s(amount).BoundingBox(2)) + round(rand .* s(amount).BoundingBox(4));
% 
%                 %                     if ( img(c,r) == 0)
%                 %                         continue;
%                 %                     end
%                 
%                 % check if it's overflow
%                 [h, w] = size(img);
%                 if (r + patchSize - 1 > ceil(s(amount).BoundingBox(1)) + s(amount).BoundingBox(3)...
%                     || c + patchSize - 1 > ceil(s(amount).BoundingBox(2)) + s(amount).BoundingBox(4))
%                     continue;
%                 end
%                 
%                 rows = r : r + patchSize - 1;
%                 cols = c : c + patchSize - 1;
% 
% 
%                 %                     patch = BW(rows,cols);
% 
%                 %                     if sum(patch(:)) < patchSize^2 - 1 %at least all pixels but one will be accurate
%                 %                         continue
%                 %                     end
% 
%                 patch = img(rows, cols);
%                 if sum(patch(:)) < patchSize^2 * 0.8 %at least 80% pixels
%                 %will be in the mask
%                     continue
%                 end
% 
%                 imdata_patch = img_real(rows, cols, : );
%             
%                 X1 = [X1 ; imdata_patch(:,:,1)];
%                 X2 = [X2 ; imdata_patch(:,:,2)];
%                 X3 = [X3 ; imdata_patch(:,:,3)];
% 
%                 id_patch    = id_patch + 1;
%             end
%         end
%         
%         X(:,:,1) = X1;
%         X(:,:,2) = X2;
%         X(:,:,3) = X3;
%         patchNum = id_patch;
%         
%         labels_arr = ones(1, patchNum) * 1; % label == 1
%         

% new approach, modified by Wenfei, 6/17/2020
        X1 = [];
        X2 = [];
        X3 = [];

        patchJump = patchSize; % extract non-overlapping patches from non-cancerous imgs
        % Reading in the labeled files
        % Read in png files
        img = imread(file1); % lung mask
        img = logical(img);
        %Reading in the real images
        img_real = imread(file2);

        [h, w] = size(img);

        if( h < patchSize || w < patchSize)
            X = [];
            patchNum = 0;
            return;
        end

        BW = bwareafilt(img, [patchSize^2 size(img,1)*size(img,2)]);%segregates only patches area patchSize^2 to size of image

        s = regionprops(BW, 'BoundingBox');%Bounding box struct has format [left, top, width, height]

        id_patch = 0;
        
        for amount=1:size(s,1)  %properties of all regions specified by bwearefilt
            
            for c = ceil(s(amount).BoundingBox(1)) : patchJump :...
                    ceil(s(amount).BoundingBox(1)) +  (s(amount).BoundingBox(3) - patchSize + 1)
                
                for r = ceil(s(amount).BoundingBox(2)) : patchJump : ...
                        ceil(s(amount).BoundingBox(2)) +  (s(amount).BoundingBox(4)- patchSize + 1) %gets patches from bounding box
                    
                    rows = r : r + patchSize - 1;
                    cols = c : c + patchSize - 1;                   
                                        
                    % one layers of filters
                    % 1st step: filter out the all-white patches using the
                    % lung mask
                    
                    % 1st step:
                    patch = img(rows, cols);
                    if sum(patch(:)) < patchSize ^ 2 * 0.7
                        continue; % skip this patch
                    end
                    
                    % increase the id_patch by 1
                    id_patch = id_patch + 1;
                    
                    imdata_patch = img_real(rows, cols, : );
                    
                    % X1(:,idpatch) = imdata_patch(:);
                    X1 = [X1 ; imdata_patch(:,:,1)];
                    X2 = [X2 ; imdata_patch(:,:,2)];
                    X3 = [X3 ; imdata_patch(:,:,3)];
                    
                end
                
            end
        end
   
        X(:,:,1) = X1;
        X(:,:,2) = X2;
        X(:,:,3) = X3;     
        
        patchNum = id_patch;
        labels_arr = ones(1, patchNum) * 1; % label == 1
        
        return;
% ----------------------- option == 1 -------------------------------------
    else % get both random patches and overlapping patches
        
        % Get random patches -- non-cancerous

        % Npatches specifies the total number of patches extacted
        % from one image
        % TODO: modify Npatches & patchSize
        Npatches = 200; % TODO: just modified from 400->200, 06/17/2020

        X1 = zeros(patchSize^2, 0);
        X2 = zeros(patchSize^2, 0);
        X3 = zeros(patchSize^2, 0);
%         X1 = [];
%         X2 = [];
%         X3 = [];
        
        img = imread(file1); % lung mask
        img = logical(img);
        img_real = imread(file2); % real image
        img_cancerousous = imread(file3); % cancerous mask
        img_cancerousous = logical(img_cancerousous);

        BW = bwareafilt(img, [patchSize^2 size(img,1)*size(img,2)]);%segregates only patches area patchSize^2 to size of image

        s = regionprops(BW, 'BoundingBox');%Bounding box struct has format [left, top, width, height]

        id_patch = 0;
        patchPerRegion = floor(Npatches/size(s, 1)) + 1;

        for amount=1:size(s,1)  %properties of all regions specified by bwearefilt
            for num = 1 : patchPerRegion
                %                 while(patch_count ~= patchPerRegion)
                if (id_patch == Npatches)
                    continue;
                end

                c = ceil(s(amount).BoundingBox(1)) + round(rand .* s(amount).BoundingBox(3));
                r = ceil(s(amount).BoundingBox(2)) + round(rand .* s(amount).BoundingBox(4));
                
                [h, w] = size(img);
                if (r + patchSize - 1 > h || c + patchSize - 1 > w)
                    continue;
                end
                
                rows = r : r + patchSize - 1;
                cols = c : c + patchSize - 1;

                patch = img(rows, cols);
                % not all white >= 0.8 
                % not touching the cancerous regions
                if sum(patch(:)) < patchSize^2 * 0.8 %at least all pixels but one will be accurate
                    continue
                end
                
                patch = img_cancerousous(rows, cols);
                if sum(patch(:)) > patchSize^2 * 0.5 - 1 % too many cancerous regions within
                    continue;
                end

                imdata_patch = img_real(rows, cols, : );

                X1 = [X1 ; imdata_patch(:,:,1)];
                X2 = [X2 ; imdata_patch(:,:,2)];
                X3 = [X3 ; imdata_patch(:,:,3)];

                id_patch    = id_patch + 1;
            end
        end
        
         patchNum = id_patch;
        labels_arr = ones(1, id_patch) * 1; % label == 1, non-cancerous
% -------------------------------------------------------------------------        
        % overlapping patches -- cancerous
        patchJump = 3;
        
%         id_patch = 0;

%         img = imread(file1);
%         img = logical(img); % lung mask 
        img_real = imread(file2); % real image
        img_cancerous = imread(file3); % cancerous mask
        img_cancerous = logical(img_cancerous); 
        
        [h, w] = size(img);
        
        if( h < patchSize || w < patchSize)
            X = [];
            patchNum = 0;
            return;
        end
        
        BW = bwareafilt(img_cancerous, [patchSize^2 size(img_cancerous,1)*size(img_cancerous,2)]);%segregates only patches area patchSize^2 to size of image
        
        s = regionprops(BW, 'BoundingBox');%Bounding box struct has format [left, top, width, height]
        
        for amount=1:size(s,1)  %properties of all regions specified by bwearefilt
            
            for c = ceil(s(amount).BoundingBox(1)) : patchJump :...
                    ceil(s(amount).BoundingBox(1)) +  (s(amount).BoundingBox(3) - patchSize + 1)
                
                for r = ceil(s(amount).BoundingBox(2)) : patchJump : ...
                        ceil(s(amount).BoundingBox(2)) +  (s(amount).BoundingBox(4)- patchSize + 1) %gets patches from bounding box
                    
                    rows = r : r + patchSize - 1;
                    cols = c : c + patchSize - 1;                   
                                        
                    % TODO: two layers of filters
                    % 1st step: filter out the all-white patches 
                    % 2nd step: to decide the label of this patch
                    
                    % 1st step:
%                     patch = img(rows, cols);
%                     if sum(patch(:)) < patchSize ^ 2 - 1
%                         continue; % skip this patch
%                     end
                    
                    % increase the id_patch by 1
                    id_patch = id_patch + 1;
                    
                    % 2nd step:

                    patch_cancer = img_cancerous(rows, cols);
                    if sum(patch_cancer(:)) < 0.5 * patchSize ^ 2
                        labels_arr(id_patch) = 1; % non-cancerous
                    else
                        labels_arr(id_patch) = 2; % cancerous
                    end
                    
                    imdata_patch = img_real(rows, cols, : );
                    
                    % X1(:,idpatch) = imdata_patch(:);
                    X1 = [X1 ; imdata_patch(:,:,1)];
                    X2 = [X2 ; imdata_patch(:,:,2)];
                    X3 = [X3 ; imdata_patch(:,:,3)];
                    
                end
                
            end
        end
   
        X(:,:,1) = X1;
        X(:,:,2) = X2;
        X(:,:,3) = X3;
    
    patchNum = id_patch;
    end 
end
