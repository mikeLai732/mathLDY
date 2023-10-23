function [maxLen, maxCluster] = oneDCluster(diffLineUD)
cutUD = 1;
cutLen = 1;
maxCluster = [];
maxLen = 0;
for i = 2:length(diffLineUD)
    if abs(diffLineUD(i)-diffLineUD(i-1)) < 10 && diffLineUD(i) < max(diffLineUD)*0.5
        cutUD = [cutUD i];
        cutLen = cutLen + 1;
    else
        if cutLen > maxLen
            maxLen = cutLen;
            maxCluster = cutUD;
        end
        cutUD = i;
        cutLen = 1;
    end
end
end
