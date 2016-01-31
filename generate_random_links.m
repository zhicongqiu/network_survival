function [adj_mtx_new count_links count_affected] = generate_random_links(idx,core_list,radius,num_links,len_lim,adj_mtx_old)

#function [adj_mtx_new] = generate_random_links(idx_list,adj_mtx_old)
#generate random links between nodes
#input:
#idx: HEMP attack location
#core_list: geo-location of different nodes
#radius: within which we add random links from (add nodes too??? not
#decided)
#num_links: number of links needed to generate (uniformly randomly
#len_lim: longest link limit
#among all affected nodes)
#adj_mtx_old: original adjacency matrix
#####
#output:
#adj_mtx_new: modified adj matrix
#####

  count_affected = 0;
  for i=1:size(core_list,1)
    [temp_dist,~] = lon_lat_dist(core_list(idx,1),core_list(idx,2),core_list(i,1),core_list(i,2));
    if temp_dist<=radius
	count_affected = count_affected+1;
	affected_nodes(count_affected) = i;		
    end						
  end

  N = length(affected_nodes);
  count_links = 0;
  adj_mtx_new = adj_mtx_old;
  while count_links<num_links
	i = randi(N);
	j = randi(N);
	if i~=j && adj_mtx_new(affected_nodes(i),affected_nodes(j))==0
	   temp_dist = lon_lat_dist(core_list(affected_nodes(i),1),...
				    core_list(affected_nodes(i),2),...
				    core_list(affected_nodes(j),1),...
				    core_list(affected_nodes(j),2));
	   if temp_dist<len_lim
	     adj_mtx_new(affected_nodes(i),affected_nodes(j)) = temp_dist;
	     adj_mtx_new(affected_nodes(j),affected_nodes(i)) = temp_dist;
	     count_links = count_links+1;	
	   end
	end
  end
	   
