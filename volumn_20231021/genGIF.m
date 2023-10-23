name = inputdlg('输入动图命名');
V = [];
for f = 1:6
    load(['p',num2str(f),'.mat'])
    V = [V V_res];
    
    figure(2)
    clf(figure(2))
    subplot(221)
    imagesc(tmpD)
    title('深度')
    axis image
    colormap jet
    set(gca, 'CLim', [0 4500])
    axis off
    title(sprintf('深度|体积:%.2f m^3 | 占据率:%.2f %%', V_res, V_res/(4.2*2.3*2.3)*100))
    
    subplot(222)
    imagesc(tmpA)
    title('幅度')
    axis image
    colormap jet
    set(gca, 'CLim', [0 500])
    axis off
    
    subplot(223)
    plot(V, 'o-')
    box on
    grid on
    title(sprintf('体积:%.2f m^3 | 占据率:%.2f %%', V_res, V_res/(4.2*2.3*2.3)*100));
    drawnow
    
    fr = getframe(figure(2));
    im = frame2im(fr);
    [A, map] = rgb2ind(im, 256);
    if f == 1
        imwrite(A, map, [name{1}, '.gif'], 'LOOPCOUNT', Inf, 'DelayTime', 0.5);
    elseif f < 6
        imwrite(A, map, [name{1}, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
    else
        imwrite(A, map, [name{1}, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 5);
    end   
end


name = inputdlg('输入动图命名');
for f = 1:6
    load(['p',num2str(f),'.mat'])
    index = find(PC.z < 500);
    X = PC.x;
    Y = PC.y;
    Z = PC.z;
    X(index) = NaN;
    Y(index) = NaN;
    Z(index) = NaN;
    figure(5);
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
    set(gca, 'CameraViewAngle', 40)
    campos([0 -5 -4000])
    % camtarget([0 0 200])
    box on
    axis off
    drawnow
    
    fr = getframe(figure(5));
    im = frame2im(fr);
    [A, map] = rgb2ind(im, 256);
    if f == 1
        imwrite(A, map, [name{1}, '.gif'], 'LOOPCOUNT', Inf, 'DelayTime', 0.5);
    elseif f < 6
        imwrite(A, map, [name{1}, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
    else
        imwrite(A, map, [name{1}, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 5);
    end   
end