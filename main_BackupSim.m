%{
node_fail_prob = get_node_failure_prob(core_list,G_HEMP_memphis);
node_fail_prob(node_fail_prob<1e-4) = 1e-4;

%reliable backup path
flags = zeros(length(all_pairs),1);
for i=1:size(all_pairs,1)
    adj_temp = adj_mtx_wrl_unweighted;
    %clear out the shortest path nodes
    if length(shortest_ps(i).p)==2
       %disable the link
       adj_temp(shortest_ps(i).p(1),shortest_ps(i).p(2))=0;
       adj_temp(shortest_ps(i).p(2),shortest_ps(i).p(1))=0;
    else
      for j=2:length(shortest_ps(i).p)-1
	adj_temp(shortest_ps(i).p(j),:) = 0;
	adj_temp(:,shortest_ps(i).p(j)) = 0;
      end
    end

    %find the reliable backup
    [dist,backup_relia_ps(i).p] = ...
    dij_wProbFail(adj_temp,all_pairs(i,1),all_pairs(i,2),...
		  0,1,node_fail_prob);
    if isinf(dist)
       flags(i) = 1;
    end    
end

%flag the uninteresting backup (relia = baseline)
for i=1:size(all_pairs,1)
    if flags(i)==0 && ...
       length(backup_relia_ps(i).p)==length(backup_2ndsp_ps(i).p)
       if sum(backup_relia_ps(i).p==backup_2ndsp_ps(i).p)==length(backup_relia_ps(i).p)
	 flags(i) = 1;
       end
    end
end

%selected pairs
interesting_pairs = all_pairs(flags==0,:);
shortest_ps_sel = shortest_ps(flags==0);
backup_2ndsp_ps_sel = backup_2ndsp_ps(flags==0);
backup_relia_ps_sel = backup_relia_ps(flags==0);
BASELINE.backup_ps = backup_2ndsp_ps_sel;
%}
%do a simulation with interesting pairs
NUM_SIM = 300;
[RELIA_MET, BASELINE_MET] = ...
backup_protection_sim(core_list,[],[],adj_mtx_wrl_unweighted,...
		      interesting_pairs,shortest_ps_sel,...
		      backup_relia_ps_sel,BASELINE,...
		      G_HEMP_memphis,NUM_SIM,0);

%{
%output the important measures


%find an illustrative figure

%first, get the path length diff 
%this indicates if the relia backup is 'long'
count = 0;
max_diff = 0;
for i=1:size(interesting_pairs,1)
  %diff i.t.o. hop count, -2 for source and sink
  temp_diff = ...
  length(backup_relia_ps_sel(i).p)-length(backup_2ndsp_ps_sel(i).p)-2;
  if temp_diff>max_diff
     max_diff = temp_diff;
     temp_index = i;
  end
  if temp_diff>=5
    count = count+1;
    ill_candidate(count) = i;
  end
end

%what is the instance of this pair peformance?
BASELINE_temp = struct;
BASELINE_temp.backup_ps = BASELINE.backup_ps(temp_index);
[RELIA_MET_ins BASELINE_MET_ins] = ...
backup_protection_sim(core_list,[],[],...
		      adj_mtx_wrl_unweighted,...
		      interesting_pairs(temp_index,:),...
		      shortest_ps_sel(temp_index),...
		      backup_relia_ps_sel(temp_index),...
		      BASELINE_temp,G_HEMP_memphis,NUM_SIM,0);

%plot the max diff backups
plot_backups(core_list,[],adj_mtx_wrl_unweighted,...
	     shortest_ps_sel(temp_index).p,...
	     backup_relia_ps_sel(temp_index).p,...
	     backup_2ndsp_ps_sel(temp_index).p,...
	     G_HEMP_memphis.ground_zero,0);
%}
