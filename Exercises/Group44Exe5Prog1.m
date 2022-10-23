% Exercise 5

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
    fprintf(' Number of country: %d \n Country: %s\n\n',number_of_nearby_countries, nearby_countries)
    
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

figure('Name','Positivity rates 2021','NumberTitle','off');
plot((38:1:50),positivity_rates_2021, 'LineWidth', 1.4)
title('Positivity rates 2021')
xlabel('week')
ylabel('% positivity rate')
legend(nc, 'Location', 'NorthWest')


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
    r202021(i) = temp(1,2);
end
    
%% 2020
% We do the same thing as before for 2020
positivity_rates_2020 = [ ];
for i = 1:length(nc)

    
    Indexes                         = find(contains(Data3(:,country_column),nc(i)));
    week_2020_38                    = find(contains(Data3(Indexes,year_week_column),'2020-W38')) + Indexes(1) -1;
    % in some countries we have to start from nth week, where we have the
    % data. We asume that there is at least one week with datas in 2020
    if length(week_2020_38) == 0
        w = 38;
        while length(week_2020_38) == 0
            w = w + 1;
            week_2020_38                    = find(contains(Data3(Indexes,year_week_column),'2020-W'+string(w))) + Indexes(1) -1;
        end
        new_case_2020 = zeros(50 - w + 1, 1);
        test_done_2020 = zeros(50 - w + 1, 1);
        for j = 1:length(week_2020_38)
            new_case_2020  = new_case_2020 + cell2mat(Data3(week_2020_38(j):1:week_2020_38(j)+ 50 - w,new_case_column));
            test_done_2020  = test_done_2020 + cell2mat(Data3(week_2020_38(j):1:week_2020_38(j)+ 50 - w,test_done_column));
            
        end
        positivity_rates_2020(:,i) = [ zeros(w - 38, 1); 100*(new_case_2020)./(test_done_2020)];
    
    elseif length(week_2020_38) > 1
        new_case_2020 = zeros(50 - 38 + 1, 1);
        test_done_2020 = zeros(50 - 38 + 1, 1);
        for j = 1:length(week_2020_38)
            new_case_2020  = new_case_2020 + cell2mat(Data3(week_2020_38(j):1:week_2020_38(j)+ 50 - 38,new_case_column));
            test_done_2020  = test_done_2020 + cell2mat(Data3(week_2020_38(j):1:week_2020_38(j)+ 50 - 38,test_done_column));
            
        end
        positivity_rates_2020(:,i) = 100*(new_case_2020)./(test_done_2020);

        
    else
        positivity_rates_2020(:,i)      = cell2mat(Data3((week_2020_38:1:week_2020_38+ 50 - 38),positivity_rate_column));
    end
end
figure('Name','Positivity rates 2020','NumberTitle','off');
plot((38:1:50),positivity_rates_2020, 'LineWidth', 1.4)
title('Positivity rates 2020')
xlabel('week')
ylabel('% positivity rate')
legend(nc, 'Location', 'NorthWest')

for i=38:50
    week ='2020-W'+string(i);

    New_Cases                       = find(contains(Data2(1,:), 'NewCases'));

    PCR_Tests                       = find(contains(Data2(1,:),'PCR_Tests'));

    Rapid_Tests                     = find(contains(Data2(1,:),'Rapid_Tests'));

    Week                            = min(find(contains(Data2(1,:),'Week')));

    WeekDays                        = find(contains(Data2((1:1:end-7),Week),week));

%     max(NaN,0) = 0
%     if value =! NaN then
%     value = value
%     else value = 0 in order not to have NaN value
    daily_gpr_2020                  = cell2mat(Data2(WeekDays,New_Cases))./ ...
                (max(0,cell2mat(Data2(WeekDays,PCR_Tests)))+max(0,cell2mat(Data2(WeekDays,Rapid_Tests))) ...
               - max(0,cell2mat(Data2(WeekDays-1,PCR_Tests)))-max(cell2mat(Data2(WeekDays-1,Rapid_Tests)),0))*100;

    greek_positivity_rates_2020(i-37) = mean(daily_gpr_2020);
    
end

greek_positivity_rates_2020 = greek_positivity_rates_2020';

for i=1:length(nc)
    % default alhpa = 0.05
    temp = corrcoef(positivity_rates_2020(:,i), greek_positivity_rates_2020);
    r2020(i) = temp(1,2);
end

%% 2020 parametricly
%  gia a = 0.05, a = 0.01 kai 20 kai 21

