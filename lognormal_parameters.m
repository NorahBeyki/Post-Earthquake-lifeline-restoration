function [mu,sigma] = lognormal_parameters(mean,stdv)

v = stdv^2;
m = mean;

if m == 0
    m=10^(-20);
end

mu    = log(m^2/sqrt(v+m^2));
sigma = sqrt(log(v/(m^2)+1));

end

