if ~exist('LV_J')
    LV_J = loadjson('lv_sensor_parameters.json');
end

%% 导入IR
[path, name] = uigetfile('*.csv');
IR = csvread([name, path]);

% calculate local Amplitude
loc1 = IR(88:103, 221:230);
fprintf('区域【墙角】平均光强: %.2f LSB\n', mean(loc1(:)));

loc2 = IR(455:468, 364:384);
fprintf('区域【地面】平均光强: %.2f LSB\n', mean(loc2(:)));

loc3 = IR(119:138, 315:329);
fprintf('【4.1m_10%%漫反射板】平均光强: %.2f LSB\n', mean(loc3(:)));
%% 导入深度
[path, name] = uigetfile('*.csv');
D = csvread([name, path]);
% D(end,:) = [];

%% 计算旋转矩阵
figure(1)
clf(figure(1))
subplot(121)
imagesc(D);
title('Depth')
axis image
colormap jet
axis off
set(gca, 'CLim', [0 5000])
subplot(122)
imagesc(IR);
title('Amplitude')
axis image
colormap jet
axis off
set(gca, 'CLim', [0 255])

u = repmat([1:1:640],480,1);
v = repmat([1:1:480]',1, 640);
D(D>7500) = NaN;
X = (u-LV_J.sensor_parameter.cx)./LV_J.sensor_parameter.fx .* D;
Y = (v-LV_J.sensor_parameter.cy)./LV_J.sensor_parameter.fy .* D;
Z = D;

rotateMatrix = calcRT(0, 0, -38);
PC = rotateMatrix * [X(:) Y(:) Z(:)]';
X = PC(1,:);
Y = PC(2,:);
Z = PC(3,:);

figure(2)
clf(figure(2))
pcshow([X(:) Y(:) Z(:)] , Z(:), 'markerSize', 5)
set(gca, 'XColor', 'w')
set(gca, 'YColor', 'w')
set(gca, 'ZColor', 'w')
set(gca, 'Color', [0.3 0.3 0.3])
set(gcf, 'Color', [0.3 0.3 0.3])
% ylim([-3000 1500])
xlabel('X', 'color', 'w');
ylabel('Y', 'color', 'w');
zlabel('Z', 'color', 'w');
% zlim([0 5000])
colormap hsv
grid on
set(gca, 'CLim', [0 7500])
% view([1,0,0])
% view([0 0 -1])
set(gca, 'projection', 'perspective')
set(gca, 'CameraViewAngle', 70)
campos([0 -10 -5000])
camtarget([0 0 500])
box on

load('empty_TRUCK.mat')
X1 = X;
Y1 = Y;
Z1 = Z;
load('Box1.mat');
X2 = X;
Y2 = Y;
Z2 = Z;
figure(3)
clf(figure(3))
subplot(321)
imagesc(reshape(X1, 480, 640));
axis image
colormap jet
subplot(322)
imagesc(reshape(X2, 480, 640));
axis image
colormap jet
subplot(323)
imagesc(reshape(Y1, 480, 640));
axis image
colormap jet
subplot(324)
imagesc(reshape(Y2, 480, 640));
axis image
colormap jet
subplot(325)
imagesc(reshape(Z1, 480, 640));
axis image
colormap jet
subplot(326)
imagesc(reshape(Z2, 480, 640));
axis image
colormap jet

figure(3)
clf(figure(3))
subplot(121)
imagesc(reshape(Y1-Y2, 480, 640));
axis image
colormap jet
subplot(122)
diffY = reshape(Y1-Y2, 480, 640);
diffY((diffY) < 50) = 0;
imagesc(diffY);
axis image
colormap jet

idx = find(diffY > 0);
% 体素化
xmax = max(X2(idx));
xmin = min(X2(idx));
ymax = max(Y2(idx));
ymin = min(Y2(idx));
voxel_width = 40; %mm
X_size = ceil((xmax-xmin)/voxel_width);
Y_size = ceil((ymax-ymin)/voxel_width);
map = zeros(Y_size, X_size);
mapY = zeros(Y_size, X_size);
for i = 1:length(idx)
    idxX = round((X2(idx(i))-xmin)/voxel_width);
    idxY = round((Y2(idx(i))-ymin)/voxel_width);
    if idxX == 0
        idxX = 1;
    end
    if idxY == 0
        idxY = 1;
    end
    map(idxY, idxX) =  map(idxY, idxX) + 1;
    mapY(idxY, idxX) = mapY(idxY, idxX) + (Z2(idx(i)));
end
mapY = mapY./map;
figure(4)
clf(figure(4))
subplot(121)
imagesc(map)
axis image
color map
subplot(122)
imagesc(mapY)
axis image
color map

sumCol = sum(map,1);
idx_col = find(sumCol < max(sumCol)*0.3);
mapY(:, idx_col) = [];
sumCol(sumCol < max(sumCol)*0.3) = [];
sumRow = sum(map,2);
% sumRow(sumRow < max(sumRow)*0.3) = [];

figure(5)
clf(figure(5))
subplot(221)
plot(sumCol)
subplot(222)
plot(sumRow)
subplot(223)
imagesc(mapY)
axis image
color map

xBin = length(sumCol) * voxel_width; % 长度方向尺寸
yBin = length(sumRow) * voxel_width; % 长度方向尺寸
%车厢总长度
tL = sort(Z1(:));
tL = tL(round(length(tL)*0.95));
zBin = nanmean(mapY(:));
V = (xBin)*(yBin)*(tL-zBin)/1e9;
fprintf('箱子体积为：%.2f m^3\n', V)

figure(2)
clf(figure(2))
pcshow([X(:) Y(:) Z(:)] , 'w', 'markerSize', 1)
hold on
pcshow([X2(idx)' Y2(idx)' Z2(idx)'] , 'r', 'markerSize', 5)
set(gca, 'XColor', 'w')
set(gca, 'YColor', 'w')
set(gca, 'ZColor', 'w')
set(gca, 'Color', [0.3 0.3 0.3])
set(gcf, 'Color', [0.3 0.3 0.3])
% ylim([-3000 1500])
xlabel('X', 'color', 'w');
ylabel('Y', 'color', 'w');
zlabel('Z', 'color', 'w');
% zlim([0 5000])
colormap hsv
grid on
set(gca, 'CLim', [0 7500])
% view([1,0,0])
% view([0 0 -1])
set(gca, 'projection', 'perspective')
title(sprintf('箱子体积为：%.2f m^3\n', V), 'color', 'w')
set(gca, 'CameraViewAngle', 70)
campos([0 -10 -5000])
camtarget([0 0 500])
box on

% meanZ = mean(Z2(idx));
% box_depth = max(Z1(:)) - meanZ;
% V = (xmax-xmin)*(ymax-ymin)*box_depth/1e9;