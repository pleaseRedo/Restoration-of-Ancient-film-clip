function out = blotchDetection(v)
% path = 'footage';
% prefix = 'footage_';
% first = 001;
% last = 657;
% digits = 3;
% suffix = 'png';
% v = load_sequence(path, prefix, first, last, digits, suffix);
% v = double(v);


v = double(v);
out = v;
[height,width,frame_size] = size(out);
%ref_vec = zeros([length(2:359),476]);
refpoints = zeros(6,1);
dn = zeros(height,width,frame_size);
Tn=30;
cumulateSum = motionEstimate(v(:,:,1:frame_size), 10);
for t = 3:frame_size
    for i = 2:height-1
        for j = 1:width
            refpoints(1) = out(i-1,j,t-1);
            refpoints(2) = out(i,j,t-1);
            refpoints(3) = out(i+1,j,t-1);
            refpoints(4) = out(i-1,j,t-2);
            refpoints(5) = out(i,j,t-2);
            refpoints(6) = out(i+1,j,t-2);
            if (min(refpoints) - out(i,j,t)) > 0
                dn(i,j,t) = min(refpoints) - out(i,j,t);

            
            elseif (out(i,j,t) - max(refpoints)) > 0
                dn(i,j,t) = out(i,j,t) - max(refpoints);
            else
                dn(i,j,t) = 0;
            end
        end
    end
    img = out(:,:,t);
    d = dn(:,:,t);   
    d(d(:,:)<Tn) = 0;
    d(d(:,:)>0) = 1;    
    d = d .* imcomplement(cumulateSum(:,:,t));
    %imshow(uint8(d*255));
    %se = strel('square',3);
    rgSize = 2; 
    se = ones(rgSize, rgSize); 
    d = imdilate(d*255,se);
    %imshow(uint8(d*255))
    diff = (out(:,:,t-1) + out(:,:,t-2))/2;
    img = img.* imcomplement(d/255) + (d/255).*diff;
    %img(dn(:,:,t)>Tn) = diff(dn(:,:,t)>Tn);
    out(:,:,t) = img;
    %dn(dn(:,:,t)>Tn) = 255;
    %dn(dn(:,:,t)<Tn) = 0;
    %out(dn==255) = (v(i,j,t-1) + v(i,j,t+1))/2;
%Tn = max(max(dn*0.90));
end


%save_sequence(uint8(out), 'output2', prefix, first, digits);



end