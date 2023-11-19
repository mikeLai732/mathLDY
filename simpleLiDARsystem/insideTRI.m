function state = insideTRI(pointA, pointB, pointC, pointD)
state = 0;
vec1 = pointB - pointA;
vec2 = pointC - pointA;
vec3 = pointD - pointA;
if dot(cross(vec1, vec2), cross(vec1, vec3)) >= 0
    state = 1;
end
end