function output = voxelized(inputXYZ, voxelPara)
%% voxelized PCdata into matrix Data
X_size = ceil((voxelPara.xmax-voxelPara.xmin)/voxelPara.voxel_width);
Y_size = ceil((voxelPara.ymax-voxelPara.ymin)/voxelPara.voxel_width);
map = zeros(Y_size, X_size);
mapZ = zeros(Y_size, X_size, 1000);
for i = 1:length(inputXYZ.x)
    idxX = round((inputXYZ.x(i)-voxelPara.xmin)/voxelPara.voxel_width);
    idxY = round((inputXYZ.y(i)-voxelPara.ymin)/voxelPara.voxel_width);
    if idxX >= 1  && idxX <= X_size && idxY >= 1  && idxY <= Y_size
        map(idxY, idxX) =  map(idxY, idxX) + 1;
        mapZ(idxY, idxX, map(idxY, idxX)) = (inputXYZ.z(i));
%         if idxX == 18 && idxY == 38
%             inputXYZ.z(i)
%         end
    end
end
tmpVal = zeros(Y_size, X_size);
for r = 1:size(mapZ,1)
    for c = 1:size(mapZ,2)
        if map(r,c) ~= 0
            if map(r,c) < 3
                tmpData = mapZ(r,c,1:map(r,c));
                tmpData = tmpData(:);
                tmpData = sort(tmpData);
                tmpVal(r,c) = tmpData(1);
            else
                tmpData = mapZ(r,c,1:map(r,c));
                tmpData = tmpData(:);
                tmpData = sort(tmpData);
                tmpVal(r,c) = tmpData(round(length(tmpData)/3));
            end
        end
    end
end
output.map = map;
output.value = tmpVal;
% figure;imagesc(output.map)
% figure;imagesc(output.value)