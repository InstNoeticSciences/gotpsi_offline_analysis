clear
datestr = datestr(now, 'YYYY-mm-DD') 
%datestr = '2022-06-22';

users            = readtable(['data/sql_userslog' datestr '.txt']);
data             = readtable(['data/sql_rwtrial' datestr '.txt']);
datares          = readtable(['data/sql_rwtrialres' datestr '.txt']);

uniqueUsers = unique(data.userid);

%for iUser = 1:length(uniqueUsers)
for iUser = 1:length(uniqueUsers)
    iUserStr = uniqueUsers{iUser};
    %iUserStr = '55b4aecc9c';
    %iUserStr = data.userid{end};
    
    tmpData = data(strcmp(data.userid, iUserStr), :);
    tmpRes  = datares(strcmp(datares.userid, iUserStr), :);
    
    %%
    disp('Note from old analysis: some differences with other users d06d61becd, but likely old data')
    disp('The math is OK - need to figure out the spurious sessions')
    counter = 1;
    countSessions = 1;
    for iRow = 1:size(tmpData,1)
        if tmpData.trialNum(iRow) == 1
            counter = 1;
        elseif tmpData.trialNum(iRow) == 20 && counter == 19
            % compute
            allTrials = tmpData(iRow-19:iRow,:);
            hits = sum(allTrials.isHit(:));
            z = (hits-20*0.2)/sqrt(20*0.2*0.8);
    
            fprintf('%s', iUserStr);
            if abs(z-tmpRes.z(countSessions)) > 0.005
                if hits ~= tmpRes.hits(countSessions)
                    fprintf(', difference Hit=%d vs hit(database)=%d', hits, tmpRes.hits(countSessions));
                    %error('Wrong number of hits')
                else
                    fprintf(', numhit equal but');
                end
                fprintf(' z=%1.6f vs z(database)=%1.6f\n', z, tmpRes.z(countSessions));
                %error('Wrong number of hits')
            else
                fprintf(' ok\n');
            end
            countSessions = countSessions+1;
        else
            counter = counter + 1;
        end
    end
end