%% MATLAB Project: Hypersonic-Style Aero Surrogate + Simulink-Safe Model + Optional NN
% Purpose:
% 1) Build a simple nonlinear "hypersonic-like" aero model (toy truth),
% 2) generate data, split train/val, normalize,
% 3) ALWAYS train a Simulink-safe polynomial surrogate (W),
% 4) OPTIONALLY train a neural network (if toolbox/license available) for accuracy figures,
% 5) save aeroSurrogateModel.mat with (muX, sgX, W) always, and (net) if available.

clear; clc; close all;

%% 1) Define ranges and generate a synthetic aero dataset
% Inputs: alpha_deg (deg), Mach (proxy), q_rad_s (rad/s)

alpha_deg = linspace(-5, 20, 60);     % AoA sweep
Mach      = linspace(3, 8, 40);       % Mach sweep
q_rad_s   = linspace(-2, 2, 25);      % pitch-rate sweep

% Create 3D grid (samples)
[Adeg, M, Q] = ndgrid(alpha_deg, Mach, q_rad_s);

% --- "Truth" aero model (toy but nonlinear) ---
CL_true = (0.08*Adeg) .* (1 + 0.06*(M-3)) .* (1 - 0.0015*(Adeg-10).^2) ...
          + 0.25*tanh(0.12*(Adeg-8));

CD0     = 0.035 + 0.01*(M-3);
CDi     = 0.0025*(Adeg.^2) .* (1 + 0.02*(M-3));
CDshock = 0.03*(tanh(0.15*(Adeg-12)).^2);
CD_true = CD0 + CDi + CDshock;

Cm_static = (-0.012*Adeg) .* (1 + 0.04*(M-3)) ...
            + 0.03*tanh(0.10*(6-Adeg));
Cm_damp   = -0.06*Q .* (1 + 0.03*(M-3));
Cm_true   = Cm_static + Cm_damp;

% Stack dataset
X = [Adeg(:), M(:), Q(:)];                 % N x 3 inputs
Y = [CL_true(:), CD_true(:), Cm_true(:)];  % N x 3 outputs

% Add small noise (realism)
rng(7);
Y = Y + 0.002*randn(size(Y));

%% 2) Split into training / validation sets
N = size(X,1);
idx = randperm(N);

trainFrac = 0.8;
nTrain = round(trainFrac*N);

iTrain = idx(1:nTrain);
iVal   = idx(nTrain+1:end);

Xtr = X(iTrain,:);  Ytr = Y(iTrain,:);
Xva = X(iVal,:);    Yva = Y(iVal,:);

%% 3) Normalize inputs (important for both polynomial + NN)
muX = mean(Xtr,1);
sgX = std(Xtr,[],1);
sgX(sgX==0) = 1;

XtrN = (Xtr - muX)./sgX;
XvaN = (Xva - muX)./sgX;

%% 4) ALWAYS train a Simulink-safe polynomial ridge surrogate (W)
% (This is what you should run inside a Simulink MATLAB Function block)
Phi_tr = poly2features(XtrN);
Phi_va = poly2features(XvaN);

lambda = 1e-3;
W = (Phi_tr'*Phi_tr + lambda*eye(size(Phi_tr,2))) \ (Phi_tr'*Ytr);

Yhat_poly_va = Phi_va * W;

err_poly  = Yhat_poly_va - Yva;
rmse_poly = sqrt(mean(err_poly.^2, 1));

fprintf('Polynomial (Simulink-safe) Validation RMSE:  CL=%.4f, CD=%.4f, Cm=%.4f\n', ...
    rmse_poly(1), rmse_poly(2), rmse_poly(3));

%% 5) OPTIONAL: Train a NN surrogate (for paper accuracy figure only)
% NOTE: A fitnet object typically is NOT MATLAB Function block / codegen-friendly.
% Use it for validation plots in MATLAB, but keep Simulink using W.

useNN = license('test','Neural_Network_Toolbox') || license('test','Deep_Learning_Toolbox');

net = [];
Yhat_nn_va = [];
rmse_nn = [NaN NaN NaN];
modelType = "Polynomial Ridge Regression (Simulink-safe)";

if useNN
    % To avoid "forever training", use trainscg (scales better than trainlm)
    XtrT = XtrN';  YtrT = Ytr';
    XvaT = XvaN';  YvaT = Yva'; %#ok<NASGU>

    hiddenLayerSize = [15 15];          % smaller for speed
    net = fitnet(hiddenLayerSize, 'trainscg');  % faster on large datasets

    net.trainParam.showWindow = false;
    net.trainParam.epochs = 60;
    net.trainParam.max_fail = 6;

    % Train on training set only
    net.divideFcn = 'divideind';
    net.divideParam.trainInd = 1:size(XtrT,2);
    net.divideParam.valInd   = [];
    net.divideParam.testInd  = [];

    net = train(net, XtrT, YtrT);

    % Validate
    Yhat_nn_va = net(XvaT)';  % Nva x 3
    err_nn  = Yhat_nn_va - Yva;
    rmse_nn = sqrt(mean(err_nn.^2, 1));

    fprintf('NN (MATLAB-only) Validation RMSE:          CL=%.4f, CD=%.4f, Cm=%.4f\n', ...
        rmse_nn(1), rmse_nn(2), rmse_nn(3));

    modelType = "Polynomial (Simulink) + NN (MATLAB figures)";
