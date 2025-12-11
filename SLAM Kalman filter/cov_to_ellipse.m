function [X,Y] = cov_to_ellipse(meanXY, covMat, sigma, ptsNbr)

persistent circle

if isempty(circle)
    alpha = 2*pi/ptsNbr*(0:ptsNbr);
    circle = [cos(alpha); sin(alpha)];
end

L = chol(covMat)';
ellipse = sigma*L*circle;

X = meanXY(1)+ellipse(1,:);
Y = meanXY(2)+ellipse(2,:);