n = length(greek_positivity_rates_2020);
% We convert r -> z, Fischer coefficient
z2020 = 0.5*log((1+r2020)./(1-r2020));
alpha = 0.05;
z2020_low = z2020-(norminv(1-alpha/2)*sqrt(1/(n-3)));
z2020_upper = z2020+(norminv(1-alpha/2)*sqrt(1/(n-3)));
r2020_low = tanh(z2020_low);
r2020_upper = tanh(z2020_upper);
CI5_20 = [r2020_low' r2020_upper'];

n = length(greek_positivity_rates_2020);
z2020 = 0.5*log((1+r2020)./(1-r2020));
alpha = 0.01;
z2020_low = z2020-(norminv(1-alpha/2)*sqrt(1/(n-3)));
z2020_upper = z2020+(norminv(1-alpha/2)*sqrt(1/(n-3)));
r2020_low = tanh(z2020_low);
r2020_upper = tanh(z2020_upper);
CI1_20 = [r2020_low' r2020_upper'];

% We use the data with alpha = 0.05
% if the code is oncommented then diagrams for 20 me are shown
% axes the Greeks and the corresponding positivity rates
for i =1:length(nc)
    if abs(CI5_20(1)) < 0.8
        fprintf('With parametric control greek and ' + string(nc(i)) +' \n positivity rates of 2020 are related\n\n')
    else
        fprintf('With parametric control greek and ' + string(nc(i)) +' \n positivity rates of 2020 arent related\n\n')

    end
%    figure('Name','The corelation of '+string(nc(i)) + ' and Greek positivity rates 2020','NumberTitle','off');
%    plot(positivity_rates_2020(:,i), greek_positivity_rates_2020, 'O')
%    xlabel(string(nc(i)) + ' % positivity rate 2020')
%    ylabel('Greek % positivity rate 2020')
end
%% 2021 parametricly
n = length(greek_positivity_rates_2021);
% We convert r -> z, Fischer coefficient
z2021 = 0.5*log((1+r202021)./(1-r202021));
alpha = 0.05;
z2021_low = z2021-(norminv(1-alpha/2)*sqrt(1/(n-3)));
z2021_upper = z2021+(norminv(1-alpha/2)*sqrt(1/(n-3)));
r202021_low = tanh(z2021_low);
r202021_upper = tanh(z2021_upper);
CI5_21 = [r202021_low' r202021_upper'];

alpha = 0.01;
z2021_low = z2021-(norminv(1-alpha/2)*sqrt(1/(n-3)));
z2021_upper = z2021+(norminv(1-alpha/2)*sqrt(1/(n-3)));
r202021_low = tanh(z2021_low);
r202021_upper = tanh(z2021_upper);
CI1_21 = [r202021_low' r202021_upper'];
% We use the data with alpha = 0.05
% if the code is oncommented then diagrams for 20 me are shown
% axes the Greeks and the corresponding positivity rates
for i =1:length(nc)
    if abs(CI5_21(1)) < 0.8
        fprintf('With parametric control greek and ' + string(nc(i)) +' \n positivity rates of 2021 are related\n\n')
    else
        fprintf('With parametric control greek and ' + string(nc(i)) +' \n positivity rates of 2021 arent related\n\n')

    end
%    figure('Name','The corelation of '+string(nc(i)) + ' and Greek positivity rates 2021','NumberTitle','off');
%    plot(positivity_rates_2021(:,i), greek_positivity_rates_2021, 'O')
%    xlabel(string(nc(i)) + ' % positivity rate 2021')
%    ylabel('Greek % positivity rate 2021')
end


%% 2020 randomization
alpha = 0.05;
L = 1000;
for i = 1:length(nc)
    t0 = r2020(i)*sqrt((n-2)/(1-r2020(i)^2));

    for j=1:L
         X2 = randsample(positivity_rates_2020(:,i),n,false);
         rr = corr(X2,greek_positivity_rates_2020);
         t(j) = rr*sqrt((n-2)*(1-rr^2));
    end
    t = sort(t);
    [~,pos] = min(abs(t-t0));
    if pos<L*alpha/2 || pos>L*(1-alpha/2)
         H5_20(i) = 1;
         fprintf('With randomization control Greek and '+string(nc(i)) + ' \n positivity rates of 2020 are not corelated\n with alpha = 0.05\n\n')
    else
         H5_20(i) = 0;
         fprintf('With randomization control we cant say that Greek and '+string(nc(i)) + ' \n positivity rates of 2020 are not corelated\n with alpha = 0.05\n\n')
    end
end

