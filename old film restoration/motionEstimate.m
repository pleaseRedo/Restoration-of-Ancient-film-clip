function cumulateSum = motionEstimate(input_v, subseqsize)
% clear;
% path = 'footage';
% prefix = 'footage_';
% first = 001;
% last = 657;
% digits = 3;
% suffix = 'png';
% v = load_sequence(path, prefix, first, last, digits, suffix);
% v_d = double(v);

v = input_v;
v_d = double(v);
[~,~,frame_size]  = size(input_v);
%subseqsize = 10;


diffMat = zeros(size(v,1),size(v,2),frame_size);

for t = 2 : frame_size
    diffMat(:,:,t) = v_d(:,:,t) - v_d(:,:,t-1); 
end
cumulateSum = zeros(size(v,1),size(v,2),frame_size);
cumulateSum(:,:,1) = abs(diffMat(:,:,1));

remainder = rem(frame_size,subseqsize);
divisions = (frame_size - remainder)/subseqsize;
for div = 1:divisions
    sumup = 0;
    for t = (div-1)*subseqsize : (div)*subseqsize-1
        sumup = sumup + abs(diffMat(:,:,t+1));
    end
    t = max(sumup(:))*0.25;
    sumup = sumup - t; % Only the densed area remained
    % Using the average filter to connect the disjoints
    filter = fspecial('average', 60);
    sumup = imfilter(sumup, filter);
    % Do a close operation to close the concave shape.
    se = strel('disk',50);
    sumup = imclose(sumup,se);
    rgSize = 55; % region growing by 55 pixels
    se = ones(rgSize, rgSize); 
    sumup = imdilate(sumup,se);
    sumup(sumup(:,:) >0 ) = 1;
    sumup(sumup(:,:) <0 ) = 0;   
    cumulateSum(:,:,(div-1)*subseqsize+1 : (div)*subseqsize) = sumup.* ones(size(v,1),size(v,2),subseqsize);
end

if remainder < subseqsize/5
   cumulateSum(:,:, divisions*subseqsize+1 : divisions*subseqsize+remainder ) = sumup.* ones(size(v,1),size(v,2),remainder); 
else    
    sumup = 0;
    for t = divisions*remainder : divisions*remainder+subseqsize
        sumup = sumup + abs(diffMat(:,:,t+1));
    end
    t = max(sumup(:))*0.25;
    sumup = sumup - t;
    filter = fspecial('average', 60);
    sumup = imfilter(sumup, filter);
    se = strel('disk',50);
    sumup = imclose(sumup,se);
    rgSize = 50; % region growing by 20 pixels
    se = ones(rgSize, rgSize); 
    sumup = imdilate(sumup,se);
    sumup(sumup(:,:) >0 ) = 1;
    sumup(sumup(:,:) <0 ) = 0;
    cumulateSum(:,:,divisions*subseqsize+1 : divisions*subseqsize+remainder) = sumup.* ones(size(v,1),size(v,2),remainder);
end


% sumup = cumulateSum(:,:,2);
% t = max(sumup(:))*0.3;
% sumup = sumup - t;
%  filter = fspecial('average', 45);
%  sumup(:,:) = imfilter(sumup(:,:), filter);
%  se = strel('disk',50);
%  
%  sumup = imclose(sumup,se);
%  sumup(sumup(:,:) >0 ) = 255;
% imshow(uint8(sumup)); % sum up and thresholding can be a good way to presenting shaking correction
end
