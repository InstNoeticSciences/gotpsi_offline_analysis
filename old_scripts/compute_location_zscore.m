% recompute z score support function for compute_location_stats

function z = compute_location_zscore(loc1, loc2)

minval = 0;
maxval = 256;

loc1 = str2num(loc1{1});
loc2 = str2num(loc2{1});

loc1x_r0 = loc1(1) - 125; % center is at 128,128
loc1y_r0 = loc1(2) - 125;

loc2x = loc2(1) - 125;
loc2y = loc2(2) - 125;

% rotate loc1 by 90 degrees
loc1x_r1 = -loc1y_r0;
loc1y_r1 = loc1x_r0;

loc1x_r2 = -loc1y_r1;
loc1y_r2 = loc1x_r1;

loc1x_r3 = -loc1y_r2;
loc1y_r3 = loc1x_r2;

% check OK
% loc1x_r4 = -loc1x_r3;
% loc1y_r4 = loc1y_r3;

dist = [ ...
    sqrt((loc1x_r0-loc2x)^2 + (loc1y_r0-loc2y)^2 )  ...
    sqrt((loc1x_r1-loc2x)^2 + (loc1y_r1-loc2y)^2 )  ...
    sqrt((loc1x_r2-loc2x)^2 + (loc1y_r2-loc2y)^2 )  ...
    sqrt((loc1x_r3-loc2x)^2 + (loc1y_r3-loc2y)^2 )];
[~,ind] = sort(dist);
pos1 = find(ind == 1); % on average 2.5

stdval = sqrt(( (1-2.5)^2 + (2-2.5)^2 + (3-2.5)^2 + (4-2.5)^2 )/4);
z = (2.5 - pos1)/stdval;

% if loc1(1) < minval
%     minval = loc1(1);
%     fprintf('\nmin: %1.0f\n\n', minval);
% end
% if loc1(1) > maxval
%     maxval = loc1(1);
%     fprintf('\nmax: %1.0f\n\n', maxval);
% end

