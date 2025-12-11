function [p_cart, J_ppol] = from_polar_to_cart(p_pol)
    rho = p_pol(1);
    phi = p_pol(2);
    px = rho*cos(phi);
    py = rho*sin(phi);
    p_cart = [px; py];
    J_ppol = [cos(phi) -rho*sin(phi); sin(phi)  rho*cos(phi)];
end