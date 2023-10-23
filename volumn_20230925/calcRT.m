function rotateMatrix = calcRT(XYdegree, XZdegree, YZdegree)
rotateMatrix = ones(3,3);
% XYdegree = 0; %-4;
% XZdegree = 0; %-35;
% YZdegree = -30;
rotateDegree = [XYdegree XZdegree YZdegree]/180*pi; % corresponding to the rotation degree of plane X-Y | X-Z | Y-Z
rotateMatrix(1,1) = (cos(rotateDegree(1))*cos(rotateDegree(2)));
rotateMatrix(1,2) = (-sin(rotateDegree(1))*cos(rotateDegree(2))*cos(rotateDegree(3)) - sin(rotateDegree(2))*sin(rotateDegree(3)));
rotateMatrix(1,3) = (sin(rotateDegree(1))*cos(rotateDegree(2))*sin(rotateDegree(3)) - sin(rotateDegree(2))*cos(rotateDegree(3)));
rotateMatrix(2,1) = (sin(rotateDegree(1)));
rotateMatrix(2,2) = (cos(rotateDegree(1))*cos(rotateDegree(3)));
rotateMatrix(2,3) = (-cos(rotateDegree(1))*sin(rotateDegree(3)));
rotateMatrix(3,1) = (cos(rotateDegree(1))*sin(rotateDegree(2)));
rotateMatrix(3,2) = (-sin(rotateDegree(1))*sin(rotateDegree(2))*cos(rotateDegree(3)) + cos(rotateDegree(2))*sin(rotateDegree(3)));
rotateMatrix(3,3) = (sin(rotateDegree(1))*sin(rotateDegree(2))*sin(rotateDegree(3)) + cos(rotateDegree(2))*cos(rotateDegree(3)));
end
