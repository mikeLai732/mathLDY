%% RANSAC
function output = RANSAC(oY, oZ, th, ax)
maxLen = 0;
output = [];
for iter = 1:50
    randIDX = randperm(length(oY), 2);
    k = (oZ(randIDX(2))-oZ(randIDX(1)))/(oY(randIDX(2))-oY(randIDX(1)));
    b = oZ(randIDX(2)) - k*oY(randIDX(2));
    oZfit = k*oY + b;
    
    disP2L = abs(k*oY-oZ+b)/sqrt(k^2+1);
    ind = find(disP2L < th);
    if length(ind) > maxLen
        output = [k b];
        maxLen = length(ind);
%         figure(8);
%         clf(figure(8))
%         plot(oY, oZ, '.')
%         hold on
%         plot(oY, oZfit, '.')
%         if strcmpi(ax, 'yz')
%             xlabel('Y')
%             ylabel('Z')
%         elseif strcmpi(ax, 'xz')
%             xlabel('X')
%             ylabel('Z')
%         elseif strcmpi(ax, 'xy')
%             xlabel('X')
%             ylabel('Y')
%         end
%         axis image
%         drawnow()
%         pause(0.2)
    end
end
end
