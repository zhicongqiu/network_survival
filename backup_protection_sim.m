function [PAIRS_METRICS BASELINE_METRICS] = ...
	 backup_protection_sim(GRAPH,rep_link,rep_list,ADJ,...
			       pairs,shortest_ps,backup_ps,...
			       BASELINE,HEMP,NUM)

%function [METRICS] = backup_protection_sim(GRAPH,rep_link,rep_list,ADJ,...
%					   pairs,shortest_ps,backup_ps,...
%					   BASELINE,HEMP,NUM)
%INPUT:
%GRAPH - node x,y locations
%rep_link - repeater links
%rep_list - repeater x,y location
%ADJ - adjacency matrix
%pairs - pairs of interested node, i.e., nodes within std of HEMP
%shortest_p - precomputed shortest paths for each pair
%backup_p - precomputed backup paths for each pair
%BASELINE - an struct array containing baseline of interest (e.g., 2nd
%nd shortest ps, etc.)
%HEMP - HEMP model (gaussian HEMP attack)
%NUM - number of MC sampling to the HEMP attack
%OUTPUT:
%not decided?
  num_pairs = size(pairs,1);
  PAIRS_METRICS = zeros(num_pairs,6);
  for i=1:length(BASELINE)
    BASELINE_METRICS(i).PAIRS_METRICS = zeros(num_pairs,6);
  end
  for i=1:NUM
    survived_nodes_indicator = zeros(1,size(GRAPH,1));
    %getting survival and failed nodes
    [survive_nodes failed_nodes count_survived count_failed] = ...
    generate_failures(GRAPH,HEMP,'gaussian');
    fail_node_count(i) = count_failed;
    
%{
    %get failed repeaters index, and hence failed links
    [survived_repeaters failed_repeaters count_survived count_failed] = ...
    generate_failures(rep_list,HEMP,'gaussian');
    fail_repeater_count(i) = count_failed;
%}
    %post attack graph
    %initialize GRAPH and ADJ post-attack
    ADJ_post = ADJ;
    ADJ_failed = ADJ;

%{
    if size(failed_repeaters,1)>0
      for j=1:size(failed_repeaters,1) %link failures
	ADJ_post(rep_link(failed_repeaters(j),1),rep_link(failed_repeaters(j),2)) = 0;
	ADJ_post(rep_link(failed_repeaters(j),2),rep_link(failed_repeaters(j),1)) = 0;
      end
    end
%}
    %node failure
    ADJ_post(failed_nodes,:) = 0;
    ADJ_post(:,failed_nodes) = 0;

    survived_nodes_indicator(survive_nodes) = 1;
    %check which pairs have survived
    for j=1:num_pairs
      if survived_nodes_indicator(pairs(j,1))==1&&...
	 survived_nodes_indicator(pairs(j,2))==1
	PAIRS_METRICS(j,1) = PAIRS_METRICS(j,1)+1;
	temp = calculate_backup_survive(ADJ_post,shortest_ps(j).p);
	%primary survived
	if temp==true
          PAIRS_METRICS(j,2) = PAIRS_METRICS(j,2)+1;
	else
	  PAIRS_METRICS(j,3) = PAIRS_METRICS(j,3)+1;

	  %check if the pairs are connected
	  [temp_dist,~] = dijkstra(ADJ_post,pairs(j,1),pairs(j,2));

	  if ~isinf(temp_dist)
	    %the pairs are connected post attack
	    PAIRS_METRICS(j,4) = PAIRS_METRICS(j,4)+1;

	    %out of connected pairs, are backup paths survived?
	    temp = calculate_backup_survive(ADJ_post,backup_ps(j).p);
	    if temp==false %backup failed
	      PAIRS_METRICS(j,6) = PAIRS_METRICS(j,6)+1;
	    else %backup survived
	      PAIRS_METRICS(j,5) = PAIRS_METRICS(j,5)+1;
	    end
	    for k=1:length(BASELINE)
	      temp = calculate_backup_survive(ADJ_post,BASELINE(k).backup_ps(j).p);
	      if temp==false
		BASELINE_METRICS(k).PAIRS_METRICS(j,6) = ...
		BASELINE_METRICS(k).PAIRS_METRICS(j,6)+1;
	      else
		BASELINE_METRICS(k).PAIRS_METRICS(j,5) = ...
		BASELINE_METRICS(k).PAIRS_METRICS(j,5)+1;
	      end
	    end	 
	  end   
	end
      end
    end
  end
