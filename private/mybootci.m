function [ci, p] = mybootci(data)

    naccu = 10000;
    [ci,bs] = bootci(naccu, {@mean data}, 'type', 'per');
    bs(end+1) = 0;
    [~,ind] = sort(bs);
    pos = find(ind == naccu+1);
    p   = pos/naccu;