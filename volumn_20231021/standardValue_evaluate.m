%% 导入内参
if ~exist('LV_J')
    LV_J = loadjson('lv_sensor_parameters.json');
    load('rotateMat.mat');
end
%% 导入空车标定文件
[fn, fp] = uigetfile('*.bin');
% rotateDegree = -38;
fid = fopen([fp,fn], 'r');
empty = fread(fid, 480*640, 'uint16');
fclose(fid);
empty = reshape(empty, 640, 480)';
outputXYZ.empty = calcPC(empty, LV_J, rotate, 1); % 计算点云
%% 模板体素化
sortX = sort(outputXYZ.empty.x);
sortY = sort(outputXYZ.empty.y);
voxelPara.xmax = sortX(round(length(sortX)*0.99)); % 定义体素参数结构体
voxelPara.xmin = sortX(round(length(sortX)*0.01));
voxelPara.ymax = sortY(round(length(sortX)*0.99));
voxelPara.ymin = sortY(round(length(sortX)*0.01));
voxelPara.voxel_width = 50; %mm
Empty = voxelized(outputXYZ.empty, voxelPara);
%% 搜寻上下界限
BOUND = Empty.map;
BOUND(BOUND < 50) = 0;
BOUND(BOUND >= 50) = 1;
figure(11)
subplot(221)
imagesc(BOUND)
axis image
subplot(222)
plot(sum(BOUND,2))
subplot(223)
plot(abs(diff(sum(BOUND,2))))
subplot(224)
plot(abs(diff(sum(BOUND,1))))
diffLineUD = abs(diff(sum(BOUND,2)));
diffLineLR = abs(diff(sum(BOUND,1)));
%% 一维聚类
[~, ud] = oneDCluster(diffLineUD);
[~, lr] = oneDCluster(diffLineLR);
ud = [ud(1)-1 ud(end)+2];
lr = [lr(1)-1 lr(end)+2];
mask = ones(size(BOUND,1), size(BOUND,2));
mask(1:ud(1),:) = 0;
mask(ud(2):end,:) = 0;
mask(:, 1:lr(1)) = 0;
mask(:, lr(2):end) = 0;
%% load Box data
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

% name = inputdlg('输入动图命名');
% for f = 1:size(tmpDIS, 3)
%     figure(2)
%     clf(figure(2))
%     imagesc(tmpDIS(1:480,:,f))
%     axis image
%     colormap jet
%     set(gca, 'CLim', [0 4500])
%     axis off
%     drawnow
%     
%     fr = getframe(figure(2));
%     im = frame2im(fr);
%     [A, map] = rgb2ind(im, 256);
%     if f == 1
%         imwrite(A, map, [name{1}, '.gif'], 'LOOPCOUNT', Inf, 'DelayTime', 0.1);
%     elseif f < size(tmpDIS, 3)
%         imwrite(A, map, [name{1}, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
%     else
%         imwrite(A, map, [name{1}, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 5);
%     end   
% end
% stdStream = std(tmpDIS, 0, 3);
% figure(3)
% clf(figure(3))
% imagesc(stdStream)
% axis image
% colormap jet
% set(gca, 'CLim', [0 200])
% axis off
% colorbar
%% 随机选取数据查看精度
% [idxX, idxY] = find(stdStream >= 200 & stdStream < 500);
% randIDX = randperm(length(idxX), 1);
% figure(5);
% clf(figure(5))
% cla
% plot(reshape(tmpDIS(idxX(randIDX), idxY(randIDX), :),1,size(tmpDIS,3)));
% title([sprintf('【行】%d\t【列】%d\t',idxX(randIDX), idxY(randIDX)),'精度', num2str(stdStream(idxX(randIDX), idxY(randIDX)))])
%% 短时窗
ptr = 1;
windData = [];
frame = 30;
stdTrace = [];
V_res = [];
MAP = [];
VAL = [];
for f = 1:size(tmpDIS, 3)
    if f <= frame
        tmpD = tmpDIS(1:480, :, f);
        tmpA = tmpAMP(1:480, :, f);
        tmpD(tmpA < 25) = NaN;
        tmpD(isnan(tmpD)) = empty(isnan(tmpD));
        windData(:,:,ptr) = tmpD;
        ptr = ptr + 1;
    else
        ptr = mod(ptr,frame);
        if ptr == 0
            ptr = frame;
        end
        tmpD = tmpDIS(1:480, :, f);
        tmpA = tmpAMP(1:480, :, f);
        tmpD(tmpA < 25) = NaN;
        tmpD(isnan(tmpD)) = empty(isnan(tmpD));
        windData(:,:,ptr) = tmpD;
        stdTrace = [stdTrace reshape(std(windData,0,3)', size(windData,1)*size(windData, 2), 1)];
        figure(4)
        clf(figure(4))
        subplot(121)
        imagesc(std(windData,0,3))
        axis image
        colormap jet
        set(gca, 'CLim', [0 200])
        title('短时精度流')
        subplot(122)
        s_windData = sort(windData,3);
        imagesc(s_windData(1:480, :, round(frame/2)))
        set(gca, 'CLim', [0 5000])
        title('中值')
        axis image
        colormap jet
        
        [V, BOX] = calcV(s_windData(1:480, :, round(frame/2)), LV_J, voxelPara, mask, Empty, rotate); %计算体积
        V_res = [V_res V];
        PC = calcPC(s_windData(1:480, :, round(frame/2)), LV_J, rotate, 0);
        MAP = [MAP BOX.map];
        VAL = [VAL BOX.value];
        drawnow
        ptr = ptr + 1;
    end
end

figure(8);
clf(figure(8))
plot(V_res)
title(sprintf('重复量方测算精度：%.4f m^3 [%.2f%%]\t|\t均值为: %.4f', std(V_res), std(V_res)/(4.2*2.2*2.2)*100, mean(V_res)), 'fontSize', 16)
xlabel('Loop', 'fontSize', 16)
ylabel('Volumn', 'fontSize', 16)

row = 293;
col = 410;
line1 = tmpDIS(row, col, :);
line1 = line1(:);
line2 = stdTrace((row-1)*640+col,:);
line2 = line2(:);
figure(6)
clf(figure(6))
[AX, HX] = plotyy(1:length(line1),line1,1:length(line2),line2);
xlabel('时序t', 'fontSize', 16)
ylabel(AX(1), '深度变化趋势', 'fontSize', 16)
ylabel(AX(2), '短时精度变化趋势', 'fontSize', 16)
%% showVoxelData
for i = 1:length(V_res)
    tmpMap = MAP(:, [1:size(MAP,2)/length(V_res)]+size(MAP,2)/length(V_res)*(i-1));
    tmpVal = VAL(:, [1:size(MAP,2)/length(V_res)]+size(MAP,2)/length(V_res)*(i-1));
    figure(9)
    subplot(121)
    imagesc(tmpMap)
    axis image
    colormap jet
    subplot(122) 
    imagesc(tmpVal)
    axis image
    colormap jet
    drawnow
end