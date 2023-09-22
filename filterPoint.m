function output = filterPoint(intputData)
diffData = abs(diff(intputData));
% figure(1)
% clf(figure(1))
% subplot(211)
% plot(diffData)
ind = find(diffData > sum(diffData(round(length(intputData)*0.2):round(length(intputData)*0.8)))*3);
intputData(ind+1) = [];
% diffIDX = diff(ind);
% ind1 = find(diffIDX > 100);
% delE = ind(ind1);
% delS = ind(ind1+1);
% intputData(delS:end) = [];
% intputData(1:delE) = [];
output = intputData;
% subplot(212)
% plot(output)
end