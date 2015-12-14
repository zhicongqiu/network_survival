function [min_cut_num sp] = get_mincut(adj_mtx,source,sink)
  %get the min cut of the source and sink
  count = 0;
  sp = inf;
  while true
    [d,P] = dijkstra(adj_mtx,source,sink);
    if d==inf
       min_cut_num = count;
       break;
    else
	count = count+1;
	if count==1
	   sp = d;
	end
	for i=1:length(P)-1
	    adj_mtx(P(i),P(i+1)) = 0;
	    adj_mtx(P(i+1),P(i)) = 0;
	end
    end
  end
