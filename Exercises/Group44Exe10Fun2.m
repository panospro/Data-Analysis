% This function calculates b with d<p with p = 30 + 1 (30 days ago +
% b0). It uses the PCR method
function [bPCRV rsquaredPCR] = Group44Exe10Fun2(d, X, y)

    yV = y;
    xM = X;
    p = size(xM,2);
    n = length(yV);

    TSS = sum((yV-mean(yV)).^2);
    % We center the data
    mxV = mean(xM);
    xcM = xM - repmat(mxV,n,1); % centered data matrix
    my = mean(yV);
    ycV = yV - my;

    [uM,sigmaM,vM] = svd(xcM,'econ');
    % we put all lambda values = 0 and then we fill them with 1
    % first d positions. Then we calculate b and calculate a
    % p - d from "quietizations"
    lambdaV = zeros(p,1);
    lambdaV(1:d) = 1;
    
    bPCRV = vM * diag(lambdaV) * inv(sigmaM) * uM'* ycV;
    bPCRV = [my - mxV*bPCRV; bPCRV];
    yfitPCRV = [ones(n,1) xM] * bPCRV; 
    resPCRV = yfitPCRV - yV;     % Calculate residuals
    RSSPCR = sum(resPCRV.^2);
    rsquaredPCR = 1 - RSSPCR/TSS;
%     figure('Name','PCR')
%     clf
%     plot(yV,yfitPCRV,'.')
%     hold on
%     xlabel('y')
%     ylabel('$\hat{y}$','Interpreter','Latex')
%     title(sprintf('PCR R^2=%1.4f',rsquaredPCR))
%     figure('Name','PCR')
%     clf
%     plot(yV,resPCRV/std(resPCRV),'.','Markersize',10)
%     hold on
%     plot(xlim,1.96*[1 1],'--c')
%     plot(xlim,-1.96*[1 1],'--c')
%     xlabel('y')
%     ylabel('e^*')
%     title('Name','PCR')
    
%     figure('Name','PCR')
%     clf
%     plot(1:1:length(yV),[yV yfitPCRV])
%     xlabel('The days')
%     ylabel('The values of y and yfit')
%     legend('the real values','the estimations')


end