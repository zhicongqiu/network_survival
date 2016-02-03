function [node_fail_prob] = get_node_failure_prob(core_list,HEMP)

N = size(core_list,1);
node_fail_prob = zeros(N,1);
for i=1:N
    [temp_dist temp_az] = ...
    lon_lat_dist(HEMP.ground_zero(1),HEMP.ground_zero(2),...
		 core_list(i,1),core_list(i,2));

    %excluding too faraway node
      %p-value associated with x and y
      temp_prob = normcdf(temp_dist,0,HEMP.std);
      if temp_prob<0.5
	temp_prob = 2*temp_prob;
      else
	temp_prob = 2*(1-temp_prob);
      end
      node_fail_prob(i) = temp_prob;
end
