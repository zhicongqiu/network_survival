function [num_paths ALL_PATHS] = get_disjoint_paths_all(adj_mtx)

  ALL_PATHS = struct;
  count = 0;
  for i=1:size(adj_mtx,1)-1
    for j=i+1:size(adj_mtx,1)
      count = count+1;
      [ALL_PATHS(count).num_path ALL_PATHS(count).hop_count] =...
      get_disjoint_paths(adj_mtx,i,j);
      num_paths(count) = ALL_PATHS(count).num_path;
      ALL_PATHS(count).pairs = [i j];
    end
  end
