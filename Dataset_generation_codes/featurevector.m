path = path_files();
path_size = size(path,2);
for itr=1:path_size
imgitr{itr+12000} = imread(path{itr});
end
