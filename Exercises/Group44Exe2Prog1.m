% Exercise 2

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
[number, country]               = Data1{mod(9699,25)+2,:};
fprintf(' Number of country: %d \n Country: %s\n',number, country);

% It depicts the country column of the xlsx file
country_column                  = find(contains(Data3(1,:), 'country'));

% It depicts the country index based on our AEM of the xlsx file
Indexes                         = find(contains(Data3(:,country_column),country));

% It depicts the positivity rate column of the xlsx file
positivity_rate_column          = find(contains(Data3(1,:), 'positivity_rate'));

% It depicts the year_weak column of the xlsx file
year_week_column                = find(contains(Data3(1,:), 'year_week'));


%% 2)
% We assume that every country has 45-50 weeks and not less

% Contains the index of the 45th week of the year 2020
week_2020_45                    = find(contains(Data3(Indexes,year_week_column),'2020-W45')) + Indexes(1) -1;

% The positivity rates of 2020
positivity_rates_2020           = cell2mat(Data3((week_2020_45:1:week_2020_45+5),positivity_rate_column));

% The week that has the max positivity rate in 2020
weekwithmaxrate20               = find(positivity_rates_2020 == max(positivity_rates_2020)) + 45 - 1;

% Every index of the week we found before that has the max positivity rate
% in 2020.There are more than 25 values,because some countries have more
% than one samples.
weeksindexes20                  = find(contains(Data3(:,year_week_column), '2020-W'+string(weekwithmaxrate20)));

% Every value of the week we found before that has the max positivity rate
% in 2020.There are more than 25 values,because some countries have more
% than one samples.
european_positivity_rates_2020  = cell2mat(Data3(weeksindexes20,positivity_rate_column));


%% 1)
% Every variable we used before does the same thing as before,but for the
% year 2021
week_2021_45                    = find(contains(Data3(Indexes,year_week_column),'2021-W45')) + Indexes(1) -1;
positivity_rates_2021           = cell2mat(Data3((week_2021_45:1:week_2021_45+5),positivity_rate_column));
weekwithmaxrate21               = find(positivity_rates_2021 == max(positivity_rates_2021)) + 45 - 1;
weeksindexes21                  = find(contains(Data3(:,year_week_column), '2021-W'+string(weekwithmaxrate21)));
european_positivity_rates_2021  = cell2mat(Data3(weeksindexes21,positivity_rate_column));
european_positivity_rates_2020  = sort(european_positivity_rates_2020);
european_positivity_rates_2021  = sort(european_positivity_rates_2021);





%% Exe2
% We plot the cdfs of the european positivity rate of 2020 and 2021
% accordingly
figure();
F20 = cumsum(european_positivity_rates_2020)/sum(european_positivity_rates_2020);
plot((1:1:length(F20)),F20,'Color','m')
hold on
F21 = cumsum(european_positivity_rates_2021)/sum(european_positivity_rates_2021);
plot((1:1:length(F21)),F21)
title('cdf for week 20'+ string(weekwithmaxrate20)+' and week 21' + string(weekwithmaxrate21))
xlabel('positivity rate')
ylabel('value of cdf')
legend('cdf of 2020','cdf of 2021','Location','Southeast')


% Number of samples 
N = 10000;

% N Bootstrapped samples
bootstat20 = [ ];
bootstat21 = [ ];
n = length(european_positivity_rates_2020);
for i=1:1:N
    rnd = unidrnd(n,n,1);
    boot20 = sort(european_positivity_rates_2020(rnd));
    boot21 = sort(european_positivity_rates_2021(rnd));
    bootstat20(:,i) = boot20;
    bootstat21(:,i) = boot21;
end
    


% We found a function on the internet that finds the Kolmogorov-Smirnov
% statistic and returns the h and p values.
% If h = 1, this indicates the rejection of the null hypothesis at the Alpha significance level.
% If h = 0, this indicates a failure to reject the null hypothesis at the Alpha significance level.
% Asymptotic p-value of the test, returned as a scalar value in the range (0,1). p is the probability 
% of observing a test statistic as extreme as, or more extreme than, the observed value under the null
% hypothesis.
% ks2stat is a test statistic, returned as a nonnegative scalar value.
h = [ ];
p = [ ];
ks2sat = [ ];
for i=1:N
    [h(i), p(i), ks2stat(i)] = kstest2(bootstat20(:,i), bootstat21(:,i));
end


if sum(h) > n/2 
    fprintf('They are not from the same distribution\n')
else
    dprintf('They are from the same distribution\n')
end

%%
% We note that they do not come from the same name, and this is why
% extract differential parameters l.
% We can say with great confidence that it is not the same.
% distributions, pmean = 8.6 * 10 ^-5