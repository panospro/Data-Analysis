% Exercise 1

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

% I chose AEM:9699
% The index of the country is (mod(AEM)+1)+1 because in the xlsx file
% we have one extra column that has to be skipped.
[number, country]               = Data1{mod(9699,25)+2,:};
fprintf(' Number of country: %d \n Country: %s\n',number, country)



%%
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


%%

% Histograms of the positivity rate of 2020
figure()
h20 = histogram(european_positivity_rates_2020,'Normalization','pdf','FaceColor', 'm');
xlabel('positivity rate')
ylabel('number of countries')
title('Histogram of positivity rates distribution in 2020');
hold on;

% We scaled it,so the pdf is equal to the number of countries by dividing
% it with 132
mu=expfit(european_positivity_rates_2020);
f=@(x)(exp(-x/mu)/mu);
x=min(european_positivity_rates_2020):0.1:max(european_positivity_rates_2020);
plot(x,f(x),'LineWidth',3)

figure()
h21 = histogram(european_positivity_rates_2021,'Normalization','pdf');
xlabel('positivity rate')
ylabel('number of countries')
title('Histogram of positivity rates distribution in 2021');
hold on;
mu=expfit(european_positivity_rates_2021);
f=@(x)(exp(-x/mu)/mu);
x=min(european_positivity_rates_2021):0.1:max(european_positivity_rates_2021);
plot(x,f(x),'LineWidth',3)


center_of_bins_20 = (h20.BinLimits(1) + h20.BinWidth/2:h20.BinWidth:h20.BinLimits(2) - h20.BinWidth/2);
rmse_20 = 0;
for i=center_of_bins_20
    j = ceil((i - h20.BinLimits(1))/h20.BinWidth);
    rmse_20  = rmse_20 + (f(i) - h20.Values(j))^2;
end


center_of_bins_21 = (h21.BinLimits(1) + h21.BinWidth/2:h21.BinWidth:h21.BinLimits(2) - h21.BinWidth/2);
rmse_21 = 0;
for i=center_of_bins_21
    j = ceil((i - h21.BinLimits(1))/h21.BinWidth);
    rmse_21  = rmse_21 + (f(i) - h21.Values(j))^2;
end

% RMS in the center of bins
fprintf(' This is the rms of 2020: %f \n This is the rms of 2021: %f\n',rmse_20,rmse_21)


%% 
% 1) According to European roots for the two days (weeks)
% are shown in the histograms.

% 2) Yes there is a known distribution, the exponential distribution with l = 1/mu=0.0737.
% gia by 2021 kai l=1/mu=0.0785 gia by 2020

% 3) On the histograms we plot the exponential parametric distribution that expfit gave us
% We note that exponential exponents approximate positive ones very well
% rates ths every years, also in the histogram of 2021 we see that
% there will be 2 extreme times.

