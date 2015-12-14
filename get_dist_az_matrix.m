function [adj_mtx az_mtx] = get_dist_az_matrix(core_list)

N = size(core_list,1);
az_mtx = zeros(N,N);
adj_mtx = zeros(N,N);
for i=1:size(core_list,1)-1
	for j=i+1:size(core_list,1)
		[temp_dist temp_az] = distance(core_list(i,2),core_list(i,1),core_list(j,2),core_list(j,1));
		az_mtx(i,j) = temp_az;
		adj_mtx(i,j) = deg2nm(temp_dist);
		adj_mtx(j,i) = adj_mtx(i,j);
		%not used
		%az_mtx(j,i) = distance(core_list(j,2),core_list(j,1),core_list(i,2),core_list(i,1));
	end
end
