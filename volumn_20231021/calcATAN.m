function theta0 = calcATAN(input, index, ax, th)
oX = input.x(index);
oY = input.y(index);
oZ = input.z(index);
if strcmpi(ax, 'yz')
    output = RANSAC(oY, oZ, th, ax);
elseif strcmpi(ax, 'xz')
    output = RANSAC(oX, oZ, th, ax);
elseif strcmpi(ax, 'xy')
    output = RANSAC(oX, oY, th, ax);
end
theta0 = atan2d(output(1),1);
if theta0 < 0
    theta0 = theta0 + 180;
end
% if theta0 > 90
theta0 = 90 - theta0;
% end
end
