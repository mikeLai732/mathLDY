function [V, Box] = calcV(box, LV_J, voxelPara, mask, Empty, rotate)
% mask_�޳��߽��ɰ�
% Empty-�ճ��궨����
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

%% ʵʱ�����뱳�����Ʋ���
diffVoxel = (Empty.value - Box.value);
diffVoxel(diffVoxel < 5) = 0;
figure(7)
clf(figure(7))
% subplot(121)
imagesc(diffVoxel)
axis image
colormap jet
axis off

%% �������
diffVoxel = diffVoxel * voxelPara.voxel_width * voxelPara.voxel_width;
V = nansum(diffVoxel(:))/1e9;
fprintf('�������ؼ������ | ��ǰ���Ϊ�� %.4f m^3\n', V);
% V_result = [V_result V];
% subplot(122)
% plot(V_result, 'o-', 'markerSize', 10, 'lineWidth', 1.5)
% xlim([1 6])
% grid on
% xlabel('������ [��]', 'FontSize', 16)
% ylabel('��� [m^3]', 'FontSize', 16)
% title('���Ӹ���������仯����', 'FontSize', 16);
% drawnow