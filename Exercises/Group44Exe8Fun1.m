% The function decides which dimensions to keep. Accepts as an argument
% the X's and output the b's
function d = Group44Exe8Fun1(X)
    % The dimensions of the table are 90 X 30 because we count 90 days, 30
    % variables for each single day
    [n,p] = size(X);
    figure('Name','calculation of d')
    clf
    plot(mean(X,2))
    xlabel('variable index i')
    ylabel('sample mean of x_i')
    title('Sample mean of positivity rate i days before')
    figure('Name','calculation of d')
    clf
    plot(std(X'))
    xlabel('variable index i')
    ylabel('sample SD of x_i')
    title('Sample SD of psoitivity rate i days before')

    %% PSA and estimates of d<p using different techniques
    % center the data to 0
    X = X - repmat(sum(X)/n,n,1);
    % We find tables with the c
    covxM = cov(X);
    [eigvecM,eigvalM] = eig(covxM);
    eigvalV = diag(eigvalM); % Extract the diagonal elements
    % Order in descending order
    eigvalV = flipud(eigvalV);
    eigvecM = eigvecM(:,p:-1:1);
    neigval = length(eigvalV);
    ieigvalV = (1:p)';
    %% 1. Scree plot
    % Do a scree plot.
    figure('Name','calculation of d')
    clf
    plot(ieigvalV,eigvalV,'ko-')
    avgeig = mean(eigvalV);
    hold on
    plot(xlim,avgeig*[1 1],'b') 
    title('Scree Plot')
    xlabel('index')
    ylabel('eigenvalue')
    legend('how the eigenvalues change, from maximum to minimum','the mean')
    %% 4. Size of the variance
    avgeig = mean(eigvalV);
    ind = find(eigvalV > avgeig);
    fprintf('Dimension d using size of the variance: %d \n',length(ind));
    d = length(ind);



end