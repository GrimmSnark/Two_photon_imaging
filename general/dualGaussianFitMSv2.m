function y=dualGaussianFitMS(x)
% dualGaussianFit computes the best fitting pair of Gaussian functions
% for orientation tuning curves.  It assumes two peaks over 360 degrees.
% It returns the fit structure.
%
% Form y=dualGaussianFit(x) where x = column vector of the tuning data
% ==============================
% Correcting for missing factor of 2 in denominator of exponent, 21 July
% 2011
% ==============================


xvalue = linspace(0, 360, length(x)+1);
xvalue = xvalue(1:end-1)';

%  testfit=fittype('a1*exp(-((x-b1)^2)/(2*c1^2)) + a2*exp(-((x-b2)^2)/(2*c2^2)) + d');
 testfit = fittype ('A*exp(k*cos(2*(x-PO)))','coefficients',{'A','PO','k'},'independent','x');

[f1,f2]=fit(xvalue,x',testfit);

plot(xvalue,x,'.');hold on;
%  plot(f1,'k');hold off;

hold on;
dx = 0:0.01:2*pi;
plot (180/pi*dx, f1.A * exp (f1.k * cos (2*(dx-f1.PO))), 'r');

end