%% 根据镜头内参进行光线仿真
% 大FOV—焦距f = 1.66 mm dx = 0.0058mm dy = 0.0054mm
% 小FOV—焦距f = 2.60 mm dx = 0.0058mm dy = 0.0054mm
% VFOV = atand((dx*640/2)/1.66)*2
% HFOV = atand((dy*480/2)/1.66)*2
%% 仿真相机内参(大FOV)
f = 1.66;
cx = 312; % 默认主点在传感器像素中心
cy = 253;
fx = 241;
fy = 279;
dx = f/fx; % 行像素尺寸
dy = f/fy; % 列像素尺寸
%% 仿真相机内参(大FOV)
% f = 2.60;
% cx = 313;
% cy = 259;
% fx = 450;
% fy = 480;
% dx = f/fx; % 行像素尺寸
% dy = f/fy; % 列像素尺寸
%% binning版本内参
bin = 4; %降采样提高计算实际
width = 640/bin;
height = 480/bin;
fx = fx / bin;
fy = fy / bin;
cx = round(cx/bin);
cy = round(cy/bin);
dx = dx*bin;
dy = dy*bin;

VFOV = atand((dx*width/2)/f)*2;
HFOV = atand((dy*height/2)/f)*2;
normZ = 1000;
ray.origin = [0; 0; 0]';

oX = zeros(480/bin, 640/bin);
oY = zeros(480/bin, 640/bin);
oZ = zeros(480/bin, 640/bin);
i = 1;
R = zeros(480/bin, 640/bin);
for ii = 1:bin:480
    j = 1;
    for jj = 1:bin:640
        xx = (j - cx)*dx;
        yy = (i - cy)*dy;
        oX(i,j) = (xx * normZ)/f;
        oY(i,j) = (yy * normZ)/f;
        oZ(i,j) = normZ+ray.origin(3);
        R(i,j) = norm([oX(i,j) oY(i,j) oZ(i,j)], 2);
        j = j + 1;
    end
    i = i + 1;
