function restoration = shakeCorrection(v)
% clear;
% path = 'footage';
% prefix = 'footage_';
% first = 1;
% last = 657;
% digits = 3;
% suffix = 'png';
% v = load_sequence(path, prefix, first, last, digits, suffix);

[height,width,frame_num ] = size(v);
v_d = double(v);

% template
reference_frame = v_d(:,:,1);
template_size = round(height/2); 
reference_template = reference_frame(1:template_size,:);
%imshow(uint8(reference_template));
patch_head = 0;
patch_tail = template_size;
%a = patch_head+1:patch_tail;
%b = window_default_size+1:width-window_default_size;
% window
window_default_size = 2;% this is radius so if windowsize = 2 then window is 5 x 5.
tm_offset = zeros(2*window_default_size+1);

startidx_m = round(template_size/6)+patch_head+1;
startidx_n = round(width/6);
patch = v_d( startidx_m:patch_tail-round(template_size/6), startidx_n: width - round(width/6),1);
offset_sets = zeros(1,2,frame_num);
restoration = v_d;
for t = 1:frame_num
    current_frame = restoration(:,:,t);
    tm_matrix = normxcorr2(patch,current_frame);
    [m_max, n_max] = find(tm_matrix==max(tm_matrix(:)));
    if tm_matrix(m_max,n_max) < 0.7 % not a reliable result
        %continue;
        % Do template matching with the revious frame instead of the
        % reference frame
        patch2 = v_d( startidx_m:patch_tail-round(template_size/6), startidx_n: width - round(width/6),t-1);
        tm_matrix = normxcorr2(patch2,current_frame);
       
        [m_max2, n_max2] = find(tm_matrix==max(tm_matrix(:)));
        max2 = tm_matrix(m_max2,n_max2);
        %if tm_matrix(m_manx2,n_max2) < 0.6
        % Template matching for the lower part of the frame.
        startidx_m3 = round(template_size/6) + patch_tail +1;
        patch3 = v_d( startidx_m3:height-round(template_size/6), startidx_n: width - round(width/6),1);
        tm_matrix = normxcorr2(patch3,current_frame);
        [m_max3, n_max3] = find(tm_matrix==max(tm_matrix(:)));
        max3 = tm_matrix(m_max3,n_max3);
        if(max2 > max3)
           if(max2 <0.7)
               frame_shifted = circshift(current_frame,[offset_sets(1,1,t-1) offset_sets(1,2,t-1)]);
               % Check the offset size if it is too large.
               if(startidx_m+patch_head-m_offSet > size(patch,1)*0.1)||(startidx_n-n_offSet-1> size(patch,1)*0.1)               
                   continue;
               end
               offset_sets(1,1,t) = startidx_m+patch_head-m_offSet;
               offset_sets(1,2,t) = startidx_n-n_offSet-1;
               restoration(:,:,t) = frame_shifted;      
               continue;                
           end
           m_max = m_max2;   
           n_max = n_max2; 
           patch = patch2;
           m_offSet = m_max-size(patch,1);
           n_offSet = n_max-size(patch,2);
           frame_shifted = circshift(current_frame,[startidx_m+patch_head-m_offSet+offset_sets(1,1,t-1) startidx_n-n_offSet-1+offset_sets(1,2,t-1)]);
           if(startidx_m+patch_head-m_offSet > size(patch,1)*0.1)||(startidx_n-n_offSet-1> size(patch,1)*0.1)
               continue;
           end
           offset_sets(1,1,t) = startidx_m+patch_head-m_offSet;
           offset_sets(1,2,t) = startidx_n-n_offSet-1;
           restoration(:,:,t) = frame_shifted;
           continue;
        else
           if(max3 <0.7)               
               frame_shifted = circshift(current_frame,[offset_sets(1,1,t-1) offset_sets(1,2,t-1)]);
               if(startidx_m+patch_head-m_offSet > size(patch,1)*0.1)||(startidx_n-n_offSet-1> size(patch,1)*0.1)     
                    continue;        
               end
               offset_sets(1,1,t) = startidx_m+patch_head-m_offSet;
               offset_sets(1,2,t) = startidx_n-n_offSet-1;
               restoration(:,:,t) = frame_shifted;              
               continue;              
           end
           m_max = m_max3;   
           n_max = n_max3; 
           patch = patch3;
           startidx_m = startidx_m3;          
        end
    end
    m_offSet = m_max-size(patch,1);
    n_offSet = n_max-size(patch,2);
    frame_shifted = circshift(current_frame,[startidx_m+patch_head-m_offSet startidx_n-n_offSet-1]);
    if(startidx_m+patch_head-m_offSet > size(patch,1)*0.1)||(startidx_n-n_offSet-1> size(patch,1)*0.1)     
       continue;        
    end
    offset_sets(1,1,t) = startidx_m+patch_head-m_offSet;
    offset_sets(1,2,t) = startidx_n-n_offSet-1;
    restoration(:,:,t) = frame_shifted;
    %imshowpair(uint8(patch),uint8(current_frame),'montage');

%     figure
%     imshow(uint8(v_d(:,:,t)));
%     imrect(gca, [n_offSet+1, m_offSet+1, size(patch,2), size(patch,1)]);
end
%save_sequence(uint8(restoration), 'output4', 'footage_', 1, 3);
%imshow(uint8(restoration(:,:,1)))

end
