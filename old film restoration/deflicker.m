function restoration = deflicker(v)
%DEFLICKER Summary of this function goes here
%   Detailed explanation goes here


%v = load_sequence(path, prefix, first, last, digits, suffix);
[height,width,frame_num ] = size(v);
alphas = zeros(1,frame_num);
betas = zeros(1,frame_num);

v = double(v);
restoration = zeros(size(v));
kappa = 0.85;
variance = 0.1;
%gau_noise = sqrt(variance)*randn(size(v(:,:,1)));
%block size = 10 * 14 for 360x476 frame size
block_height = 10;
block_width = 14;
vec_height = height/10;
vec_width = width/14;
E_vec = zeros([vec_height,vec_width ,frame_num]);
var_vec = zeros([vec_height,vec_width ,frame_num]);
alpha_vec = zeros([vec_height,vec_width ,frame_num]);
beta_vec = zeros([vec_height,vec_width ,frame_num]);
gau_vec = zeros([vec_height,vec_width ,frame_num]); 


cur_frame1 = v(:,:,1);
cur_frame2 = v(:,:,2);
alpha_ini = 1;
beta_ini = 0;
alpha_vec(:,:,1) = alpha_ini;
beta_vec(:,:,1) = beta_ini;
alpha_vec(:,:,2) = alpha_ini;
beta_vec(:,:,2) = beta_ini;
% 
% for i = 1:vec_height
%     for j = 1:vec_width
%        head_i = (i-1)*block_height;
%        tail_i = i*block_height;
%        head_j = (j-1)*block_width;
%        tail_j = j*block_width;
%        %gau_noise1 = sqrt(variance)*randn([block_height,block_width]);
%        gau_noise2 = sqrt(variance)*randn([block_height,block_width]);
%        %cur_block = cur_frame1(head_i+1:tail_i,head_j+1:tail_j);
%        cur_block2 = cur_frame2(head_i+1:tail_i,head_j+1:tail_j);
%        %E_ini = alpha_ini * mean2(cur_block) + beta_ini + mean2(gau_noise1);
%       % var_ini = alpha_ini^2 * var(reshape(cur_block+gau_noise1,[],1)) + (1-alpha_ini^2)*var(gau_noise1(:));
%        E_2 = alpha_ini * mean2(cur_block2) + beta_ini + mean2(gau_noise2);
%        var_2 = alpha_ini^2 * var(reshape(cur_block2+gau_noise2,[],1)) + (1-alpha_ini^2)*var(gau_noise2(:));
%        E_vec(i,j,1) = E_ini;
%        var_vec(i,j,1) = var_ini;
%        E_vec(i,j,2) = E_2;
%        var_vec(i,j,2) = var_2;
%        gau_vec(i,j,1) = var(gau_noise1(:));
%        gau_vec(i,j,2) = var(gau_noise2(:));
%     end
% end
%% initialisation: get flickering params for the first two frames.
% for i = 1:vec_height
%     for j = 1:vec_width
%        head_i = (i-1)*block_height;
%        tail_i = i*block_height;
%        head_j = (j-1)*block_width;
%        tail_j = j*block_width;
%        gau_noise2 = sqrt(variance)*randn([block_height,block_width]);
%        cur_block1 = cur_frame1(head_i+1:tail_i,head_j+1:tail_j);
%        cur_block2 = cur_frame2(head_i+1:tail_i,head_j+1:tail_j);
%        %E_2 = alpha_ini * mean2(cur_block2) + beta_ini + mean2(gau_noise2);
%        %var_2 = alpha_ini^2 * var(reshape(cur_block2+gau_noise2,[],1)) + (1-alpha_ini^2)*var(gau_noise2(:));
%        alpha_2 = sqrt((var(cur_block2(:)) )/(var(cur_block1(:))));
%        alpha_2(isnan(alpha_2)) = 1;
%        beta_2 = mean2(cur_block2) - alpha_2 * mean2(cur_block1(:));
% 
% 
%        alpha_vec(i,j,2) = alpha_2;
%        beta_vec(i,j,2) = beta_2;
%        %E_vec(i,j,2) = E_2;
%        %var_vec(i,j,2) = var_2;
%        %gau_vec(i,j,2) = var(gau_noise2(:));
% 
%        restoration(head_i+1:tail_i,head_j+1:tail_j,2) = (v(head_i+1:tail_i,head_j+1:tail_j,2) - beta_2)/alpha_2;
%        if (alpha_2==0)
%            
%           1 
%        end
%     end
% end
% restoration(:,:,1) = v(:,:,1);


