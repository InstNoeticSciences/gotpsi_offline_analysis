clear
%datestr = '2022-06-22';
datestr = datestr(now, 'YYYY-mm-DD') 

users            = readtable(['data/sql_userslog' datestr '.txt']);
data             = readtable(['data/sql_rvresponse' datestr '.txt'],'Format','auto');
imgs             = readtable(['data/sql_rvimages' datestr '.txt']);
hall_of_fame_day = readtable(['data/sql_hall_of_fame_day' datestr '.txt']);

uniqueUsers = unique(data.userid);
tmpData = data;

%%
for iRow = size(tmpData,1):-1:1
    % compute
    selectedTrial = tmpData(iRow,:);

    %
    nim = size(imgs,1)+1;
    for iImg = 1:size(imgs,1)

        arr1 = selectedTrial;
        arr2 = imgs(iImg,:);

        sum = 0;
        sum = sum + (abs(arr1.srounded - arr2.srounded) * 2);
        sum = sum + (abs(arr1.sangular - arr2.sangular) * 2);
        sum = sum + (abs(arr1.slinear - arr2.slinear) * 2);
        sum = sum + (abs(arr1.spoints - arr2.spoints) * 2);
        sum = sum + (abs(arr1.ssoft - arr2.ssoft) * 2);
        sum = sum + (abs(arr1.srepeated - arr2.srepeated) * 2);

        sum = sum + fastif(abs(arr1.water - arr2.water) > 2,  2 , abs(arr1.water - arr2.water));
        sum = sum + fastif(abs(arr1.people - arr2.people) > 2,  2 , abs(arr1.people - arr2.people));
        sum = sum + fastif(abs(arr1.plants - arr2.plants) > 2,  2 , abs(arr1.plants - arr2.plants));
        sum = sum + fastif(abs(arr1.food - arr2.food) > 2,  2 , abs(arr1.food - arr2.food));
        sum = sum + fastif(abs(arr1.animals - arr2.animals),  2 , abs(arr1.animals - arr2.animals));
        sum = sum + fastif(abs(arr1.temperature - arr2.temperature),  2 , abs(arr1.temperature - arr2.temperature));
        sum = sum + fastif(abs(arr1.scenetype - arr2.scenetype),  2 , abs(arr1.scenetype - arr2.scenetype));
        sum = sum + fastif(abs(arr1.movement - arr2.movement),  2 , abs(arr1.movement - arr2.movement));
        sum = sum + fastif(abs(arr1.location - arr2.location),  2 , abs(arr1.location - arr2.location));

        allSums(iImg) = sum;
    end
    clear sum;

    if iscell(selectedTrial.imgname) selectedTrial.imgname = selectedTrial.imgname{1}; end
    targetImg = strcmp( imgs.name, num2str(selectedTrial.imgname));
    count = sum(allSums(targetImg) >= allSums )+1;
    score = count/nim*100;
    z     = norminv(score/100);

    fprintf('%s', selectedTrial.userid{1});
    if abs(z-selectedTrial.z) > 0.005
        fprintf(' z=%1.6f vs z(database)=%1.6f\n', z, selectedTrial.z);
        %error('Wrong number of hits')
    else
        fprintf(' ok\n');
    end
end

