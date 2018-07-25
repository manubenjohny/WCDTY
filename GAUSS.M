function H = GAUSS(w,wc,T)
% GAUSSIAN Filter Components with corner (3dB) frequency at wc.

sigma = 0.1325*(2*pi/wc);

W=(-sigma*sigma/2)*w.^2;
H=exp(W);

% Gaussian Filters have no delay