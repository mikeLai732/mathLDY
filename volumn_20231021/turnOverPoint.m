function output = turnOverPoint(input, interval)
output = [];
scan = 1:interval:length(input);
if mod(length(scan)-1, 2) == 0
    w = 1:1:(length(scan)-1)/2;
    w = [w, fliplr(w)];
else
    w = 1:1:ceil((length(scan)-1)/2);
    w = [w, w(end)+1, fliplr(w)];
end
for i = 2:length(scan)
    output = [output w(i-1)*(input(scan(i))-input(scan(i-1)))/(scan(i)-scan(i-1))];
end
end