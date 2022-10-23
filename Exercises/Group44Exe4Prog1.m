% Exercise 4

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

% We chose AEM:Aem
% The index of the country is (mod(AEM)+1)+1 because in the xlsx file
% we have one extra column that has to be skipped.
Aem                             =9699;
[number, country]               = Data1{mod(Aem,25)+2,:};
fprintf(' Number of country: %d \n Country: %s\n\n',number, country)


%%
% It depicts the country column of the xlsx file
country_column                  = find(contains(Data3(1,:), 'country'));

% It depicts the country index based on our AEM of the xlsx file
Indexes                         = find(contains(Data3(:,country_column),country));

% It depicts the year_weak column of the xlsx file
year_week_column                = find(contains(Data3(1,:), 'year_week'));

% It depicts the positivity rate column of the xlsx file
positivity_rate_column          = find(contains(Data3(1,:), 'positivity_rate'));

% It depicts the positivity rate column of the xlsx file
new_case_column          = find(contains(Data3(1,:), 'new_cases'));
test_done_column         = find(contains(Data3(1,:), 'tests_done'));


%% 1)
% We assume that every country has 42-50 weeks and not less

% Contains the index of the 42th week of the year 2021
week_2021_42                    = find(contains(Data3(Indexes,year_week_column),'2021-W42')) + Indexes(1) -1;

% The positivity rates of 2021
positivity_rates_2021           = cell2mat(Data3((week_2021_42:1:week_2021_42+8),positivity_rate_column));

% Number of bootstrap data samples
B                               = 10000;

% Bootstraping the positivity rates of 2021
bootmu21                        = bootstrp(B,@mean,positivity_rates_2021);




%% 2)

week_2020_42                    = find(contains(Data3(Indexes,year_week_column),'2020-W42')) + Indexes(1) -1;
positivity_rates_2020           = cell2mat(Data3((week_2020_42:1:week_2020_42+8),positivity_rate_column));
bootmu20                        = bootstrp(B,@mean,positivity_rates_2020);

% Ttesting the variable for a parametric check
[hs,ps,cis]                     = ttest(bootmu20,bootmu21);


% figure('Name','Positivity rates of 2020 and 2021','NumberTitle','off');
% histogram(bootmu21)
% hold on
% histogram(bootmu20)
% xline(mean(positivity_rates_2020),'--r','E[positivity2020]','DisplayName','Average Sales','LineWidth',2);
% xline(mean(positivity_rates_2021),'--b','E[positivity2021]','DisplayName','Average Sales','LineWidth',2);
% title(sprintf('Positivity rates of 2020 and 2021 of '+ string(country)))
% xlabel('% positivity rate')
% ylabel('samples of bootstraping')
% legend('positivity2021','positivity2020')


%% For the other 4 nearby countries
ci = [ ];
positivity_rates_2021 = [ ];
positivity_rates_2020 = [ ];
for i=1:5
    
    [number_of_nearby_countries, nearby_countries]               = Data1{mod(Aem + i-3,25)+2,:};

    fprintf(' Number of country: %d \n Country: %s\n\n',number_of_nearby_countries, nearby_countries)
    
    % Number of nearby countries and nearby countries names respectively
    nonc(i)=number_of_nearby_countries;
    nc{i,:}=nearby_countries;
  
    Indexes                         = find(contains(Data3(:,country_column),nc{i}));

    %% 2021
    week_2021_42                    = find(contains(Data3(Indexes,year_week_column),'2021-W42')) + Indexes(1) -1;
    new_case_2021 = zeros(50 - 42 + 1, 1);
    test_done_2021 = zeros(50 - 42 + 1, 1);
    for j = 1:length(week_2021_42)
        new_case_2021  = new_case_2021 + cell2mat(Data3(week_2021_42(j):1:week_2021_42(j)+ 50 - 42,new_case_column));
        test_done_2021  = test_done_2021 + cell2mat(Data3(week_2021_42(j):1:week_2021_42(j)+ 50 - 42,test_done_column));
    end
    positivity_rates_2021(:,i) = 100*(new_case_2021)./(test_done_2021);
    bootmu21                        = bootstrp(B,@mean,positivity_rates_2021(:,i));
    
    %% 2020
    week_2020_42                    = find(contains(Data3(Indexes,year_week_column),'2020-W42')) + Indexes(1) -1;
    new_case_2020 = zeros(50 - 42 + 1, 1);
    test_done_2020 = zeros(50 - 42 + 1, 1);
    for j = 1:length(week_2020_42)
        new_case_2020  = new_case_2020 + cell2mat(Data3(week_2020_42(j):1:week_2020_42(j)+ 50 - 42,new_case_column));
        test_done_2020  = test_done_2020 + cell2mat(Data3(week_2020_42(j):1:week_2020_42(j)+ 50 - 42,test_done_column));
            
    end
    positivity_rates_2020(:,i)      =  100*(new_case_2020)./(test_done_2020);

    bootmu20                        = bootstrp(B,@mean,positivity_rates_2020(:,i));
    [h(i),p(i),ci(i,:)]             = ttest(bootmu20, bootmu21);
 
    %h     %if you want to see the h values 

    figure('Name','Positivity rates of 2020 and 2021','NumberTitle','off');
    histogram(bootmu21)
    hold on
    histogram(bootmu20)
    xline(mean(positivity_rates_2020(:,i)),'--k','E[positivity2020]','DisplayName','Average Sales','LineWidth',2);
    xline(mean(positivity_rates_2021(:,i)),'--b','E[positivity2021]','DisplayName','Average Sales','LineWidth',2);
    title(sprintf('Positivity rates of 2020 and 2021 of '+ string(nc{i,:})))
    xlabel('% positivity rate')
    ylabel('samples of bootstraping')
    legend('positivity2021','positivity2020')
end




%%
% From here you go through the tables h, p, chi of the times for the equivalents.
% results of all the countries.h(1) of the first country is ktl ktl.

% The comparison was made with appropriate parametric test and bootstrap test for
% the country with our AEM for all 4 neighbors.

% Because there may be countries that have broken up into 'recessions'. For
% of each country separately we added the new incidents and the
% divided by the total number of trials.

% We notice from the histograms, that in all countries in 2020 it has.
% "significant" difference in positivity index from 2021. Which is
% logical since in 2020 there was a smaller number of tests that require the
% denominative. In Belgium however, although it seems that the 2 are similar.
% pointers, bleeping the equivalents so we see that 0 does not exist inside.
% in their interval so we cannot say that there are no significant ones
% difference.
