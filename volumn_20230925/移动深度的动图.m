name = inputdlg('输入动图命名');
for f = 1:3
    fid = fopen(['mv_', num2str(f-1),'boxD.bin'], 'r');
    box = fread(fid, 480*640, 'uint16');
    fclose(fid);
    box = reshape(box, 640, 480)';
    outputXYZ.box = calcPC(box, LV_J, -41);
    axis off
    
    fr = getframe(figure(5));
    im = frame2im(fr);
    [A, map] = rgb2ind(im, 256);
    if f == 1
        imwrite(A, map, [name{1}, '.gif'], 'LOOPCOUNT', Inf, 'DelayTime', 0.4);
    elseif f < 3
        imwrite(A, map, [name{1}, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 0.4);
    else
        imwrite(A, map, [name{1}, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 1);
    end
end

name = inputdlg('输入动图命名');
V_result = [];
for b = 1:3
    fid = fopen(['mv_', num2str(b-1),'boxD.bin'], 'r');
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
    xlim([1 3])
    grid on
    xlabel('往前推移0-2倍的箱子深度', 'FontSize', 16)
    ylabel('体积 [m^3]', 'FontSize', 16)
    title('箱子个数—体积变化曲线', 'FontSize', 16);
    drawnow
    
    fr = getframe(figure(7));
    im = frame2im(fr);
    [A, map] = rgb2ind(im, 256);
    if b == 1
        imwrite(A, map, [name{1}, '.gif'], 'LOOPCOUNT', Inf, 'DelayTime', 0.5);
    elseif b < 3
        imwrite(A, map, [name{1}, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
    else
        imwrite(A, map, [name{1}, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 5);
    end   
end

V_real = 0.3*6;
V_real = V_real .*(1:1:3);
V_ideal = 0.9*0.6*0.6*6;
V_ideal = V_ideal .*(1:1:3);
figure(8)
clf(figure(8))
plot(V_result, 'o-', 'markerSize', 10, 'lineWidth', 1.5)'
hold on
plot(V_ideal , 'g--', 'lineWidth', 0.5)
hold on
plot(V_real , 'r--', 'lineWidth', 1.0)
for i = 1:3
    hold on
    text(i-0.3, V_real(i)-0.1, sprintf('error：%.2f %%', abs((V_result(i)-V_real(i))/(3.9*2*2))*100), 'color', 'r')
end
grid on
legend('体素计算结果', '纸箱规格体积', '实际体积') %(由于箱子摆放存在间隙)
xlabel('往前推移0-2倍的箱子深度', 'FontSize', 16)
ylabel('体积 [m^3]', 'FontSize', 16)
title('【LW】推移距离—体积变化曲线', 'FontSize', 16);

