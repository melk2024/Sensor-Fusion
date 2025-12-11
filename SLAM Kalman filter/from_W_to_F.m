function [pF, J_r, J_p] = from_W_to_F(r, pW)
    t = r(1:2);
    theta = r(3);
    R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    pF = R'*(pW-t);
    px = pW(1);
    py = pW(2);
    x = t(1);
    y = t(2);
    J_r = [[-cos(theta), -sin(theta), -sin(theta)*(px-x)+cos(theta)*(py-y)]
            [sin(theta), -cos(theta), -cos(theta)*(px-x)-sin(theta)*(py-y)]];
    J_p = R';
end