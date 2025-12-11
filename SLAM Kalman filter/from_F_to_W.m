function [pW, J_r, J_pF] = from_F_to_W(r, pF)
    % pF - pose on frame
    t = r(1:2);
    theta = r(3);
    R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    pW = R*pF + t;
    px = pF(1);
    py = pF(2);  
    J_r = [[1, 0, -sin(theta)*px-cos(theta)*py]
           [0, 1, cos(theta)*px-sin(theta)*py]];
    J_pF = R;
end