clear
%datestr = '2022-06-22';
datestr = datestr(now, 'YYYY-mm-DD') 

users            = readtable(['data/sql_userslog' datestr '.txt']);
data             = readtable(['data/sql_lotteries' datestr '.txt']);

% 
correct = data.num_correct(end); mega = data.mega(end); z = data.z(end);
p = 0;
for k = correct:5
    p = p+ nchoosek(5,k) * nchoosek(42,5-k) / nchoosek(47,5);
end
if mega ~= 0
    p = p / 25;
end

fprintf('%1.2f vs %1.2f (database)\n', -norminv(p), z);

return


%% from the database (all 3 solutions where checked)
% the database was storing p instead of z (in the z column). Now it stores z.
% -----------------
correct = 2; mega = 0; p2 = 0.08;
%correct = 1; mega = 0; p2 = 0.45;
%correct = 0; mega = 1; p2 = 0.04;

%%
p = 0;
for k = correct:5
    p = p+ nchoosek(5,k) * nchoosek(42,5-k) / nchoosek(47,5);
end
if mega ~= 0
    p = p / 25;
end

fprintf('%1.2f vs %1.2f (ok since -6.36 is the minimum)\n', p, p2);