end
bendComp = bendingCorr(R, cx, cy, fx, fy);
Depth = R.*bendComp;
u = repmat([1:1:size(oX,2)], size(oX,1), 1);
v = repmat([1:1:size(oX,1)]', 1, size(oX,2));
X = (u-cx)./fx .* Depth;
Y = (v-cy)./fy .* Depth;
Z = Depth;

%% 光迹可视化
plane = [normZ -1000 -750;
         normZ 1000 -750;
         normZ 1000 750;
         normZ -1000 750;];
figure(3)
clf(figure(3))
for r = 1:4:size(X,1)
    for c = 1:8:size(X,2)
        plot3([0 Z(r,c)], [0 X(r,c)], [0 Y(r,c)], 'r-')
        hold on
    end
end
hold on
patch('Faces',[1 2 3 4],'Vertices',plane, 'FaceColor', [0.9 0.9 0.9],'FaceAlpha',1)
hold on
text(-100, 0, 0, 'D3', 'color', 'w')
set(gca, 'XColor', 'w')
set(gca, 'YColor', 'w')
set(gca, 'ZColor', 'w')
set(gca, 'Color', [0.3 0.3 0.3])
set(gcf, 'Color', [0.3 0.3 0.3])
xlabel('X', 'color', 'w');
ylabel('Y', 'color', 'w');
zlabel('Z', 'color', 'w');
axis image
colormap hsv
grid on
box on
%% 出光点云
figure(5);
clf(figure(5))
pcshow([X(:) Y(:) Z(:)] , Z(:), 'markerSize', 5)
hold on
plot3(ray.origin(1), ray.origin(2), ray.origin(3), 'r*', 'markerSize', 15)
hold on
text(ray.origin(1)-0.1, ray.origin(2)+0.1, ray.origin(3)+0.1, 'LiDAR-D3', 'color', 'r')
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
box on
%% D3倾斜角
rotateMatrix = calcRT(0, 0, 0); % 相机旋转角---模拟相机摆放不平稳
edge = [oX(:) oY(:) oZ(:)];
edge = rotateMatrix*edge';
edge = edge';
rX = edge(:,1);
rY = edge(:,2);
rZ = edge(:,3);
rX = reshape(rX, 480/bin, 640/bin);
rY = reshape(rY, 480/bin, 640/bin);
rZ = reshape(rZ, 480/bin, 640/bin);
figure(5);
hold on
pcshow([rX(:) rY(:) rZ(:)] ,'w', 'markerSize', 5)
hold on
plot3(ray.origin(1), ray.origin(2), ray.origin(3), 'r*', 'markerSize', 15)
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
box on
%% 定义标靶(无穷大)
dis = [0.4 1:0.5:4.5]*1000;
D = {length(dis)};
% figure(5);
% clf(figure(5))
for i = 1:length(dis)
    N_plane = [0 0 -1];
    objDIS = dis(i);
    plane = [-1000 -750 0;
        1000 -750 0;
        1000 750 0;
        -1000 750 0;];
    rotateMatrix = calcRT(0, 0, -0); % 标靶旋转角
    plane = rotateMatrix*plane';
    plane = plane';
    plane(:,3) = plane(:,3) + objDIS;
    
    N_plane = rotateMatrix*N_plane';
    N_plane = N_plane';
    
    crossPoint = zeros(size(rX,1)*size(rX,2),3);
    Depth = zeros(size(rX,1), size(rX,2));
    for r = 1:size(rX,1)
        for c = 1:size(rX, 2)
            d = dot(N_plane, [0 0 objDIS]-ray.origin)/dot(N_plane, [rX(r,c),rY(r,c),rZ(r,c)]-ray.origin);
            tmpCross = ray.origin + d * ([rX(r,c),rY(r,c),rZ(r,c)] - ray.origin);
            
            if onPlane(tmpCross, plane(1,:), plane(2,:), plane(3,:))
                flag1 = (insideTRI(plane(1,:), plane(2,:), plane(3,:), tmpCross)&...
                    insideTRI(plane(2,:), plane(3,:), plane(1,:), tmpCross)&...
                    insideTRI(plane(3,:), plane(1,:), plane(2,:), tmpCross));
                flag2 = (insideTRI(plane(3,:), plane(4,:), plane(1,:), tmpCross)&...
                    insideTRI(plane(4,:), plane(1,:), plane(3,:), tmpCross)&...
                    insideTRI(plane(1,:), plane(3,:), plane(4,:), tmpCross));
                if flag1 || flag2
                    crossPoint((r-1)*size(rX,2)+c, :) = tmpCross;
                    Depth(r,c) = norm(tmpCross, 2);
                end
            end
        end
    end
    D{i} = Depth;
    pcshow([crossPoint(:, 1) crossPoint(:, 2) crossPoint(:, 3)] , crossPoint(:, 3), 'markerSize', 5)
    hold on
    plot3(ray.origin(1), ray.origin(2), ray.origin(3), 'r*', 'markerSize', 15)
    hold on
    patch('Faces',[1 2 3 4],'Vertices',plane, 'FaceColor', [0.9 0.9 0.9],'FaceAlpha',1)
    set(gca, 'XColor', 'w')
    set(gca, 'YColor', 'w')
    set(gca, 'ZColor', 'w')
    set(gca, 'Color', [0.3 0.3 0.3])
    set(gcf, 'Color', [0.3 0.3 0.3])
    xlabel('X', 'color', 'w');
    ylabel('Y', 'color', 'w');
    zlabel('Z', 'color', 'w');
    set(gca, 'clim', [0 5000])
    set(gca, 'projection', 'perspective')
    colormap hsv
    grid on
    box on
    view(0, -60)
    hold on
    drawnow()
end
%% 采集标靶深度图展示
name = inputdlg('输入动图命名');
for i = 1:length(D)
    %% 深度数据
    tmpD = D{i};
    Depth = tmpD.* bendComp;
    figure(2)
    clf(figure(2))
    imagesc(Depth);
    axis image
    colormap jet
    set(gca, 'CLim', [0 5000])
    axis off
    
    u = repmat([1:1:size(Depth,2)], size(Depth,1), 1);
    v = repmat([1:1:size(Depth,1)]', 1, size(Depth,2));
    X = (u-cx)./fx .* Depth;
    Y = (v-cy)./fy .* Depth;
    Z = Depth;
    if i == 1
        figure(6)
        clf(figure(6))    
        pcshow([Z(:) X(:) Y(:)] , Z(:), 'markerSize', 10)
        hold on
        plot3([0 4500], [0 0], [0 0], 'w-')
        hold on
        text(ray.origin(1), ray.origin(2), ray.origin(3), 'D3', 'color', 'w')
        set(gca, 'XColor', 'w')
        set(gca, 'YColor', 'w')
        set(gca, 'ZColor', 'w')
        set(gca, 'Color', [0.1 0.1 0.1])
        set(gcf, 'Color', [0.1 0.1 0.1])
        set(gca, 'CLim', [0 7500])
        set(gca, 'Projection', 'perspective');
        xlabel('X', 'color', 'w');
        ylabel('Y', 'color', 'w');
        zlabel('Z', 'color', 'w');
        colormap hsv
        grid on
        box on
        view(-80, 20)
        xlim([0 4500])
        ylim([-1000 1000])
        zlim([-750 750])
    else
        figure(6)
        hold on
        pcshow([Z(:) X(:) Y(:)] , Z(:), 'markerSize', 10)
        hold on
        plot3([0 4500], [0 0], [0 0], 'w-')
        hold on
        text(ray.origin(1), ray.origin(2), ray.origin(3), 'D3', 'color', 'w')
        set(gca, 'XColor', 'w')
        set(gca, 'YColor', 'w')
        set(gca, 'ZColor', 'w')
        set(gca, 'Color', [0.1 0.1 0.1])
        set(gcf, 'Color', [0.1 0.1 0.1])
        set(gca, 'CLim', [0 7500])
        set(gca, 'Projection', 'perspective');
        xlabel('X', 'color', 'w');
        ylabel('Y', 'color', 'w');
        zlabel('Z', 'color', 'w');
        colormap hsv
        grid on
        box on
        view(-80, 20)
        xlim([0 4500])
        ylim([-1000 1000])
        zlim([-750 750])
    end
    drawnow()
    
    frame = getframe(figure(6));
    im = frame2im(frame);
    [A, map] = rgb2ind(im, 256);
    if i == 1
        imwrite(A, map, [name{1},'_3D.gif'], 'gif', 'LoopCount', Inf, 'DelayTime', 0.4)
    elseif i < length(D)
        imwrite(A, map, [name{1},'_3D.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 0.4)
    else
        imwrite(A, map, [name{1},'_3D.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 2)
    end
    
    frame = getframe(figure(2));
    im = frame2im(frame);
    [A, map] = rgb2ind(im, 256);
    if i == 1
        imwrite(A, map, [name{1}, '_2D.gif'], 'gif', 'LoopCount', Inf, 'DelayTime', 0.4)
    elseif i < length(D)
        imwrite(A, map, [name{1}, '_2D.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 0.4)
    else
        imwrite(A, map, [name{1}, '_2D.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 2)
    end
    
    pause(0.1)
end
%% 标靶中心像素区域深度
name = inputdlg('输入动图命名');
for i = 1:length(D)
    %% 深度数据
    tmpD = D{i}; 
    Depth = tmpD.*bendComp;
    
    rowIDX = [size(Depth,1)/2-4:size(Depth,1)/2+5];
    colIDX = [size(Depth,2)/2-4:size(Depth,2)/2+5];
%     rowIDX = cy-4:cy+5;
%     colIDX = cx-4:cx+5;
    centData = Depth(rowIDX, colIDX);
    centData(centData == 0) = NaN;
    fprintf('中心区域深度均值：%.4f mm\n', nanmean(centData(:)));
    u = repmat([1:1:size(Depth,2)], size(Depth,1), 1);
    v = repmat([1:1:size(Depth,1)]', 1, size(Depth,2));
    X = (u-cx)./fx .* Depth;
    Y = (v-cy)./fy .* Depth;
    Z = Depth;
    
    centX = X(rowIDX, colIDX);
    centY = Y(rowIDX, colIDX);
    centZ = Z(rowIDX, colIDX);
    
    if i == 1
        figure(6);
        clf(figure(6))
        pcshow([centX(:) centY(:) centZ(:)], centZ(:), 'markerSize', 50)
        set(gca, 'XColor', 'w')
        set(gca, 'YColor', 'w')
        set(gca, 'ZColor', 'w')
        set(gca, 'Color', [0.1 0.1 0.1])
        set(gcf, 'Color', [0.1 0.1 0.1])
        set(gca, 'CLim', [0 5000])
        xlabel('X', 'color', 'w');
        ylabel('Y', 'color', 'w');
        zlabel('Z', 'color', 'w');
        colormap hsv
        grid on
        box on
    else
         figure(6);
         hold on
        pcshow([centX(:) centY(:) centZ(:)], centZ(:), 'markerSize', 50)
        set(gca, 'XColor', 'w')
        set(gca, 'YColor', 'w')
        set(gca, 'ZColor', 'w')
        set(gca, 'Color', [0.1 0.1 0.1])
        set(gcf, 'Color', [0.1 0.1 0.1])
        set(gca, 'CLim', [0 5000])
        xlabel('X', 'color', 'w');
        ylabel('Y', 'color', 'w');
        zlabel('Z', 'color', 'w');
        colormap hsv
        grid on
        box on
    end
    view([0 0 -1])
    frame = getframe(figure(6));
    im = frame2im(frame);
    [A, map] = rgb2ind(im, 256);
    if i == 1
        imwrite(A, map, [name{1},'.gif'], 'gif', 'LoopCount', Inf, 'DelayTime', 0.4)
    elseif i < length(D)
        imwrite(A, map, [name{1},'.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 0.4)
    else
        imwrite(A, map, [name{1},'.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 2)
    end
    drawnow()  
    pause(0.1)
end
