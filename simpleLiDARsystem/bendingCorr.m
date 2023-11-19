function output = bendingCorr(Depth, cx, cy, fx, fy)
u = repmat([1:1:size(Depth,2)], size(Depth,1), 1);
v = repmat([1:1:size(Depth,1)]', 1, size(Depth,2));
bendCorr = cos(atan(sqrt(((u-cx)/(fx*1)).^2 + ((v-cy)/(fy*1)).^2)));
output = bendCorr;