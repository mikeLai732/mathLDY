function output = voxelized(inputXYZ, xmin, xmax, ymin, ymax, voxel_width)
%% voxelized PCdata into matrix Data
X_size = ceil((xmax-xmin)/voxel_width);
Y_size = ceil((ymax-ymin)/voxel_width);
map = zeros(Y_size, X_size);
mapZ = zeros(Y_size, X_size);
for i = 1:length(inputXYZ.x)
    idxX = round((inputXYZ.x(i)-xmin)/voxel_width);
    idxY = round((inputXYZ.y(i)-ymin)/voxel_width);
    if idxX >= 1  && idxX <= X_size && idxY >= 1  && idxY <= Y_size
        map(idxY, idxX) =  map(idxY, idxX) + 1;
        mapZ(idxY, idxX) = mapZ(idxY, idxX) + (inputXYZ.z(i));
    end
end
mapZ = mapZ./map;
output.map = map;
output.value = mapZ;
