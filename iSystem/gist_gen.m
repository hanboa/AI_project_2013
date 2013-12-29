function output = gist_gen()
% Generate GIST descriptor
load IMAGES
img = IMAGES;
num_img = size(IMAGES,3);
% Parameters:
clear param

param.orientationsPerScale = [8 8 8 8];
param.numberBlocks = 4;
param.fc_prefilt = 4;

% Computing gist requires 1) prefilter image, 2) filter image and collect
% output energies
gist = [];
for i = 1 : num_img,
  param.imageSize = size( img(:,:,i) ); % it works also with non-square images
  [gist(i,:), param] = LMgist(img(:,:,i), '', param);
end

% % Visualization
for i = 1 : num_img,
   figure;
   subplot(1,2,1);
   imshow(img(:,:,i));
   title('Input images');
   subplot(1,2,2);
   showGist(gist(i,:), param);
   title('Descriptor');
end

output = gist;

end
