% Exercise 3

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
fprintf(' Number of country: %d \n Country: %s\n\n\n',number, country)



%%
% It depicts the country column of the xlsx file
country_column                  = find(contains(Data3(1,:), 'country'));

% It depicts the index of the country based on the AEM we chose of the xlsx file
Indexes                         = find(contains(Data3(:,country_column),country));

% It depicts the new cases column of the xlsx file
new_case_column          = find(contains(Data3(1,:), 'new_cases'));

% It depicts the test that have been made column of the xlsx file
test_done_column         = find(contains(Data3(1,:), 'tests_done'));

% It depicts the year_weak column of the xlsx file
year_week_column          = find(contains(Data3(1,:), 'year_week'));



%% 2)
% We assume that every country has 45-50 weeks and not less

% Contains the index of the 45th week of the year 2020
week_2020_45                    = find(contains(Data3(Indexes,year_week_column),'2020-W45')) + Indexes(1) -1;

% The positivity rates of 2020
positivity_rates_2020           = cell2mat(Data3((week_2020_45:1:week_2020_45+5),new_case_column));

% The week that has the max positivity rate in 2020 between W45-W50
weekwithmaxrate20               = find(positivity_rates_2020 == max(positivity_rates_2020)) + 45 - 1;




%% 1)
% Every variable we used before does the same thing as before,but for the
% year 2021
week_2021_45                    = find(contains(Data3(Indexes,year_week_column),'2021-W45')) + Indexes(1) -1;
positivity_rates_2021           = cell2mat(Data3((week_2021_45:1:week_2021_45+5),new_case_column));
weekwithmaxrate21               = find(positivity_rates_2021 == max(positivity_rates_2021)) + 45 - 1;
weeksindexes21                  = find(contains(Data3(:,year_week_column), '2021-W'+string(weekwithmaxrate21)));


%% Exe3

