% recompute z score support function for compute_location_stats

clear
stagingFlag = false; 
if ~stagingFlag
    % latest data from Production
    dateStr = '2023-04-26'; 
    fileName1 = ['data/sql_location' dateStr '_cleaned.txt'];
    fileName2 = ['data/sql_locationres' dateStr '.txt'];
    fileName3 = ['data/sql_locationres' dateStr '_corrected.txt'];
else
    % data from phase 2
    dateStr = '2023-07-01'; 
    fileName1 = ['data/staging_sql_location' dateStr '.txt'];
    fileName2 = ['data/staging_sql_locationres' dateStr '.txt'];
    fileName3 = ['data/staging_sql_locationres' dateStr '_corrected.txt'];
end

data     = readtable(fileName1);
datares  = readtable(fileName2);
datares2 = datares;
datares2(2:end,:) = [];

uniqueUsers = unique(data.userid);

%for iUser = 1:length(uniqueUsers)
countTotal = 1;
for iUser = 1:length(uniqueUsers)
    iUserStr = uniqueUsers{iUser};
    tmpData = data(strcmp(data.userid, iUserStr), :);
    tmpRes  = datares(strcmp(datares.userid, iUserStr), :);

    %%
    counter = 1;
    countSessions = 1;
    for iRow = 1:size(tmpData,1)
        if tmpData.trial(iRow) == 1
            counter = 1;
        elseif tmpData.trial(iRow) == 20 && counter == 19
            % compute
            allTrials = tmpData(iRow-19:iRow,:);

            if iscell(allTrials.locationrandom(1)) && iscell(allTrials.locationchoosen(1))
                for iTmp = 1:20
                    z(iTmp) = compute_location_zscore(allTrials.locationchoosen(iTmp), allTrials.locationrandom(iTmp));
                end
                tmpRes.z(countSessions) = sum(z)/sqrt(20); % stouffer z

                fprintf('%s processed\n', uniqueUsers{iUser});

                if countTotal > 1
                    datares2(countTotal,:)            = datares(countTotal-1,:);
                end
                datares2(countTotal,"id")         = {tmpRes.id(countSessions)};
                datares2(countTotal,"userid")     = {tmpRes.userid(countSessions)};
                datares2(countTotal,"z")          = {tmpRes.z(countSessions)};
                datares2(countTotal,"trials")     = {tmpRes.trials(countSessions)};
                datares2(countTotal,"created_at") = {tmpRes.created_at(countSessions)};

                countTotal = countTotal + 1;
            end
            countSessions = countSessions+1;
        else
            counter = counter + 1;
        end
    end
end    
writetable(datares2, fileName3);
