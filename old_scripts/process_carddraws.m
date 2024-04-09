clear
datestr = '2023-04-26';
datestr = '2023-07-01'
%datestr = datestr(now, 'YYYY-mm-DD') 
prefix = 'staging_'; % use empty for production
%prefix = '';

users            = readtable(['data/' prefix 'sql_users' datestr '.txt']);
cards            = readtable(['data/' prefix 'sql_carddraws' datestr '.txt']);
cardsres         = readtable(['data/' prefix 'sql_carddrawsres' datestr '.txt']);
hall_of_fame_day = readtable(['data/' prefix 'sql_hall_of_fame_day' datestr '.txt']);

uniqueUsers = unique(cards.userid);

%for iUser = 1:length(uniqueUsers)
iUser = 1;
iUserStr = '613b878b90';
iUserStr = uniqueUsers{iUser};
tmpData = cards(strcmp(cards.userid, iUserStr), :);
tmpRes  = cardsres(strcmp(cardsres.userid, iUserStr), :)
% tmpRes.z = 0;
% tmpRes.hits = 0;

%%
counter = 1;
countSessions = 1;
for iRow = 1:size(tmpData,1)
    if tmpData.trial_num(iRow) == 1
        counter = 1;
    elseif tmpData.trial_num(iRow) == 10 && counter == 9
        % compute
        allTrials = tmpData(iRow-9:iRow,:);
        hits      = sum([allTrials.num_hits]);
        allzs = (allTrials.num_hits-5*0.5)/sqrt(5*0.5*0.5);

        z = sum(allzs)/sqrt(10);

        fprintf('%s', uniqueUsers{iUser});
        if abs(z-tmpRes.z(countSessions)) > 0.005
            if hits ~= tmpRes.hits(countSessions)
                fprintf(', difference Hit=%d vs hit=%d', hits, tmpRes.hits(countSessions));
                %error('Wrong number of hits')
            else
                fprintf(', numhit equal but');
            end
            fprintf(' z=%1.6f vs z=%1.6f XXXXXX\n', z, tmpRes.z(countSessions));
            %error('Wrong number of hits')
        else
            fprintf(' z=%1.6f vs z=%1.6f OK\n', z, tmpRes.z(countSessions));
        end
        countSessions = countSessions+1;
    else
        counter = counter + 1;
    end
end


