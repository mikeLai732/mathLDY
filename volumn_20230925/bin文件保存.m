name = inputdlg('输入二进制文件命名');
fid=fopen([name{1},'.bin'],'wb');
fwrite(fid, D','uint16');
fclose(fid);

% fid = fopen('empty.bin', 'r');
% c = fread(fid, 480*640, 'uint16');
% fclose(fid);
% 
% c = reshape(c, 640, 480)';
% figure(1)
% imagesc(c)
% axis image
% colormap jet
% set(gca, 'CLim', [0 4500])