else
    fprintf('NN toolbox not available (or trial not active). Using polynomial only.\n');
end

%% 6) Figures for your paper

% ---- Figure A: Coefficient trends vs AoA (truth model) at representative Mach & q ----
M0 = 6; q0 = 0;
a_plot = linspace(-5, 20, 200)';

CL_plot = (0.08*a_plot) .* (1 + 0.06*(M0-3)) .* (1 - 0.0015*(a_plot-10).^2) ...
          + 0.25*tanh(0.12*(a_plot-8));
CD_plot = (0.035 + 0.01*(M0-3)) ...
          + 0.0025*(a_plot.^2).*(1 + 0.02*(M0-3)) ...
          + 0.03*(tanh(0.15*(a_plot-12)).^2);
Cm_plot = (-0.012*a_plot).*(1 + 0.04*(M0-3)) ...
          + 0.03*tanh(0.10*(6-a_plot)) ...
          + (-0.06*q0).*(1 + 0.03*(M0-3));

figure; plot(a_plot, CL_plot, 'LineWidth', 2); grid on;
xlabel('\alpha (deg)'); ylabel('C_L');
title(sprintf('C_L vs \\alpha (Mach=%.1f, q=%.1f)', M0, q0));

figure; plot(a_plot, CD_plot, 'LineWidth', 2); grid on;
xlabel('\alpha (deg)'); ylabel('C_D');
title(sprintf('C_D vs \\alpha (Mach=%.1f, q=%.1f)', M0, q0));

figure; plot(a_plot, Cm_plot, 'LineWidth', 2); grid on;
xlabel('\alpha (deg)'); ylabel('C_m');
title(sprintf('C_m vs \\alpha (Mach=%.1f, q=%.1f)', M0, q0));

% ---- Figure B: Polynomial surrogate validation scatter ----
figure;
tiledlayout(1,3);
names = {'C_L','C_D','C_m'};
for k = 1:3
    nexttile;
    scatter(Yva(:,k), Yhat_poly_va(:,k), 8, 'filled'); grid on;
    xlabel(['True ' names{k}]); ylabel(['Pred (Poly) ' names{k}]);
    title(sprintf('%s Poly (RMSE=%.4f)', names{k}, rmse_poly(k)));
    axis equal;
end
sgtitle('Polynomial Surrogate: True vs Predicted');

% ---- Figure C (optional): NN surrogate validation scatter (if available) ----
if useNN
    figure;
    tiledlayout(1,3);
    for k = 1:3
        nexttile;
        scatter(Yva(:,k), Yhat_nn_va(:,k), 8, 'filled'); grid on;
        xlabel(['True ' names{k}]); ylabel(['Pred (NN) ' names{k}]);
        title(sprintf('%s NN (RMSE=%.4f)', names{k}, rmse_nn(k)));
        axis equal;
    end
    sgtitle('Neural Network Surrogate (MATLAB-only): True vs Predicted');
end

% ---- Figure D: Drift term example (supports "limitations" argument) ----
t = linspace(0, 12, 800)';     % seconds
dCm = 0.002*max(0, t-4);       % ramp after 4 s

figure;
plot(t, dCm, 'LineWidth', 2); grid on;
xlabel('Time (s)'); ylabel('\Delta C_m(t)');
title('Example Drift Term (Aerothermal/Deformation) for Stress Testing');

%% 7) Save Simulink-ready model file (ALWAYS includes W)
aeroModel.modelType = modelType;
aeroModel.muX = muX;
aeroModel.sgX = sgX;
aeroModel.W   = W;         % <-- Simulink uses this (always present)

if useNN
    aeroModel.net = net;   % optional (MATLAB figures)
end

save('aeroSurrogateModel.mat','aeroModel');
disp('Saved aeroSurrogateModel.mat (contains muX, sgX, W; and net if available).');

%% ---------------- Local helper function ----------------
function Phi = poly2features(XN)
% poly2features: 2nd-order polynomial features for 3 inputs [a, m, q]
% XN is N x 3
    a = XN(:,1); m = XN(:,2); q = XN(:,3);
    Phi = [ones(size(a)), a, m, q, a.^2, m.^2, q.^2, a.*m, a.*q, m.*q];
end
