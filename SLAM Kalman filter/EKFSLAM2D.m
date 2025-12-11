% By Melkamu Amare
% 2024 SAAS
clc;
% EKF-SLAM in 2D
% Initialization

% Model evolution noise
q = [0.005; 0.003];
Q = diag(q.^2);

% Measurement noise
mm = [0.25; 1*pi/180];
M = diag(mm.^2);

% Loading landmarks
load('W.mat')

% System parameters
% R → robot pose (x, y, theta)
% u → control (delta_x, delta_y, delta_theta)
% y → map (W → landmarks positions from enclosed file)

R = [0; -2.5; 0];
u = [0.1; 0.05];
y = zeros(2, size(W, 2));

% EKF-state and covariance matrix
% state (robot pose and landmark positions)
x = zeros(numel(R)+numel(W), 1); % initialize
% covariance matrix 
P = zeros(numel(x), numel(x)); % initialize 

mapspace = false(1,numel(x)); % set logic 0 to mapspace
% disp('Current mapspace:');
% disp(mapspace);
l = zeros(2, size(W, 2)); % define map size
r = find(mapspace==0, numel(R)); % search unoccupied space in robot pose
mapspace(r) = 1; % set the robot pose occupied
x(r) = R;
P(r,r) = 0;

%%%
% Graphics initialization
mapFig = figure(1);
cla;
axis([-6 6 -6 6])
axis square

% Draw landmarks
WG = line('parent', gca, 'linestyle', 'none', 'marker', 'o', 'color', 'r', 'xdata', W(1,:), 'ydata', W(2,:));
% Draw initial robot position
RG = line('parent', gca, 'marker', 'x', 'color', 'r', 'xdata', R(1), 'ydata', R(2));
% Draw initial robot position estimation
rG = line('parent', gca, 'linestyle', 'none', 'marker', '+', 'color', 'b', 'xdata', x(r(1)), 'ydata', x(r(2)));

% Initialize objects for future landmarks drawing
lG = line('parent', gca, 'linestyle', 'none', 'marker', '+', 'color', 'b', 'xdata', [], 'ydata', []);
eG = zeros(1, size(W,2));
for i = 1:numel(eG)
    eG(i) = line('parent', gca, 'color', 'g', 'xdata', [], 'ydata', []);
end
reG = line('parent', gca, 'color', 'm', 'xdata', [], 'ydata', []);


%%
% EKF-SLAM simulation

for t = 1:200
    
    % TODO Simulate robot movement and landmarks observation
    
    % simulate robot movement
    % R1 = R + [u(1) * cos(R(3)); u(1) * sin(R(3)); u(2)]
    R = move(R, u, zeros(2,1));

    % Simulate noisy landmark observations
    for i = 1:size(W, 2) % i: landmark index
        v = mm.*randn(2,1); % measurement noise
        y(:, i) = back_project_from_map(x(r), W(:,i));
    end

    %%%
    %create dynamic map pointers to be used hereafter
    m = l(l~=0)'; % pointers to landmarks
    rm = [r, m]; % pose + landmark

    %% TODO Extended Kalman Filter
    % Prediction and correction with known landmarks
    % noise
    noise = q.*randn(2, 1);
    % motion estimation
    [x(r), Fx, Fn] = move(x(r), u, noise);
    % Update robot state in the EKF state vector 
    x(r) = R;
    % Predict covariance for the robot
    P(r,r) = Fx*P(r,r)*Fx' + Fn*Q*Fn';  % pose covariance
    P(r,m) = Fx*P(r,m); % cross covariance of pose and map
    P(m,r) = P(r,m)';
    % disp(P(r, r))

    
    %%% EKF correction step

    % Find indices of mapped landmarks
    lids = find(l(1, :));  % Landmarks already mapped
    for i = lids
        % expectation: Gaussian {p_e,H}
        % landmark pointer
        n = l(:,i)'; 
        % find h(x) in EKF
        [p_e, Hr, Hl] = back_project_from_map(x(r), x(n));
        % pointers to robot and landmark.
        rl = [r, n]; 
        % expectation Jacobian
        H = [Hr, Hl]; 
        % measurement covariance
        Z1 = H*P(rl,rl)*H';
        

        Z = Z1 + M;
        % measurement of landmark i
        yi = y(:,i);

        z = yi - p_e;
        z(2) = wrapToPi(z(2));  % Wrap angular error to [-pi, pi]

        % Kalman Filter
        % Ensure Z is invertible

        if rank(Z) < size(Z, 1)
            iZ = pinv(Z);
        else
            iZ = inv(Z); % inversion of measurement covariance
        end

        K = P(rm,rl)*H'*iZ; % 
        %disp(K)

        % map update
        x(rm) = x(rm) + K*z; % state update 
        P(rm,rm) = P(rm,rm) - K*Z*K'; % covariance update
        
    end

    %%
    % TODO Check if there is new landmarks and addition to the map

    lids = find(l(1,:)==0); % all non−initialized landmarks
    if ~isempty(lids) % there are still landmarks to initialize
        i = lids(randi(numel(lids))); % pick one landmark randomly, its index is i
        n = find(mapspace==0, 2); % pointer of the new landmark in the map
        if ~isempty(n) % there is still space in the map
            mapspace(n) = 1; % block map space
            l(:,i) = n; % store landmark pointers 
            % measurement value at specific point
            yi = y(:,i);
            % reverse tracking and check new locations            
            [x(n), Gr, Gy] = measurement_to_map(x(r), yi); 
            P(n,rm) = Gr * P(r,rm);
            P(rm,n) = P(n,rm)'; % cross-covariances 
            P(n,n) = Gr*P(r,r)*Gr' + Gy*M*Gy'; % landmark covariance
        end
    end

    %%
    % Graphics drawing
    set(RG, 'xdata', R(1), 'ydata', R(2));
    set(rG, 'xdata', x(r(1)), 'ydata', x(r(2)));
    lids = find(l(1, :));
    lx = x(l(1,lids));
    ly = x(l(2,lids));
    set(lG, 'xdata', lx, 'ydata', ly); % landmark points
    for lid = lids
        le = x(l(:,lid));
        LE = P(l(:,lid),l(:,lid));
        [X, Y] = cov_to_ellipse(le, LE, 3, 16); 
        set(eG(lid), 'xdata', X, 'ydata', Y); % ellipse drawing over estimated landmark
    end
    if t > 1
        re = x(r(1:2));
        RE = P(r(1:2), r(1:2));
        [X,Y] = cov_to_ellipse(re, RE, 3, 16);
        set(reG, 'xdata', X, 'ydata', Y); % ellipse drawing over robot pose
    end
    drawnow;
    pause(0.1);
    %%%
end