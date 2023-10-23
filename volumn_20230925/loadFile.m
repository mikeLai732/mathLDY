currentDIR = pwd;
enterDIR = uigetdir;
cd(enterDIR);
fs = dir('*.csv');
flagA = 1;
flagD = 1;
tmpAMP = [];
tmpDIS = [];
for ff = 1:length(fs)
    fn = strsplit(fs(ff).name, '_');
    if ismember('amplitude', fn)
        tmpAMP(:,:,flagA) = csvread(fs(ff).name);
        flagA = flagA + 1;
    end
    if ismember('distance', fn)
        tmpDIS(:,:,flagD) = csvread(fs(ff).name);
        flagD = flagD + 1;
    end
end
cd(currentDIR);

name = inputdlg('输入动图命名');
for f = 1:size(tmpDIS, 3)
    figure(2)
    clf(figure(2))
    imagesc(tmpDIS(1:480,:,f))
    axis image
    colormap jet
    set(gca, 'CLim', [0 4500])
    axis off
    drawnow
    
    fr = getframe(figure(2));
    im = frame2im(fr);
    [A, map] = rgb2ind(im, 256);
    if f == 1
        imwrite(A, map, [name{1}, '.gif'], 'LOOPCOUNT', Inf, 'DelayTime', 0.1);
    elseif f < size(tmpDIS, 3)
        imwrite(A, map, [name{1}, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
    else
        imwrite(A, map, [name{1}, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 5);
    end   
end
tmpDIS = sort(tmpDIS(:, :, 1:100), 3);
tmpDIS = mean(tmpDIS(1:480, :, 46:55), 3);
figure(3)
clf(figure(3))
imagesc(tmpDIS)
axis image
colormap jet
set(gca, 'CLim', [0 4500])
drawnow

%% 中值滤波
for r = 1:480
    for c = 1:640
        binR = r-2:r+2;
        binC = c-2:c+2;
        binR(binR < 1) = [];
        binR(binR > 480) = [];
        binC(binC < 1) = [];
        binC(binC > 640) = [];
        locDIS = tmpDIS(binR, binC);
        locDIS = locDIS(:);
        tmpDIS(r,c) = locDIS(round(length(locDIS)/2));
    end
end
figure(3)
clf(figure(3))
imagesc(tmpDIS)
axis image
colormap jet
set(gca, 'CLim', [0 4500])
drawnow

%% 生成点云
D = tmpDIS;
u = repmat([1:1:640],480,1);
v = repmat([1:1:480]',1, 640);
D(D>7500) = NaN;
X = (u-LV_J.sensor_parameter.cx)./LV_J.sensor_parameter.fx .* D;
Y = (v-LV_J.sensor_parameter.cy)./LV_J.sensor_parameter.fy .* D;
Z = D;

rotateMatrix = calcRT(0, 0, -41);
PC = rotateMatrix * [X(:) Y(:) Z(:)]';
X = PC(1,:);
Y = PC(2,:);
Z = PC(3,:);

figure(4)
clf(figure(4))
pcshow([X(:) Y(:) Z(:)] , Z(:), 'markerSize', 5)
set(gca, 'XColor', 'w')
set(gca, 'YColor', 'w')
set(gca, 'ZColor', 'w')
set(gca, 'Color', [0.3 0.3 0.3])
set(gcf, 'Color', [0.3 0.3 0.3])
xlabel('X', 'color', 'w');
ylabel('Y', 'color', 'w');
zlabel('Z', 'color', 'w');
colormap hsv
grid on
set(gca, 'CLim', [0 7500])
set(gca, 'projection', 'perspective')
set(gca, 'CameraViewAngle', 70)
campos([0 -10 -5000])
camtarget([0 0 500])
box on

%% 导出二进制
genBin;