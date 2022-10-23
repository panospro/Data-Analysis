% Exercise 7

clc        %clears the console
clear      %clears the memory
close all  %clears all figures


%%

% We upload the files
% Data is a representation of every file with strings and variables and it's
% a cell array type
[~, ~, Data1]                   = xlsread('EuropeanCountries.xlsx');
[~, ~, Data2]                   = xlsread('FullEodyData.xlsx');
[~, ~, Data3]                   = xlsread('ECDC-7Days-Testing.xlsx');
[~, ~, Data4]                   = xlsread('data');


% We chose AEM:Aem
% The index of the country is (mod(AEM)+1)+1 because in the xlsx file
% we have one extra column that has to be skipped.
Aem                             = 9699;
population_of_Sweden            = 10327589;

[number, country]               = Data1{mod(Aem,25)+2,:};
fprintf(' Number of country: %d \n Country: %s\n\n',number, country)



% It depicts the country column of the xlsx file
country_column                  = find(contains(Data3(1,:), 'country'));

% It depicts the country index based on our AEM of the xlsx file
Indexes                         = find(contains(Data3(:,country_column),country));

% It depicts the date column of the xlsx file
date_column                            = find(contains(Data4(1,:), 'dateRep'));
IndexesStartingDate                    = find(contains(Data4(:,date_column),'06/04/2020'));
IndexesFinishingDate                   = find(contains(Data4(:,date_column),'19/12/2021'));
% It depicts the country column of the xlsx file
country_column_Data4            = find(contains(Data4(1,:), 'countriesAndTerritories'));

% It depicts the country index based on our AEM of the xlsx file
IndexesData4                    = find(contains(Data4(:,country_column_Data4),country));

% It depicts the deaths column of the xlsx file
deaths_column                   = find(contains(Data4(1,:), 'deaths'));

% It depicts the positivity rate column of the xlsx file
positivity_rate_column          = find(contains(Data3(1,:), 'positivity_rate'));

% It depicts the positivity rates of Swden of the xlsx file
positivity_rates_of_Sweden      = Data3(Indexes,positivity_rate_column);

% It depicts the deaths of Sweden of the xlsx file
deaths_of_Sweden                = Data4(IndexesData4,deaths_column);
deaths_of_Sweden                = flip(deaths_of_Sweden);
deaths_of_Sweden                = deaths_of_Sweden(62:(end-39));

% It depicts the deaths of Sweden per million per day people of the xlsx file
deaths_per_mil                  = cell2mat(deaths_of_Sweden)*1000000/population_of_Sweden;

% It depicts the deaths of Sweden per million per week people of the xlsx file
for i=1:90
    weekly_deaths_per_mil(i)       = sum(deaths_per_mil(1:(7*i)));
end

% We take one random week which will be the starting week of
% our 4 months.
% We make one array with 16 weeks

% we should not take any of the first 4 weeks and some of
% the last sixteen
random_week                    = floor(rand()*(length(weekly_deaths_per_mil)- 20)+ 5);
weeks                          = (random_week+1:1:random_week + 16);

y                              = weekly_deaths_per_mil(weeks)';
X                              = [ ];
weeksbefore = 4;
% The number of weeks before the one we are searching for
 for i=1:weeksbefore
    X(:,i)                      = cell2mat(positivity_rates_of_Sweden(weeks - i));
    

    data = [y, X];
    [n p] = size(data);
    XX = [ones(n,1) X];
    [b,bCI,residuals,residualsInt,stats] = regress(y,XX);
    yfit = XX*b;
    e = y - yfit;
    SSresid(i) = sum(e.^2);
    SStotal = (n-1) * var(y);
    Rsq = 1 - SSresid/SStotal;
    adjRsq = 1 - SSresid/SStotal * (n-1)/(n-length(b)-1);
    figure('Name','Chart predicting deaths sampled from '+string(i)+' weeks before','NumberTitle','off')
    plot(weeks, [y, yfit], 'LineWidth', 2)
    title('Chart predicting deaths sampled from '+string(i)+' weeks before for and we count from the week' + string(random_week))
    xlabel('weeks')
    ylabel('new deaths')
    legend('real deaths', 'prediction')
    
    
 end
figure('Name','Chart showing the error versus \n how many days of lag we had for the first quarter')
plot((1:weeksbefore), SSresid)
title('cumulative squared error over the 16-week period')
xlabel('weeks behind schedule')
ylabel('Rsquere')



random_week                    = floor(rand()*(length(weekly_deaths_per_mil)- 20)+ 5);
weeks                          = (random_week+1:1:random_week + 16);

y                              = weekly_deaths_per_mil(weeks)';
X                              = [ ];
 for i=1:weeksbefore
    X(:,i)                      = cell2mat(positivity_rates_of_Sweden(weeks - i));
    

    data = [y, X];
    [n p] = size(data);
    XX = [ones(n,1) X];
    [b,bCI,residuals,residualsInt,stats] = regress(y,XX);
    yfit = XX*b;
    e = y - yfit;
    SSresid(i) = sum(e.^2);
    SStotal = (n-1) * var(y);
    Rsq = 1 - SSresid/SStotal;
    adjRsq = 1 - SSresid/SStotal * (n-1)/(n-length(b)-1);
    figure('Name','Chart predicting deaths sampled from '+string(i)+' weeks before','NumberTitle','off')
    plot(weeks, [y, yfit], 'LineWidth', 2)
    title('Chart predicting deaths sampled from  '+string(i)+' weeks before for and we count from the week' + string(random_week))
    xlabel('weeks')
    ylabel('new deaths')
    legend('real deaths', 'prediction')

    
 end
figure('Name','Chart showing the error versus \n how many days of lag we had for the first quarter')
plot((1:weeksbefore), SSresid)
title('cumulative squared error over the 16-week period')
xlabel('weeks behind schedule')
ylabel('Rsquere')