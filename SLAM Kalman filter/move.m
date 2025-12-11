function [r, J_r, J_noise] = move(r, u, noise)
    theta = r(3);
    dx = u(1) + noise(1);
    dtheta = u(2) + noise(2);
    theta = theta + dtheta;
    dp = [dx; 0];

    if theta > pi
        theta = theta - 2*pi;
    end
    if theta < -pi
        theta = theta + 2*pi;
    end
    [t, J_dpr, J_dp] = from_F_to_W(r, dp);
    r = [t; theta];
    J_r = [J_dpr; 0 0 1];
    J_noise = [J_dp(:,1) zeros(2,1); 0 1];
end