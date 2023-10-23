function [XYZ, xlim] = xPCLocate(inputXYZ, downSample) 
%以车厢的数值分布特征分割两壁及其他部分
%但是最方便的方法仍然是直接使用法向量进行区分
% downSample = 20;
X = zeros(length(inputXYZ.x)/downSample, 1);
Y = zeros(length(inputXYZ.x)/downSample, 1);
Z = zeros(length(inputXYZ.x)/downSample, 1);
count = 1;
for r = 1:downSample:length(inputXYZ.x)
    X(count) = inputXYZ.x(r);
    Y(count) = inputXYZ.y(r);
    Z(count) = inputXYZ.z(r);
    count = count + 1;
end
figure(5);
pcshow([X(:) Y(:) Z(:)] , Z(:), 'markerSize', 5)
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
set(gca, 'CLim', [0 7500])
box on
% 在X方向进行拉伸及排序
[sortX, ~] = sort(X(:));
% sortY = Y(ind);
% sortZ = Z(ind);
figure(6);
clf(figure(6))
cla;
subplot(211)
plot(sortX)

subplot(212)
interval = round(length(sortX)*0.01);
scan = 1:interval:length(sortX);
output = turnOverPoint(sortX, interval);
meanLevel = (max(output)+min(output))/2;
plot(output)
hold on
plot([1 length(output)], [meanLevel meanLevel], 'r--')
index = find(output > meanLevel);
hold on
plot((index(1)), output(index(1)), 'ro')
hold on
plot((index(end)), output(index(end)), 'ro')
xlim = [sortX(scan(index(1)+1)) sortX(scan(index(end)))];
XYZ.x = X;
XYZ.y = Y;
XYZ.z = Z;