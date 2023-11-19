%% 定义光线路径
VFOV = 80;
HFOV = 102;
normZ = 100;
detaV = VFOV/(480-1);
detaH = HFOV/(640-1);
vDegree = -VFOV/2:detaV:VFOV/2;
rayY = tand(vDegree)*normZ;
hDegree = -HFOV/2:detaH:HFOV/2;
rayX = tand(hDegree)*normZ;
ray.origin = [0; 0; 0]';
X = repmat(rayX, length(rayY),1);
Y = repmat(rayY', 1, length(rayX));
width = 1;
rX = zeros(480/width, 640/width);
rY = zeros(480/width, 640/width);
rZ = zeros(480/width, 640/width);
i = 1;
R = zeros(480/width, 640/width);
for ii = 1:width:480
    j = 1;
    for jj = 1:width:640
        rX(i,j) = X(ii,jj);
        rY(i,j) = Y(ii,jj);
        rZ(i,j) = normZ+ray.origin(3);
        R(i,j) = norm([rX(i,j) rY(i,j) rZ(i,j)], 2);
        j = j + 1;
    end
    i = i + 1;
end
cx = size(rX,2)/2;
cy = size(rX,1)/2;
fx = 267;
fy = 267;
bendComp = bendingCorr(R, cx, cy, fx, fy);
u = repmat([1:1:size(Depth,2)], size(Depth,1), 1);
v = repmat([1:1:size(Depth,1)]', 1, size(Depth,2));
X = (u-cx)./fx .* Depth;
Y = (v-cy)./fy .* Depth;
Z = Depth;

figure(5);
clf(figure(5))
pcshow([X(:) Y(:) Z(:)] , Z(:), 'markerSize', 5)
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
%% D3倾斜角
rotateMatrix = calcRT(0, 0, 2); % 相机旋转角
edge = [rX(:) rY(:) rZ(:)];
edge = rotateMatrix*edge';
edge = edge';
rX = edge(:,1);
rY = edge(:,2);
rZ = edge(:,3);
rX = reshape(rX, 480/width, 640/width);
rY = reshape(rY, 480/width, 640/width);
rZ = reshape(rZ, 480/width, 640/width);
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
figure(5);
clf(figure(5))
for i = 1:length(dis)
    N_plane = [0 0 -1];
    objDIS = dis(i);
    plane = [-1000 -900 objDIS;
        1000 -900 objDIS;
        1000 900 objDIS;
        -1000 900 objDIS;];
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
                    Depth(r,c) = round(tmpCross(3));
                end
            end
        end
    end
    D{i} = Depth;
    pcshow([crossPoint(:, 1) crossPoint(:, 2) crossPoint(:, 3)] , crossPoint(:, 3), 'markerSize', 5)
    hold on
    plot3(ray.origin(1), ray.origin(2), ray.origin(3), 'r*', 'markerSize', 15)
%     hold on
%     patch('Faces',[1 2 3 4],'Vertices',plane, 'FaceColor', [0.9 0.9 0.9],'FaceAlpha',1)
    set(gca, 'XColor', 'w')
    set(gca, 'YColor', 'w')
    set(gca, 'ZColor', 'w')
    set(gca, 'Color', [0.3 0.3 0.3])
    set(gcf, 'Color', [0.3 0.3 0.3])
    xlabel('X', 'color', 'w');
    ylabel('Y', 'color', 'w');
    zlabel('Z', 'color', 'w');
    set(gca, 'clim', [0 4500])
    set(gca, 'projection', 'perspective')
    colormap hsv
    grid on
    box on
    view(0, -60)
    hold on
    drawnow()
end

%% 采集标靶深度图
for i = 1:length(D)
    figure(2)
    clf(figure(2))
    tmpD = D{i};
    imagesc(tmpD);
    axis image
    colormap jet
    set(gca, 'CLim', [0 5000])
    
    drawnow()  
    pause(0.1)
end
