name = inputdlg(' ‰»Î∂ØÕº√¸√˚');
for f = 1:6
    fid = fopen(['box', num2str(f),'.bin'], 'r');
    box = fread(fid, 480*640, 'uint16');
    fclose(fid);
    box = reshape(box, 640, 480)';
    outputXYZ.box = calcPC(box, LV_J, -41);
    axis off
    
    fr = getframe(figure(5));
    im = frame2im(fr);
    [A, map] = rgb2ind(im, 256);
    if f == 1
        imwrite(A, map, [name{1}, '.gif'], 'LOOPCOUNT', Inf, 'DelayTime', 0.4);
    elseif f < 6
        imwrite(A, map, [name{1}, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 0.4);
    else
        imwrite(A, map, [name{1}, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 5);
    end
end