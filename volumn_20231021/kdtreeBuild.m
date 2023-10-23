function kdtree = kdtreeBuild(data)
kdtree = [];
kdtree_iter(data, []);
 % �ݹ��Ӻ���
    function index_cur = kdtree_iter(data_cur, index)
        index_cur = [];
        if size(data_cur, 1) == 0 %�������֧���������ݣ���ֱ�ӷ��أ��ݹ����
            return
        end
        index_cur = length(kdtree) + 1;
        varData = var(data_cur, 0, 1);
        [~, maxDim] = max(varData);
        data_cur = sortrows(data_cur, maxDim);
        leftbranch = data_cur(1:ceil(size(data_cur,1)/2)-1, :);
        rightbranch = data_cur(ceil(size(data_cur,1)/2)+1:end, :);
        kdtree(index_cur).split = maxDim;
        kdtree(index_cur).value = data_cur(ceil(size(data_cur,1)/2), :);
        kdtree(index_cur).parent = index;
        kdtree(index_cur).left = kdtree_iter(leftbranch, index_cur);
        kdtree(index_cur).right = kdtree_iter(rightbranch, index_cur);
    end
end