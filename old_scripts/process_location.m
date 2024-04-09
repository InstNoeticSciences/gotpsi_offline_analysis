clear
%datestr = '2022-06-22';
stagingFlag = true; 
if ~stagingFlag
    % latest data from Production
    dateStr = '2023-04-26'; 
    staging = ''; 
else
    % data from phase 2
    dateStr = '2023-07-01'; 
    staging = 'staging_'; % use '' for not staging
end

%dateStr = datestr(now, 'YYYY-mm-DD')

users            = readtable(['data/' staging 'sql_users' dateStr '.txt']);
data             = readtable(['data/' staging 'sql_location' dateStr '.txt']);
datares          = readtable(['data/' staging 'sql_locationres' dateStr '.txt']);
hall_of_fame_day = readtable(['data/' staging 'sql_hall_of_fame_day' dateStr '.txt']);

uniqueUsers = unique(data.userid);

%for iUser = 1:length(uniqueUsers)
for iUser = 1:length(uniqueUsers)
    iUserStr = uniqueUsers{iUser};
    tmpData = data(strcmp(data.userid, iUserStr), :);
    tmpRes  = datares(strcmp(datares.userid, iUserStr), :)

    disp('Values are wrong below but the code was fixed since and checked manually')
    disp('Should work with new values')

    %%
    counter = 1;
    countSessions = 1;
    for iRow = 1:size(tmpData,1)
        if tmpData.trial(iRow) == 1
            counter = 1;
        elseif tmpData.trial(iRow) == 20 && counter == 19
            % compute
            allTrials = tmpData(iRow-19:iRow,:);

            % FOR RAW COMPUTATION FROM COORDINATES, SEE NEXT SECTION
            z = sum([allTrials.zscore])/sqrt(20);

            fprintf('%s', uniqueUsers{iUser});
            if abs(z-tmpRes.z(countSessions)) > 0.005
                fprintf(' z=%1.6f vs z=%1.6f\n', z, tmpRes.z(countSessions));
                %error('Wrong number of hits')
            else
                fprintf(' ok\n');
            end
            countSessions = countSessions+1;
        else
            counter = counter + 1;
        end
    end
    return
end

%% checking raw computation of z score, record 56352
computerX = 46;
computerY = 214;
userX = 148;
userY = 215.5625;

dist2 = 44556;
z = 0.5615;

dx = computerX-userX;
dy = computerY-userY;
height = 250;
width  = 250;
sizeSquared = height * width;

count = 0;

if dx == 0 && dy == 0
    count = sizeSquared - 1;
    p = 1 / sizeSquared;
else
    rsq = (userX - computerX)^2 + (userY - computerY)^2;

    for x = 0:(height-1)
        for y = 0:(width-1)
            if (computerX - x)^2 + (computerY - y)^2 > rsq
                count = count + 1;
            end
        end
    end
end

disp(' ');
disp('Checking raw computation')
if count ~= dist2
    disp('Count is different');
else
    disp('Count is ok');
end
p = (sizeSquared - count) / sizeSquared;
z2 = -norminv(p);
if abs(z - z2) > 0.005
    disp('z is different');
else
    disp('z is ok');
end
