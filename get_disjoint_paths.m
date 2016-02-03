function [num_paths hop_count] = ...
	 get_disjoint_paths(adj_mtx,source,sink)
  %function [num_paths hop_count] = get_disjoint_paths(adj_mtx,source,sink)
  %get number of node-disjoint paths and hop_count for each path

  count = 0;
  while true
    [d,P] = dijkstra(adj_mtx,source,sink);
    if d==inf
       num_paths = count;
       break;
    else
	count = count+1;
	hop_count(count) = length(P)-1;
	%node disjoint
	if length(P)>2
	  for i=2:length(P)-1
	    adj_mtx(P(i),:) = 0;
	    adj_mtx(:,P(i)) = 0;
	  end
	else
	    %it is directed connected, no backup paths are used for now?
	    %delete the direct link btw source and sink
	    %adj_mtx(P(1),P(2)) = 0;
	    %adj_mtx(P(2),P(1)) = 0;
	    num_paths = count;
	    break;
	end
    end
  end
