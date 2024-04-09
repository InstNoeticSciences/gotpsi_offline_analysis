clear
dateStr1 = '2023-04-26';
dateStr1 = '2023-08-23';
dateStr2 = '2023-07-01';

users1            = readtable(['data/sql_users'       dateStr1 '.txt']);
data1             = readtable(['data/sql_carddraws'    dateStr1 '.txt']);
datares1          = readtable(['data/sql_carddrawsres' dateStr1 '.txt']);

users2            = readtable(['data/staging_sql_users'       dateStr2 '.txt']);
data2             = readtable(['data/staging_sql_carddraws'    dateStr2 '.txt']);
datares2          = readtable(['data/staging_sql_carddrawsres' dateStr2 '.txt']);

% find common subjects
keepUserId = unique(data2.userid);
selected = zeros(size(data1,1),1, 'logical');
for iUser = 1:length(keepUserId)
    selected = selected | strcmp(data1.userid, keepUserId{iUser});
end
data1 = data1(selected, :);

%%
figure; 
range = [-20:20];
res = histc(data1.odds, range);
subplot(1,2,1); bar( range, res);
hold on; yl = ylim;
plot([0 0], yl, 'r-')
res = histc(data2.odds, range);
subplot(1,2,2); bar( range, res);
hold on; yl = ylim;
plot([0 0], yl, 'r-')

%%
figure; 
range = [0:6];
res = histc(data1.num_hits, range);
subplot(1,2,1); bar( range, res);
hold on; yl = ylim;
plot([0 0], yl, 'r-')
title('Before')
res = histc([data2.num_hits], range);
subplot(1,2,2); bar( range, res);
hold on; yl = ylim;
plot([0 0], yl, 'r-')
title('After')

%%
figure; 
range = [-6:0.5:6];
res = histc(datares1.z, range);
subplot(1,2,1); bar( range, res);
hold on; yl = ylim;
plot([0 0], yl, 'r-')
res = histc(datares2.z, range);
subplot(1,2,2); bar( range, res);
hold on; yl = ylim;
plot([0 0], yl, 'r-')
