function e = error_percentage(measurements)

e = 0;
if numel(measurements) > 1
    m1 = measurements(1);
    m2 =  measurements(2);
    e  = (abs(m1-m2) / mean([m1, m2])) * 100;
end
end

