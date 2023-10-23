%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%empty_truck_calibration%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% �����ڲ�
if ~exist('LV_J')
    LV_J = loadjson('lv_sensor_parameters.json');
end
%% ���ݵ���
[tmpAMP, tmpDIS] = loadAMPDISfile;
%% ��ʱ��
ptr = 1;
windData = [];
frame = 50;
stdTrace = [];
V_res = [];
MAP = [];
VAL = [];
for f = 1:size(tmpDIS, 3)
    if f <= frame
        windData(:,:,ptr) = tmpDIS(:,:,f);
        ptr = ptr + 1;
    else
        ptr = mod(ptr,frame);
        if ptr == 0
            ptr = frame;
        end
        windData(:,:,ptr) = tmpDIS(:,:,f);
        stdTrace = [stdTrace reshape(std(windData,0,3)', size(windData,1)*size(windData, 2), 1)];
        figure(4)
        clf(figure(4))
        subplot(121)
        imagesc(std(windData,0,3))
        axis image
        colormap jet
        set(gca, 'CLim', [0 200])
        title('��ʱ������')
        subplot(122)
        s_windData = sort(windData,3);
        imagesc(s_windData(1:480, :, round(frame/2)))
%         windData(:,:,ptr) = s_windData(:, :, round(frame/2)); %��ֵ�滻����֡
        set(gca, 'CLim', [0 5000])
        title('��ֵ')
        axis image
        colormap jet
        ptr = ptr + 1;
        drawnow
    end
end
emptyData = s_windData(1:480, :, round(frame/2)); %����ճ��궨�ļ�
fid = fopen('empty.bin', 'w+');
fwrite(fid, emptyData','uint16');
fclose(fid);

%% ��ʼ��λ��
rotate.xy = 0;
rotate.xz = 0;
rotate.yz = 0;
outputXYZ.empty = calcPC(emptyData, LV_J, rotate, 1); % �������
%% ���Ʒ�������λ
% �޳���ڼ������yz�����λ��
[XYZ, xlim] = xPCLocate(outputXYZ.empty, 20); 
rotate.yz = calcATAN(XYZ, find( XYZ.x > xlim(1) &  XYZ.x < xlim(end)), 'yz', 20);

% �����ڼ������xy�����λ��
[XYZ, xlim] = xPCLocate(outputXYZ.empty, 20); 
theta1 = calcATAN(XYZ, find(XYZ.x < xlim(1)), 'xy', 20);
theta2 = calcATAN(XYZ, find(XYZ.x > xlim(end)), 'xy', 20);
rotate.xy = (theta1+theta2)/2;

%�����ڼ������xz�����λ��
% [XYZ, xlim] = xPCLocate(outputXYZ.empty, 20); 
% theta3 = calcATAN(XYZ, find(XYZ.x < xlim(1)), 'xz', 20);
% theta4 = calcATAN(XYZ, find(XYZ.x > xlim(end)), 'xz', 20);
% rotate.xz = (theta3+theta4)/2;

outputXYZ.empty = calcPC(emptyData, LV_J, rotate, 1); % �������
save('rotateMat.mat', 'rotate');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PC = [X(:) Y(:) Z(:)];
% kN = 10 * downSample; % ����Χ
% normal = zeros(length(X),3);
% for r = 1:length(X)
%     cent = [X(r) Y(r) Z(r)];
%     disP2P = sqrt(sum((repmat(cent, length(X), 1) - PC).^2,2));
%     index = find(abs(disP2P) < kN);
%     inputXYZ = PC(index, :);
%     inputXYZ = inputXYZ - repmat(mean(inputXYZ,1), length(index), 1);
%     [~, ~, D] = svd(inputXYZ);
%     normal(r, :) = (D(:,3)');
% end
% figure(6);
% clf(figure(6));
% subplot(131)
% pcshow([X(:) Y(:) Z(:)] , normal(:,1), 'markerSize', 5)
% set(gca, 'XColor', 'w')
% set(gca, 'YColor', 'w')
% set(gca, 'ZColor', 'w')
% set(gca, 'Color', [0.3 0.3 0.3])
% set(gcf, 'Color', [0.3 0.3 0.3])
% xlabel('X', 'color', 'w');
% ylabel('Y', 'color', 'w');
% zlabel('Z', 'color', 'w');
% colormap hsv
% grid on
% % set(gca, 'CLim', [0 7500])
% box on
% subplot(132)
% pcshow([X(:) Y(:) Z(:)] , normal(:,2), 'markerSize', 5)
% set(gca, 'XColor', 'w')
% set(gca, 'YColor', 'w')
% set(gca, 'ZColor', 'w')
% set(gca, 'Color', [0.3 0.3 0.3])
% set(gcf, 'Color', [0.3 0.3 0.3])
% xlabel('X', 'color', 'w');
% ylabel('Y', 'color', 'w');
% zlabel('Z', 'color', 'w');
% colormap hsv
% grid on
% % set(gca, 'CLim', [0 7500])
% box on
% subplot(133)
% pcshow([X(:) Y(:) Z(:)] , normal(:,3), 'markerSize', 5)
% set(gca, 'XColor', 'w')
% set(gca, 'YColor', 'w')
% set(gca, 'ZColor', 'w')
% set(gca, 'Color', [0.3 0.3 0.3])
% set(gcf, 'Color', [0.3 0.3 0.3])
% xlabel('X', 'color', 'w');
% ylabel('Y', 'color', 'w');
% zlabel('Z', 'color', 'w');
% colormap hsv
% grid on
% % set(gca, 'CLim', [0 7500])
% box on
% 
% index = find(abs(normal(:,2)) < 0.2);
% figure(5);
% pcshow([X(index) Y(index) Z(index)] , Z(index), 'markerSize', 5)
% set(gca, 'XColor', 'w')
% set(gca, 'YColor', 'w')
% set(gca, 'ZColor', 'w')
% set(gca, 'Color', [0.3 0.3 0.3])
% set(gcf, 'Color', [0.3 0.3 0.3])
% xlabel('X', 'color', 'w');
% ylabel('Y', 'color', 'w');
% zlabel('Z', 'color', 'w');
% colormap hsv
% grid on
% set(gca, 'CLim', [0 7500])
% box on
% 
% % KNN = kdtreeBuild([X(:) Y(:) Z(:)]);
% % target = randperm(size(X,1),1);