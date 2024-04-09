
res = readtable('IDL GotPsi 10_21_21 to 1_17_24.xlsx')

fieldtmp = 'bubble_baseline_mean';
values = str2double(res.(fieldtmp));
allUsers = res.Userid;

count = 0;
for iUser = 1:length(userDataOri)

    if ~isempty(userDataOri(iUser).bubble_attention_mean)
        [val,ind2] = min(abs(values - userDataOri(iUser).(fieldtmp)));
        [ind] = strmatch(userDataOri(iUser).userid, allUsers, 'exact');
        if val < 0.0000000001
            count = count+1;
            if length(ind) >= 1
                fprintf('Found all %s\n', userDataOri(iUser).userid )
            else
                fprintf('Found bubles %s vs %s\n', userDataOri(iUser).userid , allUsers{ind2} )
            end
        else
            if length(ind) >= 1
                fprintf('Found id %s\n', userDataOri(iUser).userid )
            else
                fprintf('Not found %s\n', userDataOri(iUser).userid )
                count = count+1;
            end
        end
    end

end

fprintf('Number not found %d/%d\n', count, length(userDataOri))

% Number not found 896/1014


