function [p, J_r, J_ppol] = measurement_to_map(r, p_pol)
    [p_r, Jr_ppol] = from_polar_to_cart(p_pol);
    [p, J_r, J_pr] = from_F_to_W(r, p_r);
    J_ppol = J_pr * Jr_ppol;
end