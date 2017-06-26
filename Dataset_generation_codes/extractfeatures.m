path = path_files();
path_size = size(path,2);
for itr=1:path_size
img = imread(path{itr});
training{itr+12000}=chip_histogram_features(img);
%display(itr);
end
