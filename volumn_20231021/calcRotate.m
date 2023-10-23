function outputXYZ = calcRotate(inputXYZ, rotate, showFlag)
% inputXYZ¡ªpointCloud data
% rotate¡ªrotate parameter
% showFlag¡ªshow figure or not
X = inputXYZ.x;
Y = inputXYZ.y;
Z = inputXYZ.z;

rotateMatrix = calcRT(rotate.xy, rotate.xz, rotate.yz);
PC = rotateMatrix * [X(:) Y(:) Z(:)]';
X = PC(1,:);
Y = PC(2,:);
Z = PC(3,:);
outputXYZ.x = round(X(:));
outputXYZ.y = round(Y(:));
outputXYZ.z = round(Z(:));
if showFlag
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
%     set(gca, 'projection', 'perspective')
%     set(gca, 'CameraViewAngle', 40)
%     campos([0 -500 -4500])
    % camtarget([0 0 200])
    box on
end