%E_2 = alpha_ini * mean2(cur_block2) + beta_ini + mean2(gau_noise2);
%var_2 = alpha_ini^2 * var(reshape(cur_block2+gau_noise2,[],1)) + (1-alpha_ini^2)*var(gau_noise2(:));
frame1 = v(:,:,1);
frame2 = v(:,:,2);
alpha_2 = sqrt((var(frame2(:)) )/(var(frame1(:))));
alpha_2(isnan(alpha_2)) = 1;
beta_2 = mean2(frame2) - alpha_2 * mean2(frame1);

restoration(:,:,2) = (frame1 - beta_2)/alpha_2;
restoration(:,:,1) = frame2;
alphas(2) = alpha_2;
betas(2) = beta_2;

%% updating E,var, alpha,beta
% This commented section is based on local region approach
% Uncommented this if result is not very expected.
% for t = 3:100
%     cur_frame = v(:,:,t);
%     for i = 1:vec_height
%         for j = 1:vec_width
%            head_i = (i-1)*block_height;
%            tail_i = i*block_height;
%            head_j = (j-1)*block_width;
%            tail_j = j*block_width;
%            frame_last = v(:,:,t-2);
%            gau_noise = sqrt(variance)*randn([block_height,block_width]);
%            cur_block = cur_frame(head_i+1:tail_i,head_j+1:tail_j);
%            block_2 = frame_last(head_i+1:tail_i,head_j+1:tail_j);
%            E_t = kappa * mean2(block_2) + (1-kappa) * (E_vec(i,j,t-1) - beta_vec(i,j,t-1))/(alpha_vec(i,j,t-1));
%            var_t = kappa * var(block_2(:)+gau_vec(i,j,t-2)) + (1-kappa) * (var_vec(i,j,t-1))/(alpha_vec(i,j,t-1)^2);
%            alpha_t = sqrt((var(cur_block(:)))/ var_t);
%            beta_t = mean2(cur_block(:)) - alpha_t * E_t;
%            
%            E_vec(i,j,t) = E_t;
%            var_vec(i,j,t) = var_t;
%            alpha_vec(i,j,t) = alpha_t;
%            beta_vec(i,j,t) = beta_t;
%            gau_vec(i,j,t) = var(gau_noise(:));
%         end
%     end  
% end
for t = 3:frame_num
    cur_frame = v(:,:,t);
    frame_last2 = restoration(:,:,t-2);
    frame_last1 = v(:,:,t-1);
    %gau_noise = sqrt(variance)*randn([block_height,block_width]);

    E_t = kappa * mean2(frame_last2) + (1-kappa) * (mean2(v(:,:,t-1)) - betas(t-1))/(alphas(t-1));
    var_t = kappa * var(frame_last2(:)) + (1-kappa) * (var(frame_last1(:)))/(alphas(t-1)^2);
    
    alpha_t = sqrt((var(frame_last1(:)) )/(var_t));
    alpha_t(isnan(alpha_t)) = 1;
    beta_t = mean2(cur_frame) - alpha_t * E_t;

    alphas(t) = alpha_t;
    betas(t) = beta_t;
    restoration(:,:,t) = (v(:,:,t) - beta_t)/alpha_t;
end


end

