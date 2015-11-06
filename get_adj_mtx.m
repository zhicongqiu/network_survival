function [adj_mtx] = get_adj_mtx(id_list,adj_list,dist_mtx,no_list)

%%%%%%%%%%%%%%%%%%%%
%input:
%id_list: node id, not used if there is no id
%adj_list: edge list
%dist_mtx: n-by-n distance matrix between pair of nodes
%output:
%n-by-n adjacency matrix

%%
N = size(id_list,1);
adj_mtx = zeros(N,N);
%loop through all links
for i=1:size(adj_list,1)
	if no_list==false
		temp_1 = find(id_list==adj_list(i,1));
		temp_2 = find(id_list==adj_list(i,2));
	else
		fprintf('no id list is used, assume one-to-one node correspondence...\n');
		temp_1 = adj_list(i,1);
		temp_2 = adj_list(i,2);
	end
	if adj_mtx(temp_1,temp_2)==0
		adj_mtx(temp_1,temp_2) = dist_mtx(temp_1,temp_2);
		adj_mtx(temp_2,temp_1) = adj_mtx(temp_1,temp_2);
	else
		fprintf('repeated links btw %d and %d? at %d th iteration\n',temp_1,temp_2,i);
	end
end