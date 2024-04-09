% This script analyzes the GOTPSI data for the published paper.
% Set staging to false for the analysis of all of the users.
% Set staging to true for the analysis of the selected users.

clear

stagingFlag = false; % staging server true means phase 2; set to true or false
process_selected = true; % only process selected users in phase 2 (this has no incidence when processing phase 2 data but affect the results reported for phase 1)

if ~stagingFlag
    % latest data from Production
    dateStr   = '2023-04-26.txt'; 
    dateStr2  = '2023-08-23.txt';
    staging = ''; 
else
    % data from phase 2
    dateStr = '2023-07-01.txt'; 
    dateStr2 = dateStr;
    staging = 'staging_'; % use '' for not staging
end
users        = readtable([ 'data/' staging 'sql_users' dateStr2 ], 'NumHeaderLines',0 );
data         = readtable([ 'data/' staging 'sql_usersprogress' dateStr ], 'NumHeaderLines',0 );
dataGame{1}  = readtable([ 'data/' staging 'sql_rwtrialres' dateStr ], 'NumHeaderLines',0 );
dataGame{2}  = readtable([ 'data/' staging 'sql_rvresponse' dateStr ], 'NumHeaderLines',0 );
if stagingFlag
    dataGame{3}  = readtable([ 'data/' staging 'sql_locationres' dateStr(1:end-4) '_corrected.txt' ], 'NumHeaderLines',0 );
else
    dataGame{3}  = readtable([ 'data/' staging 'sql_locationres' dateStr(1:end-4) '.txt' ], 'NumHeaderLines',0 );
end
dataGame{4}  = readtable([ 'data/' staging 'sql_bubbleres' dateStr ], 'NumHeaderLines',0 );
dataGame{5}  = readtable([ 'data/' staging 'sql_cardsres' dateStr ], 'NumHeaderLines',0 );
dataGame{6}  = readtable([ 'data/' staging 'sql_sequentialcardsres' dateStr ], 'NumHeaderLines',0 );
dataGame{7}  = readtable([ 'data/' staging 'sql_carddrawsres' dateStr ], 'NumHeaderLines',0 );
dataGame{8}  = readtable([ 'data/' staging 'sql_lotteries' dateStr ], 'NumHeaderLines',0);

%% list of games
%  game                  trials  hist_scale
games =     {
    'remote_viewing'        20      10;
    'long_remote_viewing'   2       50;
    'location'              20      50;
    'bubbles'               1       50;
    'card'                  10      10;
    'sequential_card'       10      20;
    'card_draw'             10      10;
    'lottery'               1       5 };
sortedNames = sort(games(:,1));
gaus = @(x,mu,sig,amp,vo)amp*exp(-(((x-mu).^2)/(2*sig.^2)))+vo;

%% plot game z-scores accross dates (useful because a range of data has different method for computing z-sccore)
% --------------------------------------------------------------------------------------------------------------
if isempty(staging)
    figure;
    fprintf('Transition observed in:\n')
    for iGame = 1:size(games,1)
        gameThreshold = [ 0 0 17000 5000 28000 15000 0 21500];
        subplot(2,4, iGame);
        dataGameTmp = conv(abs(dataGame{iGame}.z), ones(1,10));
        plot(dataGameTmp);
        hold on;
        yl = ylim;
        if gameThreshold(iGame) > 0
            plot([gameThreshold(iGame) gameThreshold(iGame)], yl, 'r');
            fprintf('%20s %s\n', games{iGame,1}, dataGame{iGame}(gameThreshold(iGame),:).created_at );
        end
        title(games{iGame,1}, 'interpreter', 'none');
    end

    %remove all records before June 1st, 2022
    % ---------------------------------------
    dateThreshold = datetime('2022-06-01 00:00:00');
    for iGame = 1:length(dataGame)
        dataGame{iGame} = dataGame{iGame}(dataGame{iGame}.created_at >= dateThreshold,:);
    end
    data(data.trials == 0,:) = [];
end

% find row with all games at level 2 or more
% ---------------------------------------
rmRow = [];
for iRow = 1:size(data,1)
    if data{iRow,8} < 2
        rmRow = [ rmRow iRow ];
    end
