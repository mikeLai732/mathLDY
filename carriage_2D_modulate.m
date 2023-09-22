CA = []; % total Cover Area
BA = []; % Blind Area
rot = []; % rotate Degree
count = 1;
ffff;
for ii = 0
    TRUCK = [0 0 4.2 2];
    VFOV = 82;
    startposition = [0.09  0.09];
    theta1 = 0+ii;
    theta2 = theta1+VFOV;
    theta_center = (theta1+theta2)/2;
    
    rot = [rot theta_center];
    
    x = [startposition(1):0.1:4.2];
    k1 = tand(theta1);
    k2 = tand(theta2);
    k3 = tand(theta_center);
    b1 = startposition(2) - k1 * startposition(1);
    b2 = startposition(2) - k2 * startposition(1);
    b3 = startposition(2) - k3 * startposition(1);
    
    %% 计算和四边的交点
    warning off;
    S1 = solve(['y =', num2str(k1),'*x+', num2str(b1)], 'x = 4.2','x', 'y');
    S2 = solve(['y =', num2str(k1),'*x+', num2str(b1)], 'y = 0','x', 'y');
    %     S3 = solve(['y =', num2str(k1),'*x+', num2str(b1)], 'y = 0','x', 'y');
    %     S4 = solve(['y =', num2str(k1),'*x+', num2str(b1)], 'y = 2','x', 'y');
    S3 = solve(['y =', num2str(k2),'*x+', num2str(b2)], 'x = 0','x', 'y');
    S4 = solve(['y =', num2str(k2),'*x+', num2str(b2)], 'y = 2','x', 'y');
    %     S7 = solve(['y =', num2str(k2),'*x+', num2str(b2)], 'y = 0','x', 'y');
    %     S8 = solve(['y =', num2str(k2),'*x+', num2str(b2)], 'y = 2','x', 'y');
    %% 绘制结果
    blind = 0;
    figure(1)
    clf(figure(1))
    rectangle('position', TRUCK, 'edgeColor', 'r', 'lineWidth', 2);
    hold on
    plot(x, k1*(x) + b1, 'b-', 'lineWidth', 2);
    hold on
    plot(x, k2*(x) + b2, 'b-', 'lineWidth', 2);
    hold on
    plot(x, k3*(x) + b3, 'b--', 'lineWidth', 1);
    hold on
    plot(startposition(1), startposition(2), 'r<', 'markerSize', 10, 'lineWidth', 2);
    hold on
    plot(startposition(1), startposition(2), 'r>', 'markerSize', 10, 'lineWidth', 2);
    xlim([-2 8])
    ylim([-2 4])

    for i = 1:4
        eval(['tmpX = double(S', num2str(i),'.x);'])
        eval(['tmpY = double(S', num2str(i),'.y);'])
        if ~isempty(tmpX) && ~isempty(tmpY)
            if tmpX >= 0 & tmpY >= 0 & tmpX <= 4.2 & tmpY <= 2 && min(((startposition(:,1) - tmpX).^2 -(startposition(:,2) - tmpY).^2).^2) ~= 0% & tmpX ~= startposition(1) & tmpY ~= startposition(2)
                if tmpY == 2
                    blind = tmpX;
                end
                startposition = [startposition; tmpX, tmpY];
                hold on
                plot(tmpX, tmpY, 'g*', 'markerSize', 10, 'lineWidth', 1.5);
            end
        end
    end
    startposition = [startposition; 4.2, 2];
    %% 角点坐标排序
    polygonPara = [];
    centerposition = [2.1,1];
    direction = startposition - repmat(centerposition, size(startposition,1), 1);
    direction = (atan2(direction(:,2),direction(:,1))+ pi)./pi*180;
    [~, sortR] = sort(direction);
    if length(direction) ==  5
        startposition = startposition(sortR, :);
    else
        flags =zeros(4,1);
        for dd = 1:length(direction)
            if direction(dd) > 0 && direction(dd) <= 90
                flags(1) = 1;
            elseif direction(dd) > 90 && direction(dd) <= 180 && startposition(dd, 2) > 0
                flags(2) = 1;
            elseif direction(dd) > 180 && direction(dd) <= 270
                flags(3) = 1;
            else
                flags(4) = 1;
            end
        end
        idx = find(flags == 0);
        if idx == 2
            startposition = [startposition; 4.2, 0];
        end
        if idx == 3
            startposition = [startposition; 4.2 2];
        end
        if idx == 4
            startposition = [startposition; 0 2];
        end
        direction = startposition - repmat(centerposition, size(startposition,1), 1);
        direction = (atan2(direction(:,2),direction(:,1))+ pi)./pi*180;
        [~, sortR] = sort(direction);
        startposition = startposition(sortR, :);
    end
    set(gca, 'YDir', 'reverse')
    hold on
    fill(startposition(:,1), startposition(:,2), 'r', 'faceAlpha', 0.2);
    coverArea = polyarea(startposition(:,1), startposition(:,2));
    title(['盲区:', num2str(blind), ' [m] | 光轴偏转角:', num2str(theta_center), ' [^o] | 面积:', num2str(coverArea), ' [m^2] | 面积占比：', num2str(coverArea/(4.2*2)*100),'%'], 'fontSize', 16)
    xlabel('深度方向 [m]', 'fontSize', 16)
    ylabel('垂直方向 [m]', 'fontSize', 16)
    xlim([0 4.2])
    ylim([0 2.0])
    % axis image
    drawnow()
    name = '允许偏转角';
    fr = getframe(figure(1));
    im = frame2im(fr);
    [A, map] = rgb2ind(im, 256);
    if count == 1
        imwrite(A, map, [name, '.gif'], 'LOOPCOUNT', Inf, 'DelayTime', 0.4);
    elseif count < 9
        imwrite(A, map, [name, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 0.4);
    else
        imwrite(A, map, [name, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 5);
    end   
    count = count + 1;
    
    CA = [CA coverArea]; % total Cover Area
    BA = [BA blind]; % Blind Area
end

figure(2)
clf(figure(2))
[AX, HX1, HX2] = plotyy(rot, CA./(4.2*2)*100, rot, BA);
hold on
xlabel('光轴距上表面偏转角度 [^o]', 'fontSize', 18);
ylabel(AX(1), 'Y-Z方向覆盖面积占比 [%]', 'fontSize', 18); 
ylabel(AX(2), '盲区 [m]', 'fontSize', 18);
title('器件垂直方向的覆盖面积与光轴偏转角度的关系', 'fontSize', 20); 
grid on
% set(AX(1), 'YTick', min(CA):0.2:max(CA))
set(HX1, 'lineStyle', '-', 'Marker', 'o', 'markerSize', 10, 'lineWidth', 2)
% set(AX(2), 'YTick', min(BA):0.05:max(BA))
set(HX2, 'lineStyle', '-', 'Marker', 'o', 'markerSize', 10, 'lineWidth', 2)

%% 最佳角度
TRUCK = [0 0 4.2 2];
VFOV = 82;
startposition = [0.0  0.0];
theta_center = 41;
theta1 = theta_center - VFOV/2;
theta2 = theta_center + VFOV/2;
rot = [rot theta_center];
x = [startposition(1):0.1:4.2];
k1 = tand(theta1);
k2 = tand(theta2);
k3 = tand(theta_center);
b1 = startposition(2) - k1 * startposition(1);
b2 = startposition(2) - k2 * startposition(1);
b3 = startposition(2) - k3 * startposition(1);
warning off;
S1 = solve(['y =', num2str(k1),'*x+', num2str(b1)], 'x = 4.2','x', 'y');
S2 = solve(['y =', num2str(k1),'*x+', num2str(b1)], 'y = 0','x', 'y');
S3 = solve(['y =', num2str(k2),'*x+', num2str(b2)], 'x = 0','x', 'y');
S4 = solve(['y =', num2str(k2),'*x+', num2str(b2)], 'y = 2','x', 'y');

blind = 0;
figure(1)
clf(figure(1))
rectangle('position', TRUCK, 'edgeColor', 'r', 'lineWidth', 2);
hold on
plot(x, k1*(x) + b1, 'b-', 'lineWidth', 2);
hold on
plot(x, k2*(x) + b2, 'b-', 'lineWidth', 2);
hold on
plot(x, k3*(x) + b3, 'b--', 'lineWidth', 1);
hold on
plot(startposition(1), startposition(2), 'r<', 'markerSize', 10, 'lineWidth', 2);
hold on
plot(startposition(1), startposition(2), 'r>', 'markerSize', 10, 'lineWidth', 2);
xlim([-2 8])
ylim([-2 4])

for i = 1:4
    eval(['tmpX = double(S', num2str(i),'.x);'])
    eval(['tmpY = double(S', num2str(i),'.y);'])
    if ~isempty(tmpX) && ~isempty(tmpY)
        if tmpX >= 0 & tmpY >= 0 & tmpX <= 4.2 & tmpY <= 2 && min(((startposition(:,1) - tmpX).^2 -(startposition(:,2) - tmpY).^2).^2) ~= 0% & tmpX ~= startposition(1) & tmpY ~= startposition(2)
            if tmpY == 2
                blind = tmpX;
            end
            startposition = [startposition; tmpX, tmpY];
            hold on
            plot(tmpX, tmpY, 'g*', 'markerSize', 10, 'lineWidth', 1.5);
        end
    end
end
startposition = [startposition; 4.2, 2];
%% 角点坐标排序
polygonPara = [];
centerposition = [2.1,1];
direction = startposition - repmat(centerposition, size(startposition,1), 1);
direction = (atan2(direction(:,2),direction(:,1))+ pi)./pi*180;
[~, sortR] = sort(direction);
if length(direction) ==  5
    startposition = startposition(sortR, :);
else
    flags =zeros(4,1);
    for dd = 1:length(direction)
        if direction(dd) > 0 && direction(dd) <= 90
            flags(1) = 1;
        elseif direction(dd) > 90 && direction(dd) <= 180 && startposition(dd, 2) > 0
            flags(2) = 1;
        elseif direction(dd) > 180 && direction(dd) <= 270
            flags(3) = 1;
        else
            flags(4) = 1;
        end
    end
    idx = find(flags == 0);
    if idx == 2
        startposition = [startposition; 4.2, 0];
    end
    if idx == 3
        startposition = [startposition; 4.2 2];
    end
    if idx == 4
        startposition = [startposition; 0 2];
    end
    direction = startposition - repmat(centerposition, size(startposition,1), 1);
    direction = (atan2(direction(:,2),direction(:,1))+ pi)./pi*180;
    [~, sortR] = sort(direction);
    startposition = startposition(sortR, :);
end
set(gca, 'YDir', 'reverse')
hold on
fill(startposition(:,1), startposition(:,2), 'r', 'faceAlpha', 0.2);
coverArea = polyarea(startposition(:,1), startposition(:,2));
title(['盲区:', num2str(blind), ' [m] | 光轴偏转角:', num2str(theta_center), ' [^o] | 面积:', num2str(coverArea), ' [m^2]'], 'fontSize', 16)
xlim([0 4.2])
ylim([0 2.0])
% axis image
drawnow()

%% 水平最佳角度
CA = [];
BA = [];
rot = [];
count = 1;
for ii = -5:5
    TRUCK = [0 0 4.2 2];
    HFOV = 104;
    startposition = [0.0  1.0];
    theta_center = 90+ii;
    theta1 = theta_center - HFOV/2;
    theta2 = theta_center + HFOV/2;
    rot = [rot theta_center];
    x = [startposition(1):0.1:4.2];
    k1 = tand(theta1);
    k2 = tand(theta2);
    k3 = tand(theta_center);
    b1 = startposition(2) - k1 * startposition(1);
    b2 = startposition(2) - k2 * startposition(1);
    b3 = startposition(2) - k3 * startposition(1);
    warning off;
    S1 = solve(['y =', num2str(k1),'*x+', num2str(b1)], 'y = 2','x', 'y');
    S2 = solve(['y =', num2str(k2),'*x+', num2str(b2)], 'y = 0','x', 'y');
    
    blind = 0;
    figure(1)
    clf(figure(1))
    rectangle('position', TRUCK, 'edgeColor', 'r', 'lineWidth', 2);
    hold on
    plot(x, k1*(x) + b1, 'b-', 'lineWidth', 2);
    hold on
    plot(x, k2*(x) + b2, 'b-', 'lineWidth', 2);
    hold on
    plot([x(1) x(end)], [1 1], 'b--', 'lineWidth', 1);
    hold on
    plot(startposition(1), startposition(2), 'r<', 'markerSize', 10, 'lineWidth', 2);
    hold on
    plot(startposition(1), startposition(2), 'r>', 'markerSize', 10, 'lineWidth', 2);
    xlim([-2 8])
    ylim([-2 4])
    
    for i = 1:2
        eval(['tmpX = double(S', num2str(i),'.x);'])
        eval(['tmpY = double(S', num2str(i),'.y);'])
        if ~isempty(tmpX) && ~isempty(tmpY)
            if tmpX >= 0 & tmpY >= 0 & tmpX <= 4.2 & tmpY <= 2
                if tmpY == 2
                    blind = tmpX;
                end
                startposition = [startposition; tmpX, tmpY];
                hold on
                plot(tmpX, tmpY, 'g*', 'markerSize', 10, 'lineWidth', 1.5);
            end
        end
    end
    startposition = [startposition; 4.2, 2; 4.2 0];
    polygonPara = [];
    centerposition = [2.0, 1.0];
    direction = startposition - repmat(centerposition, size(startposition,1), 1);
    direction = (atan2(direction(:,2),direction(:,1))+ pi)./pi*180;
    [~, sortR] = sort(direction);
    startposition = startposition(sortR, :);
    set(gca, 'YDir', 'reverse')
    hold on
    fill(startposition(:,1), startposition(:,2), 'r', 'faceAlpha', 0.2);
    coverArea = polyarea(startposition(:,1), startposition(:,2));
    CA = [CA coverArea]; % total Cover Area
    BA = [BA blind]; % Blind Area

    xlabel('深度方向 [m]', 'fontSize', 16)
    ylabel('水平方向 [m]', 'fontSize', 16)
    title(['绕中轴偏转角:', num2str(ii), ' [^o] | 面积:', num2str(coverArea), ' [m^2]'], 'fontSize', 16)
    xlim([0 4.2])
    ylim([0 2.0])
    % axis image
    drawnow()
    
    name = '水平绕中轴偏转动图';
    fr = getframe(figure(1));
    im = frame2im(fr);
    [A, map] = rgb2ind(im, 256);
    if count == 1
        imwrite(A, map, [name, '.gif'], 'LOOPCOUNT', Inf, 'DelayTime', 0.4);
    elseif count < 11
        imwrite(A, map, [name, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 0.4);
    else
        imwrite(A, map, [name, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 5);
    end   
    count = count + 1;
end
figure(2)
clf(figure(2))
plot(rot-90, CA./(4.2*2), 'o-', 'markerSize', 10, 'lineWidth', 2)
xlabel('偏转角度 [^o]', 'fontSize', 16);
ylabel('X-Z方向覆盖面积 [m^2]', 'fontSize', 18); 
title('器件水平方向的覆盖面积与偏转角度的关系', 'fontSize', 20); 
grid on

