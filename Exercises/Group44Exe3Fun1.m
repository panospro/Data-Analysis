% Exercise 3 fun1
function h = Group44Exe3Fun1(greek_rates, european_rates)

% Number of samples
B = 1000;

% ci and european mean calculation
ci = bootci(B, @mean, greek_rates);


eu_mean = mean(european_rates);

if ci(1) < eu_mean && ci(2) > eu_mean
    h = 0; %similar
elseif ci(1) > eu_mean
    h = -1; % greece > eu
else
    h = 1;  % greece <eu
end