end
data(rmRow,:) = [];

% find all users with 8 rows
% --------------------------
uniqueUsers = unique(data.userid);
numGames    = zeros(1,length(uniqueUsers));
rmList      = zeros(1,size(data,1));
rmInd       = 1;
userData    = [];
userCount   = 1;
for iUser = 1:length(uniqueUsers)
    res = strcmp(data.userid, uniqueUsers{iUser});
    userinfo = users(strcmp(users.userid, uniqueUsers{iUser}),:);

    numGames(iUser) = sum(res);
    if numGames(iUser) < 8 || size(userinfo,1) ~= 1
        indrmtmp = find(res);
        rmList(rmInd:rmInd+length(indrmtmp)-1) = indrmtmp;
        rmInd = rmInd+length(indrmtmp);
    else
        dataTmp = data(res,:);

        goodUser = true;

        if ~isempty(staging)
            % check if lottery is there twice
            if isequal(dataTmp.game_name(end), dataTmp.game_name(end-1))
                dataTmp(end,:) = [];
            end
            if length(unique(dataTmp.game_name)) ~= 8 
                goodUser = false;
            end
        else
            % original (did not work for staging data)
            if ~isequal( sort(dataTmp.game_name), sortedNames)
                goodUser = false;
            elseif dataTmp(strcmp(dataTmp.game_name, 'long_remote_viewing'), :).trials == 1
                goodUser = false;
            end
        end

        if goodUser
            userData(userCount).userid = uniqueUsers{iUser};
            userData(userCount).data   = dataTmp;
            userData(userCount).userinfo = userinfo;
            userCount = userCount + 1;
        else
            disp('Bad record detected')
            indrmtmp = find(res);
            rmList(rmInd:rmInd+length(indrmtmp)-1) = indrmtmp;
            rmInd = rmInd+length(indrmtmp);
        end
    end
    if mod(iUser,100) == 0
        fprintf('.');
    end
    if mod(iUser,1000) == 0
        fprintf('\n');
    end
end
rmList(rmInd:end) = [];
data(rmList,:) = [];

%% global game plot
% ----------------
if 0 % take all the games of all the users
    figure;
    for iGame = 1:length(games)
        dataTmp = data(strcmp(data.game_name, games{iGame,1}), :);
        dataTmp = dataTmp(dataTmp.trials >= games{iGame,2},:);
        fprintf('Number for game %s: %d\n', games{iGame,1}, size(dataTmp,1))
        subplot(2, 4, iGame);

        %%
        zVals = [dataTmp.z];
        if iGame == 8
            zVals(zVals < -5) = [];
        end
        if iGame == 6
            zVals = 10*3/sqrt(2)/sqrt(10)-10*(3-sqrt(2)*zVals)/sqrt(2)/sqrt(10);
        end
        [N,X] = hist(zVals, -7:7); %, games{iGame,3}
        cla;
        N = N/sum(N)/((X(2)-X(1)));
        N(N == 0) = NaN;
        bar(X, N);
        ylim([0 0.45])

        hold on;
        xl = xlim;
        xVals = linspace( xl(1), xl(2), 100);
        gaus = @(x,mu,sig,amp,vo)amp*exp(-(((x-mu).^2)/(2*sig.^2)))+vo;
        yVals = gaus(xVals,0,1,0.4,0);
        plot(xVals, yVals, 'r', 'linewidth', 2);
        xlim([-7 7])
        ylim([0 0.45])

        %%
        gamesTmp = games{iGame,1};
        gamesTmp(gamesTmp == '_') = ' ';
        title(gamesTmp);

    end
    setfont(gcf, 'fontsize', 16)
end

%% look up user information
%res = readtable('GotPsiIDL7_19_23.xlsx');
res = readtable('IDL2 Master Database 11_2_23.xls')
%res = readtable('IDL2_concat.csv')
%res = readtable('IDL GotPsi 10_21_21 to 1_17_24.xlsx')
allUsers = res.IDL_ID;

