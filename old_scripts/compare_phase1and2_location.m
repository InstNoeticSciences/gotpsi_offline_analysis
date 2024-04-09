clear
dateStr1 = '2023-04-26';
dateStr1 = '2023-08-23';
dateStr2 = '2023-07-01';

users1            = readtable(['data/sql_users'       dateStr1 '.txt']);
data1             = readtable(['data/sql_location'    dateStr1 '.txt']);
datares1          = readtable(['data/sql_locationres' dateStr1 '.txt']);

users2            = readtable(['data/staging_sql_users'       dateStr2 '.txt']);
data2             = readtable(['data/staging_sql_location'    dateStr2 '.txt']);
datares2          = readtable(['data/staging_sql_locationres' dateStr2 '.txt']);

% find common subjects
keepUserId = unique(data2.userid);
selected = zeros(size(data1,1),1, 'logical');
for iUser = 1:length(keepUserId)
    selected = selected | strcmp(data1.userid, keepUserId{iUser});
end
data1 = data1(selected, :);

figure; 
subplot(1,2,1); 
hist(data1.distance); 
subplot(1,2,2); 
hist(data1.distance); 

figure; 
range = [-6:0.03:6];
res = histc(data1.zscore, range);
subplot(1,2,1); bar( range, res);
hold on; yl = ylim;
plot([0 0], yl, 'r-')
res = histc(data2.zscore, range);
subplot(1,2,2); bar( range, res);
hold on; yl = ylim;
plot([0 0], yl, 'r-')
%subplot(1,2,2); hist(data2.zscore, [-6:6])

%% discrepency between datares2 and data2
indListOK = [];
users = unique(datares2.userid);
for iUser = 1:length(users)
    ind1 = find(strcmp(datares2.userid, users{iUser}));
    ind2 = find(strcmp(data2.userid,    users{iUser}));
    for iSess = 1:length(ind1)
        ind2tmp = (iSess-1)*20+1:(iSess)*20;

        zscore1 = datares2(ind1(iSess),:).z;
        zscore2 = sum(data2(ind2(ind2tmp),:).zscore)/sqrt(20);
        if abs(zscore2-zscore1) < 0.01
            res = 'ok';
            indListOK(end+1) = ind1(iSess);
        else
            res = 'NO';
        end
        fprintf('%s (%d) -> %1.3f vs %1.3f %s\n', users{iUser}, iSess, zscore1, zscore2, res);
    end
end

%% plot locations
datatmp = data1;
for iDat = 1:length(datatmp.locationrandom)
    [x, y] = strtok(datatmp(iDat,:).locationrandom{1}, ',');
    allComputerCoords(iDat,1) = str2double(x);
    allComputerCoords(iDat,2) = str2double(y(2:end));
    [x, y] = strtok(datatmp(iDat,:).locationchoosen{1}, ',');
    allUserCoords(iDat,1) = str2double(x);
    allUserCoords(iDat,2) = str2double(y(2:end));
end
figure; 
subplot(1,2,1); plot( allComputerCoords(:,1), allComputerCoords(:,2), '.')
xlim([-5 256]);
ylim([-5 256]);
subplot(1,2,2); plot( allUserCoords(    :,1), allUserCoords(    :,2), '.')
xlim([-5 256]);
ylim([-5 256]);

