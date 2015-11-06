function [hi_affected_nodes low_affected_nodes] = get_affected(node_list,HEMP,attack_mode)
	
	count_affected_hi = 0;
	count_affected_low = 0;
	hi_affected_nodes = [];
	low_affected_nodes = [];
	for i=1:size(node_list,1)
		[temp_dist temp_az] = lon_lat_dist(HEMP.ground_zero(1),HEMP.ground_zero(2),node_list(i,1),node_list(i,2));
		if attack_mode~='simple'
			if temp_dist<=HEMP.range
				count_affected = count_affected+1;
				hi_affected_nodes(count_affected) = i;
			end
		
		%a sampler model
		else
			if temp_dist<=HEMP.high_limit&&temp_dist>=HEMP.low_limit
				count_affected_low = count_affected_low+1;
				low_affected_nodes(count_affected_low) = i;		
			elseif temp_dist<HEMP.low_limit
				count_affected_hi = count_affected_hi+1;
				hi_affected_nodes(count_affected_hi) = i;		
			end			
		end				
	end	
	fprintf('%d nodes are highly affected and %d nodes are lowly affected.\n',count_affected_hi,count_affected_low);