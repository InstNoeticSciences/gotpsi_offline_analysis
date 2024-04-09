%%
clear
datestr = datestr(now, 'YYYY-mm-DD') 
%datestr = '2022-06-22';

users            = readtable(['data/sql_userslog' datestr '.txt']);
data             = readtable(['data/sql_bubble' datestr '.txt']);
datares          = readtable(['data/sql_bubbleres' datestr '.txt']);

disp('There is an issue with segmentation below and all the data is very old')
disp('Copying the values from the server and doing a t-test2 then norminv, I get the same values as the server')

%%
uniqueUsers = unique(data.userid);
iUser = 1;
for iUser = 1:length(uniqueUsers)

    iUserStr = uniqueUsers{iUser};
    tmpRes  = datares(strcmp(datares.userid, iUserStr), :);
    tmpData = data(strcmp(data.userid, iUserStr), :);

    % add spurious sample at the end
    tmpData(end+1,:) = tmpData(end,:);
    tmpData.state(end) = 2;
    
    counter = 1;
    countSessions = 0;
    oriCounter = 1;
    prevState = 1;
    countRes = 1;
    for iRow = 1:size(tmpData,1)
    
        if tmpData.state(iRow) ~= prevState
            countSessions = countSessions + 1;
            prevState = tmpData.state(iRow);
        end
    
        if countSessions == 4 && length(tmpRes.z) >= countRes
            allTrials = tmpData(oriCounter:iRow-1,:);
            countSessions = 1;
            oriCounter = iRow;
    
            % stats
            rng0 = allTrials.rngval(allTrials.state == 0);
            rng1 = allTrials.rngval(allTrials.state == 1);
            %tval = (mean(rng0)-mean(rng1))/std([rng0;rng1])/sqrt(1/length(rng0)+1/length(rng1) );
            [~,p,~, stat] = ttest2(rng0, rng1, 'vartype', 'equal');
            z = norminv(p);
    
            fprintf('%s', uniqueUsers{iUser});
            if abs(z-tmpRes.z(countRes)) > 0.01
                fprintf(' z=%1.6f vs z=%1.6f\n', z, tmpRes.z(countRes));
            else
                fprintf(' ok\n');
            end
            countRes = countRes+1;
        end
    end
end