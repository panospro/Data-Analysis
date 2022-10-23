% Exercise 10

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

% We will calculate death,according to the positivity rate and the everyday
% tubing.We could get more data,but 3 columns are enough.At first we solve
% for every variable individually,we make approaches and then we get the
% mean ,or we could place them all together and calculate b11,b12,..., b150,
% b21, b2,...,b349 ,b350.We will do the first of these two and we will run
% program 8 three times,every time will make a dimension reduction and we
% will keep some value out of 50 that are given.We will get a random value
% from where we will begin to see,if the data fit and then we will model it
% ulti 27/12/2021 and finally we will make a prediction


% It depicts the new cases column of the xlsx file
New_Deaths_Column               = find(contains(Data2(1,:), 'New_Deaths'));
Week_Column                     = min(find(contains(Data2(1,:),'Week')));
New_Cases                       = find(contains(Data2(1,:), 'NewCases'));
PCR_Tests                       = find(contains(Data2(1,:),'PCR_Tests'));
Rapid_Tests                     = find(contains(Data2(1,:),'Rapid_Tests'));
Tube_Column                     = find(contains(Data2(1,:), 'Daily_Tube'));
% We assume that on 84th and 85th dates the results of pcr tests are
% inverse,because there can't be a negative number of PCR tests
Data2([84 85], PCR_Tests) = Data2([85 84], PCR_Tests);

% Because some data are incorrect and some days have a negative or 0 values of pcr tests, 
% so we change those values
positivityrates                 = max(cell2mat(Data2(3:end-5,New_Cases)),0)./ ...
    (max(0,cell2mat(Data2(3:end-5,PCR_Tests)))+max(0,cell2mat(Data2(3:end-5,Rapid_Tests))) ...
     - max(0,cell2mat(Data2(2:end-6,PCR_Tests)))-max(cell2mat(Data2(2:end-6,Rapid_Tests)),0))*100;
positivityrates(find(positivityrates == Inf)) = 0;
positivityrates = max(0,positivityrates);
Tubes = max(cell2mat(Data2(3:end - 5, Tube_Column)), 0);

% The unvaccinated tubed people have a bigger likelihood impacting the result
Total_Tubes = Tubes(:,1);
Unvax_Tubes = Tubes(:,2);

% We take a random day,which will be the start of the trimester
% We make a day array for the timester till 27/12/2021
% Some samples are wrong f.e. for the (N+1)th day the total tests< total test
% The last day is numbered 649,so we take a random number,k,and we find the
% b values,so they fit the days among k and 649.In order to have a good
% solution,we will have to take one of the early days,f.e. day<=500 and we
% take the value 400 arbitrary,because if the sample is big enough,the data
% change and we wont have a good approach
day                            = 400;
days                           = (day+1:1:649);
y                              =  max(0,cell2mat(Data2(days,New_Deaths_Column)));
X1                             = [ ];
n = length(y);
% The number of days before,to calculate the regression
daysbefore = 50;


% First the data for the positivity rates and then for the tubing 
% Positivity rates for Greece
for i=1:daysbefore
    X1(:,i)                      = positivityrates(days - daysbefore + i);
end

% We will make a dimension reduction with the PCR method
d1 = Group44Exe10Fun1(X1);
[b1PCR, rsquaredPCR] = Group44Exe10Fun2(d1, X1, y);
yfit1 = [ones(n,1) X1] * b1PCR; 

% Total tubing
X2 = [ ];
for i=1:daysbefore
    X2(:,i)                      = Total_Tubes(days - daysbefore + i);
end


d2 = Group44Exe10Fun1(X2);
[b2PCR, rsquaredPCR] = Group44Exe10Fun2(d2, X2, y);
yfit2 = [ones(n,1) X2] * b2PCR;

X3 = [ ];
for i=1:daysbefore
    X3(:,i)                      = Unvax_Tubes(days - daysbefore + i);
end

d3 = Group44Exe10Fun1(X3);
[b3PCR, rsquaredPCR] = Group44Exe10Fun2(d3, X3, y);
yfit3 = [ones(n,1) X3] * b3PCR;
figure('Name','approaches based on each element')
plot((1:n),[y, yfit1, yfit2, yfit3], 'LineWidth', 2)
title('the death prediction diagrams per day for every statistic')
xlabel('the days')
ylabel('the number of real deaths and the estimation')
legend('real values', 'values according to the positivity rate','values according to the whole intubations','values according to intubations of unvaccinated')

yfit = (yfit1 + yfit2 + yfit3) /3;
figure('Name', 'final estimation until  27/12/2021')
plot((1:n),[y, yfit], 'LineWidth', 2)
title('the daily death diagrams')
xlabel('days')
ylabel('deaths')
legend('real values', 'estimations')

figure('Name', 'Last 200 days %error')
plot((200:n), 100*(yfit(200:n)-y(200:n))./y(200:n))
title('Last 200 days %error')
xlabel('day')
ylabel('%of denying the real value')


% We make a prediction for the value 28/12/2021,our prections are: the positivityrates, 
% Total_Tubes kai unvax_tubes with the values of the last day
X1 = [X1(end,2:end), 2.7];

% Because we dont have values for the days 26 and 27/12 we will place them
% in the array ourselves.The values we found from the corresponding
% diagrams
X1(end-1) = 2.03;
X1(end-2) = 1.79;

% Same thing for the tubing
X2 = [X2(end,2:end - 2), 624, 629, 635];
X3 = [X3(end, 2:end-2), 521, 533, 540];

% Number of deaths we found in the data of eody
fprintf('real value of death in hday 28/12/2021: 61\n\n')
yfit1 = [1 X1] * b1PCR;
yfit2 = [1 X2] * b2PCR;
yfit3 = [1 X3] * b3PCR;
yfit = (yfit1 + yfit2 + yfit3)/3;
fprintf('the estimation for the number of deaths is: '+string(yfit)+'\n\n so we have an error: '+string(100 * (yfit - 61)/61) + '%% \n')