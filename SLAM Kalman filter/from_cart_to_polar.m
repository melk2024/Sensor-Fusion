function [p_pol, J_ppol_p] = from_cart_to_polar(p)
% p - any cart. pose
    px = p(1);
    py = p(2);
    rho = sqrt(px^2 + py^2);
    phi = atan2(py, px);
    p_pol = [rho; phi];
    J_ppol_p =[[px/(px^2 + py^2)^(1/2), py/(px^2 + py^2)^(1/2)]
               [-py/(px^2*(py^2/px^2+1)), 1/(px*(py^2/px^2+1))]];
end