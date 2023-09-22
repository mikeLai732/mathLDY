fx = cameraParams.IntrinsicMatrix(1,1);
fy = cameraParams.IntrinsicMatrix(2,2);
cx = cameraParams.IntrinsicMatrix(3,1);
cy = cameraParams.IntrinsicMatrix(3,2);
p1 = 0;
p2 = 0;
k1 = cameraParams.RadialDistortion(1)*0.95;
k2 = cameraParams.RadialDistortion(2)*0.98;
k3 = cameraParams.RadialDistortion(3)*0.91;
%% 去畸变(保FOV)
% picName = ['F:\2021-11-15-Riverside\2023.5.29-6.2\cameraData_interGroup\CameraCalibration1\' ,num2str(i), '.png'];
% picPath = uigetdir;
% picName = [picPath, '\1.png'];
[picName, picPath] = uigetfile('*.bmp');
strfileNum = picPath;
strfileNum = strsplit(strfileNum, '\');
strfileNum = strfileNum{end-1};
inpIM = imread([picPath, picName]);
IM = double(inpIM);
IM = IM(:,:,1);
% figure(3)
% subplot(211)
% imshow(inpIM)
% axis image
X = zeros(size(IM,1)*size(IM,2), 1);
Y = zeros(size(IM,1)*size(IM,2), 1);
UX = zeros(size(IM,1)*size(IM,2), 1);
UY = zeros(size(IM,1)*size(IM,2), 1);
ind = 1;
for vd = 1:size(inpIM, 1)
    for ud = 1:size(inpIM, 2)
        xd = (ud-cx)/fx;
        yd = (vd-cy)/fy;
        X(ind) = xd;
        Y(ind) = yd;
        rd = sqrt(xd^2 + yd^2);
%         if vd < 450 && vd > 31 && ud < 600 && ud > 41
%             r = NewtonGaussian(rd, k1, k2, k3, 0.00001);
%         else
            r = NewtonGaussian(rd, k1, k2, k3, 0.05);
%         end
        
        x = xd/(1 + k1 * r^2 + k2 * r^4 + k3 * r^6);
        y = yd/(1 + k1 * r^2 + k2*  r^4 + k3 * r^6);
        UX(ind) = x;
        UY(ind) = y;
        ind = ind + 1;
    end
    fprintf('***Finished Row: %d\n', vd);
end
% figure(3)
% clf(figure(3))
% subplot(121)
% plot(X, Y, '.')
% ylabel('畸变后')
% subplot(122)
% plot(UX, UY, '.')
% ylabel('畸变前')
% UX1 = reshape(UX, 640, 480)';
% UY1 = reshape(UY, 640, 480)';
% minX = max(UX1(:,1));
% maxX = min(UX1(:,end));
% maxY = min(UY1(end,:));
% minY = max(UY1(1,:));
% hold on
% rectangle('position', [minX minY maxX-minX maxY-minY], 'edgeColor', 'r', 'lineWidth', 3)
% minX = min(UX1(:,1));
% maxX = max(UX1(:,end));
% maxY = max(UY1(end,:));
% minY = min(UY1(1,:));
% hold on
% rectangle('position', [minX minY maxX-minX maxY-minY], 'edgeColor', 'r', 'lineWidth', 3)
figure(3)
clf(figure(3))
subplot(121)
scatter(X, Y, [], reshape(IM', size(IM,1)*size(IM,2), 1), '.')
axis image
ylabel('畸变后')
subplot(122)
scatter(UX, UY, [], reshape(IM', size(IM,1)*size(IM,2), 1), '.')
axis image
ylabel('畸变前')
UX1 = reshape(UX, size(IM,2), size(IM,1))';
UY1 = reshape(UY, size(IM,2), size(IM,1))';
binX1 = filterPoint((UX1(:, 1)));
binX2 = filterPoint((UX1(:, end)));
binY1 = filterPoint((UY1(1, :)));
binY2 = filterPoint((UY1(end, :)));
binX1(binX1 > 0) = [];
binX2(binX2 < 0) = [];
binY1(binY1 > 0) = [];
binY2(binY2 < 0) = [];
minX1 = max(binX1);
maxX1 = min(binX2);
maxY1 = min(binY2);
minY1 = max(binY1);
hold on
rectangle('position', [minX1 minY1 maxX1-minX1 maxY1-minY1], 'edgeColor', 'r', 'lineWidth', 3)
minX2 = min(binX1);
maxX2 = max(binX2);
maxY2 = max(binY2);
minY2 = min(binY1);
hold on
rectangle('position', [minX2 minY2 maxX2-minX2 maxY2-minY2], 'edgeColor', 'r', 'lineWidth', 3)
inner = [minX1, minY1, maxX1-minX1, maxY1-minY1];
outer = [minX2, minY2, maxX2-minX2, maxY2-minY2];
%% 重构内参[标定模型中f = 1] fx1 = f/dx1
dx1 = (maxX1-minX1)/size(IM,2);
dy1 = (maxY1-minY1)/size(IM,1);
% fx1 = 1/dx1;
% fy1 = 1/dy1;
cx1 = 1/dx1*(0-inner(1));
cy1 = 1/dy1*(0-inner(2));
dx2 = (maxX2-minX2)/size(IM,2);
dy2 = (maxY2-minY2)/size(IM,1);
% fx2 = 1/dx2;
% fy2 = 1/dy2;
cx2 = 1/dx2*(0-outer(1));
cy2 = 1/dy2*(0-outer(2));
alpha = 0;
dx = dx1 * (1-alpha) + dx2 * alpha; %扩展投影矩阵
dy = dy1 * (1-alpha) + dy2 * alpha;
fx_new = 1/dx;
fy_new = 1/dy;
cx_new = cx1 * (1-alpha) + cx2 * alpha; %扩展投影矩阵
cy_new = cy1 * (1-alpha) + cy2 * alpha;
startX = minX1 * (1-alpha) + minX2 * alpha;
startY = minY1 * (1-alpha) + minY2 * alpha;
TempLate = [];
% xx = [];
% yy = [];
fprintf('新内参为:\nfx:%.8f\nfy:%.8f\ncx:%.8f\ncy:%.8f\nk1:%.8f\nk2:%.8f\nk3:%.8f\n', fx_new, fy_new, cx_new, cy_new, k1, k2, k3);
fid = fopen([picPath, '\lv_sensor_parameters.json'], 'w+');
fprintf(fid, '{\n\t"sensor_parameter":{\n\t\t"fx":%.8f,\n\t\t"fy":%.8f,\n\t\t"cx":%.8f,\n\t\t"cy":%.8f,\n\t\t"k1":%.8f,\n\t\t"k2":%.8f,\n\t\t"k3":%.8f\n\t}\n}', fx_new, fy_new, cx_new, cy_new, k1, k2, k3);
fclose(fid);
fprintf('畸变系数为:\nk1:%.4f\nk2:%.4f\nk3:%.4f\n', k1, k2, k3);
fprintf('旧内参为: fx:%.4f-fy:%.4f-cx:%.4f-cy:%.4f\n', fx, fy, cx, cy);
for v = 1:size(inpIM, 1)
    for u = 1:size(inpIM, 2)
        %%%%%%%%标准物理坐标【可以自定义重投影矩阵】%%%%%%%%%%%%%%%%
        x = startX + (u-1) * dx;
        y = startY + (v-1) * dy;
        r = sqrt(x^2 + y^2);
        %%%%%%%%标准物理坐标->畸变物理坐标%%%%%%%%%%%%%%%%
        xd = x * (1 + k1 * r^2 + k2 * r^4 + k3 * r^6);
        yd = y * (1 + k1 * r^2 + k2 * r^4 + k3 * r^6);
%         xx = [xx xd];
%         yy = [yy yd];
        %%%%%%%%%畸变物理坐标->畸变像素坐标【必须使用原生投影矩阵】%%%%%%%%%%%%%%%%
        ud = cx + fx * xd;
        vd = cy + fy * yd;
        TempLate{v, u} = [round(vd) round(ud)];
    end
end
% figure(4)
% clf(figure(4))
% scatter(X, Y, [], reshape(IM', 480*640, 1), '.')
% hold on
% plot(X1, Y1, 'ro');

currentDIR = pwd;
cd(picPath);
files = dir('*.bmp');
for i = 1:length(files)
    picName = [picPath ,'\', files(i).name];
    inpIM = imread(picName);
    figure(2)
    subplot(211)
    imshow(inpIM)
    ylabel('畸变图像', 'fontSize', 14)
    axis image
    undistorted_IM = zeros(480, 640);
    for v = 1:size(inpIM, 1)
        for u = 1:size(inpIM, 2)
            if TempLate{v, u}(1) >=1 && TempLate{v, u}(1) <= 480 &&...
                    TempLate{v, u}(2) >=1 && TempLate{v, u}(2) <= 640
                undistorted_IM(v, u) = inpIM(TempLate{v, u}(1),TempLate{v, u}(2));
            end
        end
    end
    subplot(212)
    imshow(uint8(undistorted_IM))
    ylabel('保留FOV去畸变图像', 'fontSize', 14)
    axis image
    drawnow()
end
cd(currentDIR);

%% 畸变校正表制作
LensDIST = zeros(480, 640);
for row = 1:size(IM, 1)
    for col = 1:size(IM, 2)
        LensDIST(row, col) = (TempLate{row, col}(1)-1)*640 + (TempLate{row, col}(2)-1);
    end
end

fid = fopen([picPath, '\Distortion_LUT.txt'], 'w+');
for row = 1:size(IM, 1)
    for col = 1:size(IM, 2)
        if col < size(IM, 2)
            fprintf(fid, '%d\t', LensDIST(row, col));
        else
            fprintf(fid, '%d', LensDIST(row, col));
        end
    end
    if row < size(IM, 1)
        fprintf(fid, '\n');
    end
end
fclose(fid);

%% 弯曲表制作
u = repmat([1:1:size(IM,2)], size(IM,1), 1);
v = repmat([1:1:size(IM,1)]', 1, size(IM,2));
bendCorr = cos(atan(sqrt(((u-cx_new)/(fx_new*1)).^2 + ((v-cy_new)/(fy_new*1)).^2)));

fid = fopen([picPath, '\Bending_LUT.txt'], 'w+');
for row = 1:size(bendCorr, 1)
    for col = 1:size(bendCorr, 2)
        if col < size(bendCorr, 2)
            fprintf(fid, '%f\t', bendCorr(row, col));
        else
            fprintf(fid, '%f', bendCorr(row, col));
        end
    end
    if row < size(bendCorr, 1)
        fprintf(fid, '\n');
    end
end
fclose(fid);

callback1 = scpTransportFile('root', '', '192.168.1.200', [picPath, '\lv_sensor_parameters.json'], '/home/root/lv_machine/import', 0);
if callback1 == 0
    disp('畸变表导入成功');
end
callback2 = scpTransportFile('root', '', '192.168.1.200', [picPath, '\Distortion_LUT.txt'],'/home/root/lv_machine/import', 0);
if callback2 == 0
    disp('畸变标定表');
end
callback3 = scpTransportFile('root', '', '192.168.1.200', [picPath, '\Bending_LUT.txt'],'/home/root/lv_machine/import', 0);
if callback3 == 0
    disp('弯曲补偿表');
end