alhpa = 0.01;
L = 1000;
for i = 1:length(nc)
    t0 = r2020(i)*sqrt((n-2)/(1-r2020(i)^2));

    for j=1:L
         X2 = randsample(positivity_rates_2020(:,i),n,false);
         rr = corr(X2,greek_positivity_rates_2020);
         t(j) = rr*sqrt((n-2)*(1-rr^2));
    end
    t = sort(t);
    [~,pos] = min(abs(t-t0));
    if pos<L*alpha/2 || pos>L*(1-alpha/2)
         H1_20(i) = 1;
         fprintf('With randomization control Greek and '+string(nc(i)) + '\n positivity rates of 2020 are not corelated\n with alpha = 0.01\n\n')
    else
         H1_20(i) = 0;
         fprintf('With randomization control we cant say that Greek and '+string(nc(i)) + ' \n positivity rates of 2020 are not corelated\n with alpha = 0.01\n\n')
    end
    % the statistics showing with whether the ô0 periexetai sto diagramma poy
    % resulted from randomization
%     figure(i)
%     histogram(t,'FaceColor', 'm');
%     xlabel('positivity rate')
%     ylabel('number of countries')
%     title('Histogram of positivity rates distribution in 2020');
%     hold on
%     xline(t0,'--r','corr','LineWidth',2);

end
%% 2021 randomization
alpha = 0.05;
L = 1000;
for i = 1:length(nc)
    t0 = r202021(i)*sqrt((n-2)/(1-r202021(i)^2));

    for j=1:L
         X2 = randsample(positivity_rates_2021(:,i),n,false);
         rr = corr(X2,greek_positivity_rates_2021);
         t(j) = rr*sqrt((n-2)*(1-rr^2));
    end
    t = sort(t);
    [~,pos] = min(abs(t-t0));
    if pos<L*alpha/2 || pos>L*(1-alpha/2)
         H5_21(i) = 1;
         fprintf('Greek and '+string(nc(i)) + ' positivity rates of 2021 are \n not corelated with alpha = 0.05\n\n')
    else
         H5_21(i) = 0;
         fprintf('We cant say that Greek and '+string(nc(i)) + ' positivity rates\n of 2021 are not corelated = 0.05\n\n')
    end


end

alhpa = 0.01;
L = 1000;
for i = 1:length(nc)
    t0 = r202021(i)*sqrt((n-2)/(1-r202021(i)^2));

    for j=1:L
         X2 = randsample(positivity_rates_2021(:,i),n,false);
         rr = corr(X2,greek_positivity_rates_2021);
         t(j) = rr*sqrt((n-2)*(1-rr^2));
    end
    t = sort(t);
    [~,pos] = min(abs(t-t0));
    if pos<L*alpha/2 || pos>L*(1-alpha/2)
         H1_21(i) = 1;
         fprintf('Greek and '+string(nc(i)) + ' positivity rates\n of 2021 are not corelated with alpha = 0.01\n\n')
    else
         H1_21(i) = 0;
         fprintf('We cant say that Greek and '+string(nc(i)) + ' positivity rates\n of 2021 are not corelated = 0.1\n\n')
    end
    % the statistics showing with whether the ô0 periexetai sto diagramma poy
    % resulted from randomization
%     figure(i)
%     histogram(t,'FaceColor', 'm');
%     xlabel('positivity rate')
%     ylabel('number of countries')
%     title('Histogram of positivity rates distribution in 2021');
%     hold on
%     xline(t0,'--r','corr','LineWidth',2);


end

%% 21
rhomax = 0;
for i = 1:length(nc)
   if max(abs(CI5_21(i,1)),abs(CI5_21(i,2))) > rhomax
      rhomax = max(abs(CI5_21(i,1)),abs(CI5_21(i,2)));
      country = nc(i);
      ind = i;
   end
end
fprintf('The country with the strongest corelation\n positivity rate with Greece in 2021 is: '+string(country)+'\n\n')

figure('Name','Positivity rates of 2021','NumberTitle','off');
plot((38:1:50),[positivity_rates_2021(:,ind), greek_positivity_rates_2021], 'LineWidth', 1.4)
title('The most correlated positivity rates are Greece - '+ string(country)+ ' positivity rates 2021')
ylabel('% positivity rates')
xlabel('week')
legend( string(country) , 'Greece', 'Location', 'SouthEast')


figure('Name','The corelation of '+string(country) + ' and Greek positivity rates 2021','NumberTitle','off');
plot(positivity_rates_2021(:,ind), greek_positivity_rates_2021, 'O')
xlabel(string(country) + ' % positivity rate 2021')
ylabel('Greek % positivity rate 2021')



%%
% We made the corresponding scatter and cluster diagrams of the Europeans.
% xwrwn between games and the European game of the fisherman who saw the biggest.
% association with Greece.
% We also did the same things for by 2020.

% The positivity rate in Greece for the last three months of 2021
% is strongly intertwined with Austrian and then Slovenian.
% We observe that there is a statistically significant correlation between games.