% compute gender, meditation status (binary), paranormal belief and experience (2 items), personality (5 items), and self-transcendence (1 item).
userInfo = [];
for iUser = 1:size(res,1)
    userInfo(iUser).ID = res.IDL_ID(iUser);
    userInfo(iUser).meditate = res.Meditate{iUser}; % Yes/No
    if isempty(userInfo(iUser).meditate)
        userInfo(iUser).meditate  = NaN;
    elseif isequal(userInfo(iUser).meditate, 'Yes')
        userInfo(iUser).meditate  = 1;
    else
        userInfo(iUser).meditate  = 0;
    end
    userInfo(iUser).paranormalbelief     = res.PB(iUser);
    userInfo(iUser).paranormalexperience = res.PE(iUser);
    userInfo(iUser).extraversion         = res.E(iUser);
    userInfo(iUser).agreeableness        = res.A(iUser);
    userInfo(iUser).conscientiousness    = res.C(iUser);
    userInfo(iUser).neuroticism          = res.N(iUser);
    userInfo(iUser).openness             = res.O(iUser);
    userInfo(iUser).cloninger            = res.Int(iUser);
end

found = 0;
for iUser = 1:length(userData)
    ind = strmatch(userData(iUser).userid, allUsers, 'exact');

    if length(ind) == 1 
        fprintf('Found %s\n', userData(iUser).userid)
        userData(iUser).meditate             = userInfo(ind).meditate;
        userData(iUser).paranormalbelief     = userInfo(ind).paranormalbelief;
        userData(iUser).paranormalexperience = userInfo(ind).paranormalexperience;
        userData(iUser).extraversion         = userInfo(ind).extraversion;
        userData(iUser).agreeableness        = userInfo(ind).agreeableness;
        userData(iUser).conscientiousness    = userInfo(ind).conscientiousness;
        userData(iUser).neuroticism          = userInfo(ind).neuroticism;
        userData(iUser).openness             = userInfo(ind).openness;
        userData(iUser).cloninger            = userInfo(ind).cloninger;
    elseif length(ind) >1
        fprintf('More than one %s\n', userData(iUser).userid)
    else
        fprintf('Not found %s\n', userData(iUser).userid)
    end

    % compute Stoufer z
    userData(iUser).stoufferz = sum(userData(iUser).data(1:7,:).z)/sqrt(8);
end 

%% compute z-score for 1st game for all users
% -------------------------------------------
uniqueUser = data.userid;
fprintf('\nNumber of unique users: %d\n', length(uniqueUser));
for iUser = 1:length(userData)
    userData(iUser).stoufferz = sum(userData(iUser).data(1:7,:).z)/sqrt(8);
end
userdat = [];
for iUser = 1:length(userData)
    userData(iUser).stoufferz = sum(userData(iUser).data(1:7,:).z)/sqrt(8);
end
for iUser = 1:length(userData)
    numGames = 8;

    topUser = userData(iUser).userid;
    userData(iUser).z = zeros(1,numGames);
    userData(iUser).keep = true;
    if mod(iUser,100) == 0
        fprintf('.');
    end

    % deal with each game
    for iGame = 1:numGames
        dataTmpUser  = dataGame{iGame}(strcmp(topUser, dataGame{iGame}.userid),:);
        if isempty(dataTmpUser) || (iGame == 2 && size(dataTmpUser,1) < 2)
            userData(iUser).z(iGame) = NaN; % first one
            userData(iUser).keep = false;
        else
            if iGame == 2 % Long RW
                userData(iUser).z(iGame) = sum(dataTmpUser(1:2,:).z)/sqrt(2);
            else
                dataTmpUser2 = dataTmpUser(dataTmpUser.trials == games{iGame,2},:);
                if iGame == 6
                    userData(iUser).z(iGame) = 10*3/sqrt(2)/sqrt(10)-10*(3-sqrt(2)*dataTmpUser(1,:).z)/sqrt(2)/sqrt(10);
                else
                    userData(iUser).z(iGame) = dataTmpUser(1,:).z;
                end
                if ~isequal(dataTmpUser, dataTmpUser2) % never occurs
                    fprintf('User %s game %s - some non-%d trials\n', topUser, games{iGame,1}, games{iGame,2});
                end
            end
            if iGame == 4
                userData(iUser).bubble_attention_mean = dataTmpUser2(1,:).bubble_attention_mean;
                userData(iUser).bubble_attention_std  = dataTmpUser2(1,:).bubble_attention_std;
                userData(iUser).bubble_baseline_mean  = dataTmpUser2(1,:).bubble_baseline_mean;
                userData(iUser).bubble_baseline_std   = dataTmpUser2(1,:).bubble_baseline_std;
            end
        end
    end
    if staging
        userData(iUser).stoufferz = sum(userData(iUser).z(1:6))/sqrt(length(userData(iUser).z(1:6)));
    else
        userData(iUser).stoufferz = sum(userData(iUser).z(1:7))/sqrt(length(userData(iUser).z(1:7)));
    end
