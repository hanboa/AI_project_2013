function output = databaseIndexing(),
database = struct(); 

% read the dictionary
            %load IMAGE_WHITEN_AI.mat %IMAGES.mat
load dictionary_L1_b512_30600sampling_20140103T010408.mat
Dic = B;

% parametes for sampling
windowSize = 14;% the window size of a patch
num_totalSamples = 153;% the number for sampling total patches
num_thresholdSamples = 5;% the number of samples to decide a threshold
rand_values = struct();

% read the data from dictionary_dataset
path = 'dictionary_dataset/*.*g';
imgs = dir(path);
for i = 1 : length(imgs),
    img_path = sprintf('dictionary_dataset/%s',imgs(i).name);
    img = imread(img_path);
    img = filter_whiten(img);

    % get image patches
    [X_patches rand_values]= getdata_imagepatch(img, windowSize, num_totalSamples);
    X = X_patches';

    % dictioanry projection
    display 'DICTIONARY'
    re = X*Dic; % 153x512

    % binary code
    Y = zeros(size(re));
    Y(re>=0) = 1;

    % compact bits
    Y = reshape(Y, 1, size(Y,1)*size(Y,2));
    Y = compactbit(Y);
    
    % storing data to database
    database(i).name = imgs(i).name;
    database(i).category = getCategory( imgs(i).name );
    database(i).code = Y;
    display( sprintf('[%d/%d]', i,length(imgs)) );
end

% save the data
save('database.mat', 'database');


end


