function state = onPlane(pointA, pointB, pointC, pointD)
state = 0;    
vec1 = pointA-pointB;
vec2 = pointB-pointC;
vec3 = pointC-pointD;
if abs(det([vec1(:) vec2(:) vec3(:)])) < 1e-4
    state = 1;
end
end