end
userDataOri = userData;
fprintf('\n');
phase1file = 'userData_phase1and2.mat';
phase2file = 'userData_phase2.mat';
phase2file2 = 'userData_phase2_selected_participants.mat';
if stagingFlag
    disp('Saving user data phase 2...');
    save('-mat', phase2file, 'userData');
end
fprintf('\nNumber of selected users: %d\n', length(userData));

% plot only first game of all users
figure('position', [123 767 1431 539], 'color', 'w')
for iGame = 1:length(games)
    dataTmp = data(strcmp(data.game_name, games{iGame,1}), :);
    zVals = cellfun(@(x)x(iGame), {userData.z});
    subplot(2, 4, iGame);

    %%
    [N,X] = hist(zVals, -7:7); %, games{iGame,3}
    cla;
    N = N/sum(N)/((X(2)-X(1)));
    N(N == 0) = NaN;
    bar(X, N);
    ylim([0 0.45])

    hold on;
    xl = xlim;
    xVals = linspace( xl(1), xl(2), 100);
    gaus = @(x,mu,sig,amp,vo)amp*exp(-(((x-mu).^2)/(2*sig.^2)))+vo;
    yVals = gaus(xVals,0,1,0.4,0);
    plot(xVals, yVals, 'r', 'linewidth', 2);
    xlim([-7 7])
    ylim([0 0.45])

    %%
    gamesTmp = games{iGame,1};
    gamesTmp(gamesTmp == '_') = ' ';
    title(gamesTmp);

end
setfont(gcf, 'fontsize', 16)

% phase 2 participants
if stagingFlag
    if exist(phase2file2, 'file')
        phase2data = load('-mat', phase2file2);
        userData2 = phase2data.userData;
        phase2Participants = { userData2.userid };
    else
        phase2Participants = {};
    end
else
    if exist(phase2file, 'file')
        phase2data = load('-mat', phase2file);
        userData2 = phase2data.userData;
        phase2Participants = { userData2.userid };
    else
        phase2Participants = {};
    end
end    

%% compute z-score for 1st game for all users
% -------------------------------------------
userData([userData.keep] == false) = [];
[~,ind] = sort([userData.stoufferz], 'descend');
userData = userData(ind);
if isempty(staging)
    batchNumber = 4;
    userRange   = 1:300;
    file1 = ['mysql_user_batch' int2str(batchNumber) '.sql'];
    file2 = ['mysql_userprogress_batch' int2str(batchNumber) '.sql'];
    file3 = ['userstats_batch' int2str(batchNumber) '.txt'];
else
    batchNumber = 0;
    userRange   = 1:length(userData);
    file1 = ['results_phase2_mysql_user.sql'];
    file2 = ['results_phase2_mysql_userprogress.sql'];
    file3 = ['results_phase2_userstats.txt'];
end

