function [RELIA_METS,BASELINE_METS,interesting_pairs,backup_relia_ps] = ...
	 BackupSim_pickAlpha(core_list,adj_mtx,shortest_ps,...
			     backup_2ndsp_ps,G_HEMP,...
			     all_pairs,node_fail_prob,alpha,NUM_SIM)

%reliable backup path
flags = zeros(length(all_pairs),1);
for i=1:size(all_pairs,1)
    adj_temp = adj_mtx;
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
		  alpha,1,node_fail_prob);
    if isinf(dist)
       flags(i) = 1;
    end    
end

%flag the uninteresting backup (relia = baseline)
for i=1:size(all_pairs,1)
    if flags(i)==0 && ...
       length(backup_relia_ps(i).p)==length(backup_2ndsp_ps(i).p)
       if sum(backup_relia_ps(i).p==backup_2ndsp_ps(i).p)==...
	  length(backup_relia_ps(i).p)
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

%do a simulation with interesting pairs
%NUM_SIM = 200;
RELIA_METS = struct;
BASELINE_METS = struct;
[RELIA_METS.MET, BASELINE_METS.MET] = ...
backup_protection_sim(core_list,[],[],adj_mtx,...
		      interesting_pairs,shortest_ps_sel,...
		      backup_relia_ps_sel,BASELINE,...
		      G_HEMP,NUM_SIM,0);

%{
BASELINE_METS.p = ...
BASELINE_METS.MET.PAIRS_METRICS(RELIA_METS.MET(:,4)~=0,5)./...
RELIA_METS.MET(RELIA_METS.MET(:,4)~=0,4);

RELIA_METS.p = ...
RELIA_METS.MET(RELIA_METS.MET(:,4)~=0,5)./...
RELIA_METS.MET(RELIA_METS.MET(:,4)~=0,4);
%}
