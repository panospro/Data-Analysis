% Exercise 8

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

% It depicts the new cases column of the xlsx file
New_Deaths_Column               = find(contains(Data2(1,:), 'New_Deaths'));
Week_Column                     = min(find(contains(Data2(1,:),'Week')));
New_Cases                       = find(contains(Data2(1,:), 'NewCases'));
PCR_Tests                       = find(contains(Data2(1,:),'PCR_Tests'));
Rapid_Tests                     = find(contains(Data2(1,:),'Rapid_Tests'));

% We assume that on 84th and 85th dates the results of pcr tests are
% inverse,because there can't be a negative number of PCR tests
Data2([84 85], PCR_Tests) = Data2([85 84], PCR_Tests);

% Because some data are incorrect and some days have a negative or 0 values of pcr tests, 
% so we change those values
positivityrates                 = max(cell2mat(Data2(3:end-7,New_Cases)),0)./ ...
    (max(0,cell2mat(Data2(3:end-7,PCR_Tests)))+max(0,cell2mat(Data2(3:end-7,Rapid_Tests))) ...
     - max(0,cell2mat(Data2(2:end-8,PCR_Tests)))-max(cell2mat(Data2(2:end-8,Rapid_Tests)),0))*100;
positivityrates(find(positivityrates == Inf)) = 0;



% We take a random day,which will be the start of the trimester
% We make a 90 day array for the timester
% Some samples are wrong f.e. for the (N+1)th day the total tests< total test
% in the Nth day,we assume there was an error or some samples are missing
% so we get a day after 120
%day                            = round(rand()*(length(positivityrates) - 210) + 120);
day = 120;
days                           = (day+1:1:day + 90);
y                              =  max(0,cell2mat(Data2(days,New_Deaths_Column)));
X                              = [ ];

% The number of days before,to calculate the regression
daysbefore = 30;

% Positivity rates for Greece
for i=1:daysbefore
    X(:,i)                      = positivityrates(days - daysbefore + i);
end
fprintf('The data for the second trimester\n\n')
[b1, rsquared1OLS]= Group44Exe8Fun2(X, y);
d1 = Group44Exe8Fun1(X);
[b1PCR, rsquaredPCR] = Group44Exe8Fun3(d1, X, y);

% We see that in the first method,the function has a better approach to y 
% the more value we get for y(bigger d),the better is the approach,but we 
% increase complexity.We selected the d value,so every value above the mean 
% we counted them and the other we descarded them.The values come from the
% X array,which has 90 observations.We can increase or decrease d,depending
% on how good we want our approach to be
day = 250;
days                           = (day+1:1:day + 90);
y                              =  max(0,cell2mat(Data2(days,New_Deaths_Column)));
X                              = [ ];
daysbefore = 30;
for i=1:daysbefore
    X(:,i)                      = positivityrates(days - daysbefore + i);
end

fprintf('The data for the second trimester\n\n')
[b2, rsquared2OLS] = Group44Exe8Fun2(X, y);
d2 = Group44Exe8Fun1(X);
[b2PCR, rsquared2PCR] = Group44Exe8Fun3(d2, X, y);
% In the second trimester we get d = 2 and we have a good approach.
% We can increase or decrease d,depending on how good we want our approach to be
% The b values consists of b values with the method PCA,where bPCR are with
% the method of redused demensions PCR.
% In the graphs,there are the graphical representations and in the variable
% rsquared,how good this approach is.
