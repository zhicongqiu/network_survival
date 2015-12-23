function [num_pairwise] = get_pairwise_conn(adj)
  %get connected components post attack
  for i=1:size(adj,1)-1
    [sp(i,:)]=simpleDijkstra(adj,i);
  end
  num_pairwise = 0;
  for i=1:size(sp,1)-1
    for j=i+1:size(sp,1)
      if sp(i,j)>0&&~isinf(sp(i,j))
	num_pairwise = num_pairwise+1;
      end
    end
  end
num_pairwise = [num_pairwise num_pairwise/nchoosek(size(sp,1),2)];
