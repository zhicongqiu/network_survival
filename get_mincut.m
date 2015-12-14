function [min_cut_num] = get_mincut(adj_mtx,source,sink)
  %get the min cut of the source and sink
  count = 0;
  while true
    [d,P] = dijkstra(adj_mtx,source,sink);
    if d==inf
       min_cut_num = count;
       break;
    else
	count = count+1;
	for i=1:length(P)-1
	    adj_mtx(P(i),P(i+1)) = 0;
	    adj_mtx(P(i+1),P(i)) = 0;
	end
    end
  end
