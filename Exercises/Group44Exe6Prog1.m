% Exercise 6

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

% We chose AEM:9699
% The index of the country is (mod(AEM)+1)+1 because in the xlsx file
% we have one extra column that has to be skipped.
Aem = 9699;
[number, country]               = Data1{mod(Aem,25)+2,:};


%%
% It depicts the country column of the xlsx file
country_column                  = find(contains(Data3(1,:), 'country'));
% It depicts the country index based on our AEM of the xlsx file
Indexes                         = find(contains(Data3(:,country_column),country));
% It depicts the year_weak column of the xlsx file
year_week_column                = find(contains(Data3(1,:), 'year_week'));

% It depicts the positivity rate column of the xlsx file
positivity_rate_column          = find(contains(Data3(1,:), 'positivity_rate'));

% It depicts the new cases column of the xlsx file
new_case_column          = find(contains(Data3(1,:), 'new_cases'));

% It depicts the test that have been made column of the xlsx file
test_done_column         = find(contains(Data3(1,:), 'tests_done'));


%% For the other 4 nearby countries
% We will take 2 countries after and 2 countries before our country.
% We assume that the first country is near with the last one.
for i=1:5
    % mod(-n,m) = mod(m - n, m)
    [number_of_nearby_countries, nearby_countries]               = Data1{mod(Aem + i-3,25)+2,:}; 
    % Number of nearby countries and nearby countries names respectively
    nonc(i)=number_of_nearby_countries;
    nc{i,:}=nearby_countries;
end

%% 2021
positivity_rates_2021 = [ ];
for i = 1:length(nc)
    
    Indexes                         = find(contains(Data3(:,country_column),nc(i)));
    week_2021_38                    = find(contains(Data3(Indexes,year_week_column),'2021-W38')) + Indexes(1) -1;
    if length(week_2021_38) > 1
        new_case_2021 = zeros(50 - 38 + 1, 1);
        test_done_2021 = zeros(50 - 38 + 1, 1);
        for j = 1:length(week_2021_38)
            new_case_2021  = new_case_2021 + cell2mat(Data3(week_2021_38(j):1:week_2021_38(j)+ 50 - 38,new_case_column));
            test_done_2021  = test_done_2021 + cell2mat(Data3(week_2021_38(j):1:week_2021_38(j)+ 50 - 38,test_done_column));
            
        end
        positivity_rates_2021(:,i)                  = 100*(new_case_2021)./(test_done_2021);

        
    else
        positivity_rates_2021(:,i)                  = cell2mat(Data3((week_2021_38:1:week_2021_38+ 50 - 38),positivity_rate_column));
    end
end

for i=38:50
    week ='2021-W'+string(i);
    
    % It depicts the new cases column of the xlsx file
    New_Cases                       = find(contains(Data2(1,:), 'NewCases'));
    
    % It depicts the pcr test column of the xlsx file
    PCR_Tests                       = find(contains(Data2(1,:),'PCR_Tests'));
    
    % It depicts the rapid test column of the xlsx file
    Rapid_Tests                     = find(contains(Data2(1,:),'Rapid_Tests'));
    
    % It depicts the week column of the xlsx file
    Week                            = min(find(contains(Data2(1,:),'Week')));
    
    % The days of the week we are looking for
    WeekDays                        = find(contains(Data2((1:1:end-7),Week),week));
    
    % The index of the week we are looking for
    weeksindexes21                  = find(contains(Data3(:,year_week_column), week));

%     max(NaN,0) = 0
%     if value =! NaN then
%     value = value
%     else value = 0 in order not to have NaN value

    % We calculate the daily greek positivity rate of 2021
    daily_gpr_2021                  = cell2mat(Data2(WeekDays,New_Cases))./ ...
                (max(0,cell2mat(Data2(WeekDays,PCR_Tests)))+max(0,cell2mat(Data2(WeekDays,Rapid_Tests))) ...
               - max(0,cell2mat(Data2(WeekDays-1,PCR_Tests)))-max(cell2mat(Data2(WeekDays-1,Rapid_Tests)),0))*100;
    
    % The mean of daily greek positivity rate of 2021
    greek_positivity_rates_2021(i-37) = mean(daily_gpr_2021);
    
end
greek_positivity_rates_2021 = greek_positivity_rates_2021';
for i=1:length(nc)
    % default alhpa = 0.05
    temp = corrcoef(positivity_rates_2021(:,i), greek_positivity_rates_2021);
    
    % The correlation index of 2021
    r2021(i) = temp(1,2);
end

[~, indexes] = sort(r2021);
%% The countries with the biggest correlation was Austria and Slovenia (the first and the fourth)
positivity_rates_2021 = [positivity_rates_2021(:,indexes(end)), positivity_rates_2021(:,indexes(end - 1))];
nc = [nc(indexes(end)); nc(indexes(end - 1))];
nonc = [nonc(indexes(end)); nonc(indexes(end - 1))];

%%
% We create 10000 samples with correlations,choosing random values for our countries
% and for Greece and there we found the correlation 
% It's important for every nth value of our country we choose the nth from
% greece
B = 10000;
n = length(greek_positivity_rates_2021);



for j=1:B
     indexes = randsample((1:length(positivity_rates_2021)),n,true);
     rr = corr(positivity_rates_2021(indexes,2),greek_positivity_rates_2021(indexes));
     correlations(j,1) = rr;
     % we want dust and dirt for the two countries, so we don't mess around.
     % we get the same random times
     rr = corr(positivity_rates_2021(indexes,1),greek_positivity_rates_2021(indexes));
     correlations(j,2) = rr;
end

%% Fisher transformation and diagrams
correlations = 0.5*log((1+correlations)./(1-correlations));
figure('Name',string(nc(1)) + ' and ' + string(nc(2)) +' correlation with Greek postiivity rates in 2021','NumberTitle','off');
histogram(correlations(:,1))
hold on
histogram(correlations(:,2))
xline(mean(correlations(:,1)),'--b','E[' + string(nc(1))+' positivity2021]','LineWidth',2.5);
xline(mean(correlations(:,2)),'--r','E[' + string(nc(2))+' positivity2021]','LineWidth',2.5);
title('Correlation of ' + string(nc(1))+' and '+string(nc(2))+' with greek positivity rates of 2021')
xlabel('correlations')
ylabel('samples of bootstraping')
legend(string(nc(1)) +' and Greek correlation' ,string(nc(2)) +' and Greek correlation')

%% For the mean values
[h, p, ci] = ttest(correlations(:,1), correlations(:,2));
fprintf('h sysxetish ths xwras '+string(nc(1)) +' me thn ellada\n einai kata ' + string(tanh(abs(mean(ci))))+' mikroterh apo oti h sysxetish ths\n'+string(nc(2))+' me thn ellada\n\n')

% We can see it from the diagram,where the mean value is closer to 0 for
% Austria and for Slovenia
data = mean(tanh(correlations));
fprintf('h sysxetish ths '+string(nc(1))+ ' einia: ' + string(100*data(1)/data(2)) + '%% tou syntelesths sysxetish ths '+string(nc(2))+'\n\n')
if h
    fprintf('diaferouns shmantika oi dyo syntelestes\n\n')
else
    fprintf('den diaferoun shmantika\n\n')
end

%%
% We have set the console to print the results sometimes.
% Yes they are significantly correlated, Austria's correlation with Greece is 0.23565 lower than the correlation of
% Slovenia with Greece

