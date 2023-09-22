function r = NewtonGaussian(rd, k1, k2, k3, lambda)
r = rd;
iter = 0;
% lambda = 0.05;
while iter < 1000
    F = r + k1*r^3 + k2*r^5 + k3*r^7 - rd;
    dF = 1 + 3*k1*r^2 + 5*k2*r^4 + 7*k3*r^6;
    detaR = (-dF*F)/(dF*dF + lambda);
    if abs(detaR) < 1e-4
        break;
    end
    r = r + detaR;
    iter = iter + 1;
end
% error = abs(rd - r*(1+k1*r^2+k2*r^4+k3*r^6));
end