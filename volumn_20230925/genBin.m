% name = inputdlg('输入二进制文件命名');
fid=fopen([name{1},'.bin'],'wb');
fwrite(fid, D','uint16');
fclose(fid);