function H = BESS4(w,wc,T)
% Bess4 Four Pole Bessel Filter Components
% with corner (3dB) frequency at wc.

A=2.13011;
b = [ 1 10*(wc/A) 45*(wc/A)^2 105*(wc/A)^3 105*(wc/A)^4];

B = b(1)*(j*w).^4 + b(2)*(j*w).^3 + b(3)*(j*w).^2 + b(4)*(j*w).^1 + b(5);

H=b(5)*ones(size(B))./B;


% Four Pole Bessel Filters Have Constant delay td=.339/(T*fc)
% Where td is in sample points at spacing T, filtered at fc (3dB)