fid1 = fopen(file1, 'w');
fid2 = fopen(file2, 'w');
fid3 = fopen(file3, 'w');
if fid1 == -1 || fid2 == -1 || fid3 == -1, error('Cannot open file'); end
countSelected = 0;
[userData.phase] = deal(1);
for iUser = userRange
    if any(contains(phase2Participants, userData(iUser).userid))
        countSelected = countSelected + 1;
        fprintf('%3d (%2d) - %s*\t%1.1f (%s)\n', iUser, countSelected, userData(iUser).userid,  userData(iUser).stoufferz, sprintf('%1.1f ', userData(iUser).z));
        userData(iUser).phase = 2;
        userData(iUser).data2      = userData2.data;
        userData(iUser).stoufferz2 = userData2.stoufferz;
        userData(iUser).z2         = userData2.z;
        userDataSelected(countSelected) = userData(iUser);
    else
        fprintf('%3d (  ) - %s \t%1.1f (%s)\n', iUser, userData(iUser).userid,  userData(iUser).stoufferz, sprintf('%1.1f ', userData(iUser).z));
    end
    fprintf(fid1, 'mysqldump --tz-utc=false --no-create-info -u ions -pctJh84M7P idl users --where="userid=''%s''" >> testtmp%d.sql\n', userData(iUser).userid, batchNumber);
    fprintf(fid2, "insert into userprogress (userid, game_name) values ('%s', 'remote_viewing');\n", userData(iUser).userid);
    fprintf(fid2, "insert into userprogress (userid, game_name) values ('%s', 'long_remote_viewing');\n", userData(iUser).userid);
    fprintf(fid2, "insert into userprogress (userid, game_name) values ('%s', 'location');\n", userData(iUser).userid);
    fprintf(fid2, "insert into userprogress (userid, game_name) values ('%s', 'bubbles');\n", userData(iUser).userid);
    fprintf(fid2, "insert into userprogress (userid, game_name) values ('%s', 'card');\n", userData(iUser).userid);
    fprintf(fid2, "insert into userprogress (userid, game_name) values ('%s', 'sequential_card');\n", userData(iUser).userid);
    fprintf(fid2, "insert into userprogress (userid, game_name) values ('%s', 'card_draw');\n", userData(iUser).userid);
    fprintf(fid2, "insert into userprogress (userid, game_name) values ('%s', 'lottery');\n", userData(iUser).userid);
    fprintf(fid2, "insert into userprogress (userid, game_name) values ('%s', 'lottery');\n", userData(iUser).userid);

    fprintf(fid3, "%s\t%s\t%s\n", userData(iUser).userid, userData(iUser).userinfo.email{1}, userData(iUser).userinfo.nickname{1});
end
fclose(fid1);
fclose(fid2);
fclose(fid3);
fprintf('\n1. Take the file %s and send it to Sitara\n', file3)
fprintf('2. Take the file %s and send it to production then execute on production\n', file1);
fprintf('3. Bring back the file testtmp%d.sql from production to local mac\n', batchNumber);
fprintf('4. Send the files testtmp%d.sql and %s to staging and execute them on SQL\n', batchNumber, file2);

if exist('userDataSelected', 'var') && process_selected
    if stagingFlag
        % disp('Saving user data phase 1 and 2...');
        % save('-mat', phase1file, 'userData'); % see other script "process_phase_1_and_2.m"
        userDataBackup = userData;
        userData = userDataSelected;
    else
        disp('Saving selected users...');
        userDataBackup = userData;
        userData = userDataSelected;
        save('-mat', phase2file2, 'userData');
    end
else
    userDataBackup = userData;
end

%% basic stats - should be on 50 not 59 PEOPLE - SELECT THE RIGHT PEOPLE
fprintf('\n');
fprintf('%20s\tz\tci\t\tp\tp bonf\n', 'Game');
fprintf('\n');
for iGame = 1:8
    stoufferZ = cellfun(@(x)x(iGame), {userDataBackup.z});
    [ci,p] = mybootci(stoufferZ);
    %[h,p] = ttest(stoufferZ, 0);
    fprintf('%20s\t%1.2f\t%1.2f to %1.2f\t%1.4f\t%1.4f\n', games{iGame,1}, mean(stoufferZ), ci(1), ci(2), p, min(p*8,1))
