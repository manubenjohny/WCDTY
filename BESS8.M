function H = BESS8(w,wc,T)
% BESS8 Eight Pole Bessel Filter Components
% with corner (3dB) frequency at wc.

A=3.17002;
b = [ 1 36*(wc/A) 630*(wc/A)^2 6930*(wc/A)^3 9450*(wc/A)^4 270270*(wc/A)^5 945945*(wc/A)^6 2027025*(wc/A)^7 2027025*(wc/A)^8];

B = b(1)*(j*w).^8 + b(2)*(j*w).^7 + b(3)*(j*w).^6 + b(4)*(j*w).^5 + b(5)*(j*w).^4 + b(6)*(j*w).^3 + b(7)*(j*w).^2 + b(8)*(j*w).^1 + b(9);

H=b(9)*ones(size(B))./B;

% Eight Pole Bessel Filters Have Constant delay td=.5045/(T*fc)
% Where td is in sample points at spacing T, filtered at fc (3dB)

