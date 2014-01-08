function [X rand_values]= getdata_imagepatch(img, winsize, num_patches)

image_size=size(img,1);
sz= winsize;
BUFF=4;

totalsamples = 0;
% extract subimg at random from this image to make data vector X
% Step through the img
X= zeros(sz^2, num_patches);
this_image=img(:,:);

% Determine how many patches to take
getsample = num_patches;

%recode the random values
rand_values.r = zeros(1,getsample);
rand_values.c = zeros(1,getsample);
% Extract patches at random from this image to make data vector X
for j=1:getsample
    rand_values.r(j) = rand;
    rand_values.c(j) = rand;
    r=BUFF+ceil((image_size-sz-2*BUFF)*rand_values.r(j));
    c=BUFF+ceil((image_size-sz-2*BUFF)*rand_values.c(j));
    totalsamples = totalsamples + 1;
    % X(:,totalsamples)=reshape(this_image(r:r+sz-1,c:c+sz-1),sz^2,1);
    temp =reshape(this_image(r:r+sz-1,c:c+sz-1),sz^2,1);
    X(:,totalsamples) = temp - mean(temp);
end