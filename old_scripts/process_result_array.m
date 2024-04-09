clear

%%
% get user results
data = readtable('data/sql_gotpsiresults2022-12-13.txt');
data(data.trials == 0,:) = [];

% How to cheat
% CHEAT: remote_viewing: search for targetimage var in console
% long_remote_viewing: cannot cheat (server)
% location: cannot cheat (after click)
% bubble: cannot cheat
% CHEAT: card: look for targetimage in console (pre vs post rng)
% CHEAT: cardseq: look for targetimage in console
% carddraw: cannot cheat
% lottery: draw happens after choice (not cheat)

% get game data
datestr = '2022-12-19';
files = [];
files(end+1).file    = ['data/sql_rwtrialres' datestr '.txt'];
files(end  ).name    = 'remote_viewing';
files(end  ).records = 1;
files(end  ).trials  = 20;
files(end+1).file    = ['data/sql_rvresponse' datestr '.txt'];
files(end  ).name    = 'long_remote_viewing';
files(end  ).records = 2;
files(end  ).trials  = 1;
files(end+1).file    = ['data/sql_locationres' datestr '.txt'];
files(end  ).name    = 'location';
files(end  ).records = 1;
files(end  ).trials  = 20;
files(end+1).file    = ['data/sql_bubbleres' datestr '.txt'];
files(end  ).name    = 'bubbles';
files(end  ).records = 1;
files(end  ).trials  = 1;
files(end+1).file    = ['data/sql_carddrawsres' datestr '.txt'];
files(end  ).name    = 'card_draw';
files(end  ).records = 1;
files(end  ).trials  = 10;
files(end+1).file    = ['data/sql_cardsres' datestr '.txt'];
files(end  ).name    = 'card';
files(end  ).records = 1;
files(end  ).trials  = 10;
files(end+1).file    = ['data/sql_sequentialcardsres' datestr '.txt'];
files(end  ).name    = 'sequential_card';
files(end  ).records = 1;
files(end  ).trials  = 10;
files(end+1).file    = ['data/sql_lotteries' datestr '.txt'];
files(end  ).name    = 'lottery';
files(end  ).records = 1;
files(end  ).trials  = 1;
allGames = { files.name };

% find userID with all 8 games
allUserid = table2cell(data(:,2));
users = unique(allUserid);
for iUser = 1:length(users)
    allUserid = table2cell(data(:,2));
    rowInds = strmatch(users{iUser}, allUserid, 'exact');
    fprintf('.');
    if length(rowInds) ~= 8
        data(rowInds,:) = [];
    else
        % check that we have all 8 games
        if length(unique(data.game_name(rowInds))) < 8
            disp('Duplicate games found')
            data(rowInds,:) = [];
        end

        % check that we have the required number of trial for each game
        for iGame = 1:length(rowInds)
            indGame = strmatch(data.game_name{rowInds(iGame)}, allGames, 'exact');
            if isempty(indGame)
                error('Unknown game')
            end
            if data.trials(rowInds(iGame)) < files(indGame).trials*files(indGame).records
                disp('Not enough trials')
                data(rowInds,:) = [];
                break;
            end
        end
    end
end
fprintf('\n');
users = unique(table2cell(data(:,2)));

%%
% read individual tables
for iRes = 1:length(files)
    res{iRes} = readtable(files(iRes).file);
    resUsers{iRes} = table2cell(res{iRes}(:,2));
end

% agregated z-score
userData = [];
for iUser = 1:length(users)
    for iRes = 1:length(res)
        fields = fieldnames(res{iRes});
        fieldZ = strmatch('z', lower(fields), 'exact');
        fieldT = strmatch('trials', lower(fields), 'exact');

        fieldsToShow = [ 1 2 fieldZ fieldT ];
        fprintf('Game %d: %41s, ', iRes, files(iRes).file);
        rowInds   = strmatch(users{iUser}, resUsers{iRes}, 'exact');
        rowInds   = sort(rowInds);

        % some subject info
        nTrials   = sum(res{iRes}.trials(rowInds));
        stoufferZ = sum(res{iRes}.z(rowInds))/sqrt(length(rowInds));

        % show record
        allRes = res{iRes}(rowInds(1),fieldsToShow);
        userData(iUser).userid = allRes.userid;
        userData(iUser).( [ files(iRes).name '_z' ] ) = allRes.z;
        userData(iUser).( [ files(iRes).name '_totz' ] ) = stoufferZ;
        userData(iUser).( [ files(iRes).name '_totn' ] ) = nTrials;
        if iRes == 2
            allRes = res{iRes}(rowInds(1:2),fieldsToShow);
            userData(iUser).( [ files(iRes).name '_z' ] ) = sum(allRes.z)/sqrt(2);
        end

        % print some info
        fprintf('   %5d %s z=%6s trials=%2d ', allRes{1,1}, allRes{1,2}{1}, sprintf('%1.3f', allRes{1,3}), allRes{1,4});
        fprintf('   total trials= %5d and Z:%1.3f\n', nTrials, stoufferZ);
    end

    % get data results
    rowInds = strmatch(users{iUser}, data.userid, 'exact');
    userData(iUser).table = data(rowInds,:);
    fprintf('\n\n');
end

%% flagging cheats
maxZ = 5;
minT = 100;
for iUser = 1:length(users)
    if any(userData(iUser).table.trials > minT)
        ind = find(userData(iUser).table.trials > minT);
        if any(userData(iUser).table.z(ind) > maxZ)
            userData(iUser).table
        end
    end
end