for j=1:6
    
    %% 2020
    week                            ='2020-W'+string(weekwithmaxrate20+1-j);


    % It depicts the new cases column of the xlsx file
    New_Cases                       = find(contains(Data2(1,:), 'NewCases'));

    % It depicts the PCR tests based on our AEM of the xlsx file
    PCR_Tests                       = find(contains(Data2(1,:),'PCR_Tests'));

    % It depicts the Rapid tests column of the xlsx file
    Rapid_Tests                     = find(contains(Data2(1,:),'Rapid_Tests'));

    % It depicts the Rapid tests column of the xlsx file
    Week                            = min(find(contains(Data2(1,:),'Week')));

    % It depicts the sfozgkspfogk column of the xlsx file
    WeekDays                        = find(contains(Data2((1:1:end-7),Week),week));
    
    
    % Every index of the week we found before that has the max positivity rate
    % in 2020.There are more than 25 values,because some countries have more
    % than one samples.
    weeksindexes20                  = find(contains(Data3(:,year_week_column), week));

    % The new cases in 2020 in a specific week
    new_case_2020  = cell2mat(Data3(weeksindexes20,new_case_column));
    
    % The tests that have been made in 2020 in a specific week
    test_done_2020  = cell2mat(Data3(weeksindexes20,test_done_column));
    
    % The european positivity rate in 2020 in a specific week
    european_positivity_rates_2020 = 100*sum(new_case_2020)/sum(test_done_2020);
    
    % Daily positivity rate of 2020 for greece 
    daily_gpr_2020                  = cell2mat(Data2(WeekDays,New_Cases))./ ...
                (cell2mat(Data2(WeekDays,PCR_Tests))+cell2mat(Data2(WeekDays,Rapid_Tests)) ...
                - cell2mat(Data2(WeekDays-1,PCR_Tests))-cell2mat(Data2(WeekDays-1,Rapid_Tests)))*100;

    % The answer of exe3
    answer20(j)                     = Group44Exe3Fun1(daily_gpr_2020,mean(european_positivity_rates_2020));
   
    fprintf(week+':')
    switch(answer20(j))
        case -1     
            fprintf(' The results were different enough and\n the european positivity rate was lower than the greek one\n\n')
        
        case 1
            fprintf(' The results were different enough and\n the european positivity rate was higher than the greek one\n\n')
       
        case 0
            fprintf(' The results were about the same,\n we couldnt say that they are different enough and the european\n positivity rate was about the same as the greek one\n\n')
    end
    
    %% 2021
    week ='2021-W'+string(weekwithmaxrate21+1-j);

    New_Cases                       = find(contains(Data2(1,:), 'NewCases'));
    PCR_Tests                       = find(contains(Data2(1,:),'PCR_Tests'));
    Rapid_Tests                     = find(contains(Data2(1,:),'Rapid_Tests'));
    Week                            = min(find(contains(Data2(1,:),'Week')));
    WeekDays                        = find(contains(Data2((1:1:end-7),Week),week));
    weeksindexes21                  = find(contains(Data3(:,year_week_column), week));
    new_case_2021  = cell2mat(Data3(weeksindexes21,new_case_column));
    test_done_2021  = cell2mat(Data3(weeksindexes21,test_done_column));
    european_positivity_rates_2021 = 100*sum(new_case_2021)/sum(test_done_2021);
    
    % Daily positivity rate of 2021 for greece 
    daily_gpr_2021                  = cell2mat(Data2(WeekDays,New_Cases))./ ...
                (cell2mat(Data2(WeekDays,PCR_Tests))+cell2mat(Data2(WeekDays,Rapid_Tests)) ...
                - cell2mat(Data2(WeekDays-1,PCR_Tests))-cell2mat(Data2(WeekDays-1,Rapid_Tests)))*100;

    % The answer of exe3    
    answer21(j)                     = Group44Exe3Fun1(daily_gpr_2021,mean(european_positivity_rates_2021));
    
    fprintf(week+':')
    switch(answer21(j))
        case -1     
            fprintf(' The results were different enough and\n the european positivity rate was lower than the greek one\n\n')
        
        case 1
            fprintf(' The results were different enough and\n the european positivity rate was higher than the greek one\n\n')
       
        case 0
            fprintf(' The results were about the same,\n we couldnt say that they are different enough and the european\n positivity rate was about the same as the greek one\n\n')
    end
    
    %European weekly positivity rate 2020
    ewpr_2020(j)    = mean(european_positivity_rates_2020);
    
    %European weekly positivity rate 2021
    ewpr_2021(j)    = mean(european_positivity_rates_2021);
    
    %Greek weekly positivity rate 2020
    gwpr_2020(j)    = mean(daily_gpr_2020);
    
    %European weekly positivity rate 2021
    gwpr_2021(j)    = mean(daily_gpr_2021);
    
end

% We plot the positivity rates (of the week with the max positivity rate of
% 2020) of Greece in contrast with EE 
x=(weekwithmaxrate20-5:1:weekwithmaxrate20);
figure('Name','European vs Greek positivity rates 2020','NumberTitle','off');
plot(x,ewpr_2020,'--o',x,gwpr_2020,'-o')
title('European vs Greek positivity rates 2020')
xlabel('week')
ylabel('% positivity rate')
legend('european','greek')


% We plot the positivity rates (of the week with the max positivity rate of
% 2021) of Greece in contrast with EE 
x=(weekwithmaxrate21-5:1:weekwithmaxrate21);
figure('Name','European vs Greek positivity rates 2021','NumberTitle','off');

plot(x,ewpr_2021,'--o',x,gwpr_2021,'-o')
title('European vs Greek positivity rates 2021')
xlabel('week')
ylabel('% positivity rate')
legend('european','greek')

%% 
%13/4/20 = 15W until 20/12/20= 50W
%12/4/21 = 15W until 19/12/21= 50W
%In the console we print out when the results of Greece are related to eu
%show significant differences between games.