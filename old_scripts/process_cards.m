clear 
%datestr = '2022-06-22';
datestr = datestr(now, 'YYYY-mm-DD') 

%users            = readtable(['data/sql_userslog' datestr '.txt']);
cards            = readtable(['data/sql_cards' datestr '.txt']);
cardsres         = readtable(['data/sql_cardsres' datestr '.txt']);
hall_of_fame_day = readtable(['data/sql_hall_of_fame_day' datestr '.txt']);

uniqueUsers = unique(cards.userid);

%for iUser = 1:length(uniqueUsers)
iUser = length(uniqueUsers);
if 1
    iUserStr = uniqueUsers{iUser};
else
    iUserStr = '613b878b90';
    iUserStr = '00d06796e4';
end
tmpData = cards(strcmp(cards.userid, iUserStr), :);
tmpRes  = cardsres(strcmp(cardsres.userid, iUserStr), :)

%%
disp('There was an error with old values')
disp('Should work with new values')
counter = 1;
countSessions = 1;
for iRow = 1:size(tmpData,1)
    if tmpData.trial_num(iRow) == 1
        counter = 1;
    elseif tmpData.trial_num(iRow) == 10 && counter == 9
        % compute
        allTrials = tmpData(iRow-9:iRow,:);
        hits = sum(allTrials.is_hit(:));
        z = (hits-10*0.2)/sqrt(10*0.2*0.8);

        if hits ~= tmpRes.hits(countSessions)
            fprintf('Hit=%d vs hit=%d\n', hits, tmpRes.hits(countSessions));
            error('Wrong number of hits')
        end
        if abs((z - tmpRes.z(countSessions))/z) > 0.01
            fprintf('z=%1.6f vs z=%1.6f XXXXXXXXXX\n', z, tmpRes.z(countSessions));
            %error('Wrong number of hits')
        else
            fprintf('z=%1.6f vs z=%1.6f OK\n', z, tmpRes.z(countSessions));
        end
        countSessions = countSessions+1;
    else
        counter = counter + 1;
    end
end


