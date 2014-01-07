function output = query(numQuery, numRetrieve)
querySet = struct();

% parameters for query
if ~exist('numQuery'),
<<<<<<< HEAD
    numQuery = 5;
=======
    numQuery = 1;
    [filename, pathname ]= uigetfile(sprintf('%s/queries/*.*g',pwd), 'Query');% get the query image by yourself
    filename = fullfile(pathname, filename);
    display(filename)
%     file_path = sprintf('queries/%s',filename);
%     display(file_path);
%     figure;imshow(file_path);
>>>>>>> 89bbe66b3418d24a2ce8584d87bc639e4de2e7aa
end
if ~exist('numRetrieve'),
    numRetrieve = 6;
end

% load data from indexed database, dictionary
clear database;
db = load('database.mat');
database = db.database;
clear db;
load dictionary_L1_b512_30600sampling_20140103T010408.mat
Dic = B;

% parameters for sampling patches
windowSize = 14;% the window size of a patch
num_totalSamples = 200;% the number for sampling total patches
rand_values = struct();

% query and read the data from "queries"
path = '../queries/*.*g';
imgs = dir(path);
<<<<<<< HEAD
i = numQuery;
%for i = 1 : numQuery, 
    img_path = sprintf('../queries/%s',imgs(i).name);
=======
for i = 1 : numQuery, 
    %img_path = sprintf('queries/%s',imgs(i).name);
    img_path = filename;
>>>>>>> 89bbe66b3418d24a2ce8584d87bc639e4de2e7aa
    img = imread(img_path);
    img = filter_whiten(img);

    % get image patches for the query
    [X_patches rand_values]= getdata_imagepatch(img, windowSize, num_totalSamples);
    X = X_patches';

    % Dictioanry projection
    display 'Dictionary Projection:'
    re = X*Dic; % 153x512

    % Binary code
    Y = zeros(size(re));
    Y(re>=0) = 1;

    % Compact bits
    Y = compactbit(Y);
    
    % storing data to querySet
    querySet(i).name = imgs(i).name;
    querySet(i).category = getCategory( imgs(i).name );
    querySet(i).code = Y;
    
    % Hamming distance
    display 'Hamming Distance:'
    querySet(i).diffenence = zeros(length(database),1);
    for j = 1 : length(database),
       B1 = querySet(i).code;
       B2 = database(j).code;
       
       % calculate hamming distance
       querySet(i).difference(j,1) = hammingDist(B1, B2);
       display( sprintf('Checking Database: [%d/%d]', j,length(database)) );
    end
    [querySet(i).sortedValues querySet(i).sortedIndex] = sort(querySet(i).difference);
    
    % show query image
    im = imread(img_path);
    figure; 
    imshow(im);title(sprintf('Query Image %d %s', i, querySet(i).name));
    
    % show retrieved images
    figure;
    title('Retrieved Images');
    topNumber = numRetrieve;
    if numRetrieve < 3
        Numrow = 1;
    else
        Numrow = 2;
    end
    Numcolumn = ceil(numRetrieve/Numrow);
    for j = 1 : topNumber,
        index = querySet(i).sortedIndex(j);
        db = database(index);
        path = sprintf('../dataset/%s', db.name);
        im = imread(path);
        subplot(Numrow, Numcolumn, j);
        imshow(im);
    end
    
    display( sprintf('Query Done: [%d/%d]', i,length(imgs)) );
end

%end
