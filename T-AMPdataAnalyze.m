currentDIR = pwd;
filePath = uigetdir('请选择文件所在路径');
cd(filePath);
files = dir('*.csv');
DATA.amp = [];
DATA.temp = [];
DATA.date = [];
flag = 1;
for f = 1:length(files)
    splName = strsplit(files(f).name, '_');
    if ismember('amplitude', splName) 
        tmpAMP = csvread(files(f).name);
        if flag == 1
            figure(1)
            clf(figure(1))
            imagesc(tmpAMP)
            axis image
            colormap jet
            pause
            roi = inputdlg('请选择ROI区域[x y width height]');
            roiPara = strsplit(roi{1}(2:end-1), ' ');
            roiPara = str2double(roiPara);
            roiIM = tmpAMP(roiPara(1):roiPara(1)+roiPara(3), roiPara(2):roiPara(2)+roiPara(4));
        else
            roiIM = tmpAMP(roiPara(1):roiPara(1)+roiPara(3), roiPara(2):roiPara(2)+roiPara(4));
        end
        DATA.amp(flag) = mean(roiIM(:));
        DATA.temp(flag) = tmpAMP(481, 1);
        DATA.date{flag} = files(f).date;
        flag = flag + 1;
    end
end
cd(currentDIR)

time = [];
for t = 1:length(DATA.date)
    time(t) = datenum(DATA.date{t});
end
[val, idx] = sort(time);
DATA.amp = round(DATA.amp(idx));
DATA.temp = DATA.temp(idx);
tail = mod(length(time), 50);
showIDX = 1:length(time)-tail;

figure(1)
clf(figure(1))
[AX, HX] = plotyy(showIDX, DATA.amp(showIDX), showIDX, DATA.temp(showIDX));
grid on
ylabel(AX(1), '幅度 [LSB]', 'FontSize', 16)
ylabel(AX(2), '温度 [^oC]', 'FontSize', 16)
title(sprintf('温度变化区间[%d-%d]^oC\t幅度变化区间[%d-%d]LSB', min(DATA.temp), max(DATA.temp), min(DATA.amp), max(DATA.amp)), 'FontSize', 18);
xlabel('时间', 'FontSize', 16)
set(gca, 'XTick', 0:50:length(time), 'XTickLabel', [DATA.date(1) DATA.date(50:50:length(time))], 'XTickLabelRotation', 45)
set(gca, 'Position', [0.1 0.35 0.8 0.5])