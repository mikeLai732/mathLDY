%% 导入内参
if ~exist('LV_J')
    LV_J = loadjson('lv_sensor_parameters.json');
end

%% 计算体积
fid = fopen('empty.bin', 'r');
empty = fread(fid, 480*640, 'uint16');
fclose(fid);
empty = reshape(empty, 640, 480)';
% figure(3)
% clf(figure(3))
% subplot(131)
% imagesc(empty)
% axis image
% colormap jet
% set(gca, 'CLim', [0 4500])
% subplot(132)
% imagesc(box)
% axis image
% colormap jet
% set(gca, 'CLim', [0 4500])
% subplot(133)
% imagesc((box-empty))
% axis image
% colormap jet
% 
% 
% diffIM = box-empty;
% diffIM(diffIM > 10) = 0;
% diffIM(abs(diffIM) < 10) = 0;
% figure(3)
% clf(figure(3))
% imagesc(diffIM)
% axis image
% colormap jet

outputXYZ.empty = calcPC(empty, LV_J, -41);
%% 模板体素化
sortX = sort(outputXYZ.empty.x);
sortY = sort(outputXYZ.empty.y);
xmax = sortX(round(length(sortX)*0.99));
xmin = sortX(round(length(sortX)*0.01));
ymax = sortY(round(length(sortX)*0.99));
ymin = sortY(round(length(sortX)*0.01));
voxel_width = 50; %mm
Empty = voxelized(outputXYZ.empty, xmin, xmax, ymin, ymax, voxel_width);

%% 搜寻上下界限
BOUND = Empty.map;
BOUND(BOUND < 50) = 0;
BOUND(BOUND >= 50) = 1;
figure(11)
subplot(221)
imagesc(BOUND)
axis image
subplot(222)
%%边界搜寻
plot(sum(BOUND,2))
subplot(223)
plot(abs(diff(sum(BOUND,2))))
subplot(224)
plot(abs(diff(sum(BOUND,1))))
diffLineUD = abs(diff(sum(BOUND,2)));
diffLineLR = abs(diff(sum(BOUND,1)));
ud = find(diffLineUD < max(diffLineUD)*0.5);
lr = find(diffLineLR > max(diffLineLR)*0.5);
ud = [ud(1)-1 ud(end)];
lr = [lr(1) lr(2)+1];
% histogram(BOUND)
%% 实时点云体素化
name = inputdlg('输入动图命名');
V_result = [];
for b = 1:6
    fid = fopen(['box', num2str(b),'.bin'], 'r');
    box = fread(fid, 480*640, 'uint16');
    fclose(fid);
    box = reshape(box, 640, 480)';
    outputXYZ.box = calcPC(box, LV_J, -41);
    Box = voxelized(outputXYZ.box, xmin, xmax, ymin, ymax, voxel_width);
    Box.map(ud(2):end,:) = 0;
    Box.value(ud(2):end,:) = 0;
    Empty.map(ud(2):end,:) = 0;
    Empty.value(ud(2):end,:) = 0;
    Box.map(1:ud(1),:) = 0;
    Box.value(1:ud(1),:) = 0;
    Empty.map(1:ud(1),:) = 0;
    Empty.value(1:ud(1),:) = 0;
    Box.map(:,lr(2):end) = 0;
    Box.value(:,lr(2):end) = 0;
    Empty.map(:,lr(2):end) = 0;
    Empty.value(:,lr(2):end) = 0;
    Box.map(:,1:lr(1)) = 0;
    Box.value(:,1:lr(1)) = 0;
    Empty.map(:,1:lr(1)) = 0;
    Empty.value(:,1:lr(1)) = 0;
    
    figure(6)
    clf(figure(6))
    subplot(221)
    imagesc(Empty.map)
    axis image
    colormap jet
    subplot(222)
    imagesc(Empty.value)
    axis image
    colormap jet
    subplot(223)
    imagesc(Box.map)
    axis image
    colormap jet
    subplot(224)
    imagesc(Box.value)
    axis image
    colormap jet
    
    %% 实时点云与背景点云差异
    diffVoxel = abs(Box.value-Empty.value);
    diffVoxel(diffVoxel < 5) = 0;
    figure(7)
    clf(figure(7))
    subplot(121)
    imagesc(diffVoxel)
    axis image
    colormap jet
    %% 计算体积
    diffVoxel = diffVoxel * voxel_width * voxel_width;
    V = nansum(diffVoxel(:))/1e9;
    title(sprintf('基于体素计算体积 | 当前体积为： %.2f m^3', V), 'fontSize', 14);
    V_result = [V_result V];
    subplot(122)
    plot(V_result, 'o-', 'markerSize', 10, 'lineWidth', 1.5)
    xlim([1 6])
    grid on
    xlabel('箱子数 [个]', 'FontSize', 16)
    ylabel('体积 [m^3]', 'FontSize', 16)
    title('箱子个数—体积变化曲线', 'FontSize', 16);
    drawnow
    
    fr = getframe(figure(7));
    im = frame2im(fr);
    [A, map] = rgb2ind(im, 256);
    if b == 1
        imwrite(A, map, [name{1}, '.gif'], 'LOOPCOUNT', Inf, 'DelayTime', 0.5);
    elseif b < 6
        imwrite(A, map, [name{1}, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
    else
        imwrite(A, map, [name{1}, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 5);
    end   
end

V_ideal = 0.9*0.6*0.6;
V_ideal = V_ideal .*(1:1:6);
V_real = 0.3;
V_real = V_real .*(1:1:6);
figure(8)
clf(figure(8))
plot(V_result, 'o-', 'markerSize', 10, 'lineWidth', 1.5)
hold on
plot(V_ideal , 'g--', 'lineWidth', 1.0)
hold on
plot(V_real , 'r--', 'lineWidth', 0.5)
for i = 1:6
    hold on
    text(i-0.3, V_real(i)-0.1, sprintf('error：%.2f %%', abs((V_result(i)-V_real(i))/(3.9*2*2))*100), 'color', 'r')
end
grid on
legend('体素计算结果', '纸箱规格体积', '实际体积') %(由于箱子摆放存在间隙)
xlabel('箱子数 [个]', 'FontSize', 16)
ylabel('体积 [m^3]', 'FontSize', 16)
title('【客户】箱子个数—体积变化曲线', 'FontSize', 16);

result = [V_real(:) V_result(:)]';
result = result(:);
result = result';
csvwrite('movingBox.csv', result);