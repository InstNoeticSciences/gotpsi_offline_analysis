clear
datestr = '2022-06-22';
%datestr = datestr(now, 'YYYY-mm-DD') 

users            = readtable(['data/sql_userslog' datestr '.txt']);
cards            = readtable(['data/sql_sequentialcards' datestr '.txt']);
cardsres         = readtable(['data/sql_sequentialcardsres' datestr '.txt']);
%hall_of_fame_day = readtable(['data/sql_hall_of_fame_day' datestr '.txt']);

uniqueUsers = unique(cards.userid);

%for iUser = 1:length(uniqueUsers)
iUser = 1; %length(uniqueUsers);
iUserStr = '613b878b90';
iUserStr = uniqueUsers{iUser};
tmpData = cards(strcmp(cards.userid, iUserStr), :);
tmpRes  = cardsres(strcmp(cardsres.userid, iUserStr), :)

%%
counter = 1;
countSessions = 1;
for iRow = 1:size(tmpData,1)
    if tmpData.trial_num(iRow) == 1
        counter = 1;
    elseif tmpData.trial_num(iRow) == 10 && counter == 9
        % compute
        allTrials = tmpData(iRow-9:iRow,:);
        steps = sum(allTrials.steps(:));
        z = (3-steps/10)/sqrt(2);

        % correct z
%         z = 0;
%         for iStep = 1:10
%             z = z + (3-allTrials.steps(iStep))/sqrt(2)/sqrt(10); % Stouffer z
%         end

        fprintf('%s', uniqueUsers{iUser});
        if abs(z-tmpRes.z(countSessions)) > 0.005
            if steps ~= tmpRes.steps(countSessions)
                fprintf(', difference steps=%d vs steps=%d', steps, tmpRes.steps(countSessions));
                %error('Wrong number of hits')
            else
                fprintf(', num step equal but');
            end
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


