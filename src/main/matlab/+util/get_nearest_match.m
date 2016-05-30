function match = get_nearest_match(values, number)
% get_nearest_match - returns the match which is closest to given number
% from the list of values
%   values - list of values to be checked for
%   number - number to be matched
%   match - matched number from values
%
% Description
%   if the values list has one number return that has nearest match
%   For others, sort the values and check the "log difference between 
%   number and value" is greater than the previous absolute log difference. 
%   On true return the previous value. If there is no match found return
%   the last value
%
%   Example  util.get_nearest_match([10, 200, 500, 1000], 100)
%       values = [10, 200, 500, 1000]
%       number = 100
%
%   During start of third iteration
%   - lastValue = 200 and error = 0.30 
%   - diff is log10(500) - log10(100) = 0.6990 and it is greater than error.
%   - reject 500 and select 200 has nearest match

if numel(values) == 1
    match = values;
    return;
end

% make values to be single rows
[row, ~] = size(values);
if row > 1
    values = transpose(values);
end

values = sort(values);
error = 0;
lastValue = values(1);
found = false;

for v = values
    diff = log10(v) - log10(number);
    if diff > error
        match = lastValue;
        found = true;
        break;
    end
    lastValue = v;
    error = abs(diff);
end

if ~ found
    match = values(end);
end
end
