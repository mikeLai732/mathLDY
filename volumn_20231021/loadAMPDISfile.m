function [tmpAMP, tmpDIS] = loadAMPDISfile
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

for f = 1:size(tmpDIS, 3)
    figure(2)
    clf(figure(2))
    imagesc(tmpDIS(1:480,:,f))
    axis image
    colormap jet
    set(gca, 'CLim', [0 4500])
    axis off
    drawnow
end
end