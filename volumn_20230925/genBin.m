% name = inputdlg('����������ļ�����');
fid=fopen([name{1},'.bin'],'wb');
fwrite(fid, D','uint16');
fclose(fid);