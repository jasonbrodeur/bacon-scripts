function out = fitresp_1C(c_hat,x)
%%% fitresp_1A: Lloyd and Taylor (RE-Ts) function, Reichstein and L&T Format
%%% In this form, To is fixed at -46.02 C
% c_hat(1) = Rref
% c_hat(2) = Eo
% c_hat(3) = To (fixed)
global X Y stdev objfun fixed_coeff coeffs_to_fix;

%%% Fix coefficient values if specified:
%%% Modified 4-Dec-2010:  
%%% When we have fixed coefficients, the coefficients that are fed into 
%%% this function (c_hat), does not include the fixed coefficient (or else
%%% it would get adjusted by fminsearch, fmincon, etc...).However, we need
%%% that value in the proper place in c_hat, so that the function can be
%%% evaluated properly.  Therefore, we need to put it back into the right
%%% spot in c_hat, and evaluate the function, 
%%% We do not have to put it back in, as the only output is the cost
%%% function value.  Still with me?  Good.
%%% Put the coefficient in the right spot in c_hat for evaluation purposes:
if sum(coeffs_to_fix) > 0
    c_tmp = fixed_coeff;
    c_tmp(coeffs_to_fix==0) = c_hat(1:end);
    clear c_hat;
    c_hat = c_tmp;
    clear c_tmp;
end

%% Evaluation:
%%% If nargin > 1, we want to evaluate with an x value that's been inputted
%%% by the user for final evaluation purposes.  Otherwise, the evaluation
%%% is being done by the optimization function (one argument required):


if nargin > 1
%     y_hat = c_hat(:,1).*exp( -1.*c_hat(:,2) ./ ( x(:,1)+(273.15-c_hat(:,3)) ) );
    y_hat = c_hat(:,1).*exp(c_hat(:,2).*( (1./(10-(-46.02))) - (1./(x(:,1)-(-46.02))) ));
    
    out = y_hat;
else
% y_hat = c_hat(:,1).*exp( -1.*c_hat(:,2) ./ ( X(:,1)+(273.15-c_hat(:,3)) ) );
    y_hat = c_hat(:,1).*exp(c_hat(:,2).*( (1./(10-(-46.02))) - (1./(X(:,1)-(-46.02))) ));

switch objfun
    case 'OLS'
        err = sum((y_hat - Y).^2);
    case 'WSS'
        err = sum(((y_hat - Y).^2)./(stdev.^2));
    case 'MAWE'
        err = (1./length(X)) .* ( sum(abs(y_hat - Y)./stdev));
    otherwise
        disp('no objective function specified')
end
out = err;
end
% end
% if isempty(stdev)==1; err = sum((y_hat - Y).^2); else err = (1./length(X)) .* ( sum(abs(y_hat - Y)./stdev)); end
% % try 
% %     assignin('fit_eval','y_hat',y_hat);
% % catch
% % end
% end