end
stoufferZ = [userDataBackup.stoufferz];
[ci,p] = mybootci(stoufferZ);
fprintf('Stouffer z global (n=%d)\t%1.2f\t%1.2f to %1.2f\t%1.4f\t%1.4f\n', length(stoufferZ), mean(stoufferZ), ci(1), ci(2), p)
fprintf('\n');
fprintf('\n');

% %% basic stats - should be on 50 not 59 PEOPLE - SELECT THE RIGHT PEOPLE
for iGame = 1:8
    stoufferZ = cellfun(@(x)x(iGame), {userData.z});
    [ci,p] = mybootci(stoufferZ);
    %[h,p] = ttest(stoufferZ, 0);
    fprintf('%20s\t%1.2f\t%1.2f to %1.2f\t%1.4f\t%1.4f\n', games{iGame,1}, mean(stoufferZ), ci(1), ci(2), p, min(p*8,1))
end
stoufferZ = [userData.stoufferz];
[ci,p] = mybootci(stoufferZ);
fprintf('Stouffer z selected (n=%d)\t%1.2f\t%1.2f to %1.2f\t%1.4f\n', length(stoufferZ), mean(stoufferZ), ci(1), ci(2), p)
fprintf('\n');

% get first game performance
% for iDat = 1:length(userData)
%     userData(iDat).remotewz = userData(iDat).z2(1);
% end
userData2 = userData; % replace here by userDataOri to perform stats over all people
userData2 = rmfield(userData2, {'userinfo', 'data', 'z', 'keep'});
try, userData2 = rmfield(userData2, {'phase', 'data2', 'stoufferz2', 'z2'}); catch, end
userDataTable = struct2table(userData2);
userDataTable(cellfun(@isempty, userDataTable.meditate),:) = [];
userDataTable(cellfun(@isnan  , userDataTable.meditate),:) = [];
userDataTable.meditate = categorical(cellfun(@num2str, userDataTable.meditate, 'uniformoutput', false));
userDataTable.paranormalbelief     = celltomat(userDataTable.paranormalbelief);
userDataTable.paranormalexperience = celltomat(userDataTable.paranormalexperience);
userDataTable.extraversion         = celltomat(userDataTable.extraversion);
userDataTable.agreeableness        = celltomat(userDataTable.agreeableness);
userDataTable.conscientiousness    = celltomat(userDataTable.conscientiousness);
userDataTable.neuroticism          = celltomat(userDataTable.neuroticism);
userDataTable.openness             = celltomat(userDataTable.openness);
userDataTable.cloninger            = celltomat(userDataTable.cloninger);

glme = fitglm(userDataTable,'stoufferz ~ 1 + meditate + paranormalbelief + paranormalexperience + extraversion + agreeableness + conscientiousness + neuroticism + openness + cloninger','Distribution','Normal');
glme 
residuals = glme.Residuals.Raw;
residuals(isnan(residuals)) = [];
[h, pValue] = lillietest(residuals);
fprintf('Normality: %s\n', fastif(h, 'reject', 'accept'));
return

% commands to dump data for each user on the new server
%
% mysqldump --tz-utc=false --no-create-info -u ions -pctJh84M7P idl users --where="userid='71b2ab46f5'" >> testtmp.sql
% fprintf("insert into userprogress (userid, game_name) values ('71b2ab46f5','remote_viewing');" >> testtmp.sql
% fprintf("insert into userprogress (userid, game_name) values ('71b2ab46f5', 'long_remote_viewing');" >> testtmp.sql
% fprintf("insert into userprogress (userid, game_name) values ('71b2ab46f5', 'location');" >> testtmp.sql
% fprintf("insert into userprogress (userid, game_name) values ('71b2ab46f5', 'bubbles');" >> testtmp.sql
% fprintf("insert into userprogress (userid, game_name) values ('71b2ab46f5', 'card');" >> testtmp.sql
% fprintf("insert into userprogress (userid, game_name) values ('71b2ab46f5', 'sequential_card');" >> testtmp.sql
% fprintf("insert into userprogress (userid, game_name) values ('71b2ab46f5', 'card_draw');" >> testtmp.sql
% fprintf("insert into userprogress (userid, game_name) values ('71b2ab46f5', 'lottery');" >> testtmp.sql

    