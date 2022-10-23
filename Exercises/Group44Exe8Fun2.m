% this function calculates b0, b1,b2,...,bx and makes the graphs
% shows
function [b rsquaredOLS]= Group44Exe8Fun2( X, y)
    % we make our data roughly as in exercise 6.6
    datM = [y, X];
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
    %% Estimation of the model and (b) plots for fitting and residuals
    %% OLS  
    bOLSV = vM * inv(sigmaM) * uM'* ycV;
    bOLSV = [my - mxV*bOLSV; bOLSV];
    yfitOLSV = [ones(n,1) xM] * bOLSV; 
    resOLSV = yV-yfitOLSV;
    RSSOLS = sum(resOLSV.^2);
    rsquaredOLS = 1 - RSSOLS/TSS;
    % here we "plot" the points (yhat, y) that should be located
    % approximately on the line y = x
    figure('Name','OLS')
    clf
    plot(yV,yfitOLSV,'.')
    hold on
    xlabel('y')
    ylabel('$\hat{y}$','Interpreter','Latex')
    title(sprintf('OLS R^2=%1.4f',rsquaredOLS))
    % "plot" the boundaries that contain most of them
    % values. Some are outside orion because they have a large error
    figure('Name','OLS')
    clf
    plot(yV,resOLSV/std(resOLSV),'.','Markersize',10)
    hold on
    plot(xlim,1.96*[1 1],'--c')
    plot(xlim,-1.96*[1 1],'--c')
    xlabel('y')
    ylabel('e^*')
    title('OLS')
    % finally we plot y and yhat
    figure('Name','OLS')
    clf
    plot((1:1:length(yV)),[yV yfitOLSV])
    xlabel('day')
    ylabel('Value of y and yhat')
    title('the deaths and our estimation')
    legend('real values','estimation')
    b = bOLSV;
    
end
