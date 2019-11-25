function output = labs3(path, prefix, first, last, digits, suffix)

%
% Read a sequence of images and correct the film defects. This is the file 
% you have to fill for the coursework. Do not change the function 
% declaration, keep this skeleton. You are advised to create subfunctions.
% 
% Arguments:
%
% path: path of the files
% prefix: prefix of the filename
% first: first frame
% last: last frame
% digits: number of digits of the frame number
% suffix: suffix of the filename
%
% This should generate corrected images named [path]/corrected_[prefix][number].png
%
% Example:
%
% mov = labs3('../images','myimage', 0, 10, 4, 'png')
%   -> that will load and correct images from '../images/myimage0000.png' to '../images/myimage0010.png'
%   -> and export '../images/corrected_myimage0000.png' to '../images/corrected_myimage0010.png'
%

% Your code here

%% Loading the sequence
% path = 'footage';
% prefix = 'footage_';
% first = 001;
% last = 657;
% digits = 3;
% suffix = 'png';
v_int = load_sequence(path, prefix, first, last, digits, suffix);
v = double(v_int);



%% Start with scene cut detection

[~,~,frame_num ] = size(v);
count = zeros(frame_num,256);
[counts,binLocations] = imhist(v_int(:,:,1));
count(1,:) = counts;
flag_changeScene = zeros(frame_num,1);
counter = 0;
sum_history = zeros(frame_num,1);

for i=2:frame_num
    currentImg = v_int(:,:,i);
    [counts,binLocations] = imhist(currentImg);
    count(i,:) = counts;
    sum_history(i) = sum(abs(count(i,:) - count(i-1,:))); % Comparing the histogram differences
end
for i=2:frame_num
    if sum_history(i) > max(sum_history)*0.97 % Threshold is based on 0.97*maximum difference
       counter = counter +1;
       flag_changeScene(counter) = i;
    end
end
scenes = nonzeros(flag_changeScene)-1;
scenes(length(scenes)+1) = last; % add last footage as cut scene.

% Up to this point, the text has not yet inserted to the frame since it
% would affect the accuracy of the later tasks. The text will be added
% after all other task is finished.


%% Correction of global flicker 
head_gf = 1;
output = v;
for i = 1:length(scenes)
    
    output(:,:,head_gf:scenes(i)) = deflicker(output(:,:,head_gf:scenes(i)));
    %save_sequence(uint8(output), 'output1', prefix, head, digits);
    head_gf = scenes(i)+1;
    
end
%save_sequence(uint8(output), 'output1', prefix, first, digits);


%% Correction of camera shake 
head_cs = 1;


for i = 1:length(scenes)
    
    output(:,:,head_cs:scenes(i)) = shakeCorrection(output(:,:,head_cs:scenes(i)));
    %save_sequence(uint8(output), 'output1', prefix, head, digits);
    head_cs = scenes(i)+1;
    
end
%save_sequence(uint8(output), 'output4', prefix, first, digits);



%% Correction of blotches


head_cb = 1;
%output = v_int;  %%%%%%%%%%%%%%%%%%%%%%%%% will delete this later, NOT START A NEW V

for i = 1:length(scenes)

    output(:,:,head_cb:scenes(i)) = blotchDetection(output(:,:,head_cb:scenes(i)));
    %save_sequence(uint8(output), 'output1', prefix, head, digits);
    head_cb = scenes(i)+1;
    
end
%save_sequence(uint8(output), 'output2', prefix, first, digits);


%% Correction of vertical artefacts
% The index is manually input here because this task is focusing on last sequence only
%test = double(output(:,:,497:657));
[height,width,frame_num] = size(v);


for t = 497:657
    for i = 1:height  
        % The approach is to scanning through each line and applying the median
        % filter.
        output(i,:,t)  = medfilt1(double(output(i,:,t)),4);
        output(i,:,t) = output(i,:,t) + ((double(v(i,:,t)) - output(i,:,t))./4);
    end
end
%save_sequence(uint8(output), 'output3', prefix, first, digits);

% %% Correction of camera shake 
% head_cs = 1;
% 
% 
% for i = 1:length(scenes)
%     
%     output(:,:,head_cs:scenes(i)) = shakeCorrection(output(:,:,head_cs:scenes(i)));
%     %save_sequence(uint8(output), 'output1', prefix, head, digits);
%     head_cs = scenes(i)+1;
%     
% end
% %save_sequence(uint8(output), 'output4', prefix, first, digits);

%% Adding cut scene text

position =  [1 75];
value = 'Scene Cuts here';

for i = 1:length(scenes)
    textedimg = insertText(uint8(output(:,:,scenes(i))),position,value,'AnchorPoint','LeftBottom');


    output(:,:,scenes(i)) = rgb2gray(textedimg);
end

save_sequence(uint8(output), 'output', prefix, first, digits);
end
