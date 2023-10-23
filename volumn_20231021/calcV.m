function [V, Box] = calcV(box, LV_J, voxelPara, mask, Empty, rotate)
% mask_剔除边界蒙版
% Empty-空车标定数据
outputXYZ.box = calcPC(box, LV_J, rotate, 1);
Box = voxelized(outputXYZ.box, voxelPara);
Box.map = Box.map .* mask;
Box.value = Box.value .* mask;
Empty.map = Empty.map .* mask;
Empty.value = Empty.value .* mask;
Box.value(Box.value==0) = Empty.value(Box.value==0);
% figure(6)
% clf(figure(6))
% subplot(221)
% imagesc(Empty.map)
% axis image
% colormap jet
% subplot(222)
% imagesc(Empty.value)
% axis image
% colormap jet
% subplot(223)
% imagesc(Box.map)
% axis image
% colormap jet
% subplot(224)
% imagesc(Box.value)
% axis image
% colormap jet

%% 实时点云与背景点云差异
diffVoxel = (Empty.value - Box.value);
diffVoxel(diffVoxel < 5) = 0;
figure(7)
clf(figure(7))
% subplot(121)
imagesc(diffVoxel)
axis image
colormap jet
axis off

%% 计算体积
diffVoxel = diffVoxel * voxelPara.voxel_width * voxelPara.voxel_width;
V = nansum(diffVoxel(:))/1e9;
fprintf('基于体素计算体积 | 当前体积为： %.4f m^3\n', V);
% V_result = [V_result V];
% subplot(122)
% plot(V_result, 'o-', 'markerSize', 10, 'lineWidth', 1.5)
% xlim([1 6])
% grid on
% xlabel('箱子数 [个]', 'FontSize', 16)
% ylabel('体积 [m^3]', 'FontSize', 16)
% title('箱子个数—体积变化曲线', 'FontSize', 16);
% drawnow