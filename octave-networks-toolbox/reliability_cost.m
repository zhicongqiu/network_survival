function [cost] = reliability_cost(s,target,u,v,beta,path,node_fail_prob)
%function [cost] = reliability_cost(s,target,v,path,node_fail_prob)
%s - source node 
%target - target node
%u - current node
%v - next node
%path - current path from s to u (pi)
%node_fail_prob - probability failure of each node (N*1)


  %initial cost
  if v==target
    cost = 0;
    return
  else
    cost = beta;
    if length(path)==1 %u is s
      cost = cost*node_fail_prob(v);
      return
    else
      for i=2:length(path)
	cost = cost*(1-node_fail_prob(path(i)));
      end
      if path(end)~=u
	disp(path)
	disp(u)
	disp(v)
	error('fatal error, exit immediately...');
      end
      cost = cost*node_fail_prob(v);
    end
    return
  end


