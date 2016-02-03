function [METRICS] = backup_protection_sim(GRAPH,rep_link,rep_list,ADJ,...
					   pairs,shortest_ps,backup_ps,...
					   HEMP,NUM)

%function [METRICS] = backup_protection_sim(GRAPH,rep_link,rep_list,ADJ,...
%					   pairs,shortest_p,backup_p,...
%					   HEMP,NUM)
%INPUT:
%GRAPH - node x,y locations
%rep_link - repeater links
%rep_list - repeater x,y location
%ADJ - adjacency matrix
%pairs - pairs of interested node, i.e., nodes within std of HEMP
%shortest_p - precomputed shortest paths for each pair
%backup_p - precomputed backup paths for each pair
%HEMP - HEMP model (gaussian HEMP attack)
%NUM - number of MC sampling to the HEMP attack
%OUTPUT:
%not decided?
  num_pairs = size(pairs,1);
  PAIR_MATRICS = zeros(size(num_pairs,4);
  for i=1:NUM
    survived_nodes_indicator = zeros(1,size(GRAPH,1));
    %getting survival and failed nodes
    [survive_nodes failed_nodes count_survived count_failed] = ...
    generate_failures(GRAPH,HEMP,'gaussian');
    fail_node_count(i) = count_failed;

    %get failed repeaters index, and hence failed links
    [survived_repeaters failed_repeaters count_survived count_failed] = ...
    generate_failures(rep_list,HEMP,'gaussian');
    fail_repeater_count(i) = count_failed;
    %post attack graph
    %initialize GRAPH and ADJ post-attack
    ADJ_post = ADJ;
    ADJ_failed = ADJ;
    GRAPH_post = GRAPH;
    GRAPH_failed = GRAPH;
    index4post = index4original;
    if size(failed_repeaters,1)>0
      for j=1:size(failed_repeaters,1) %link failures
	ADJ_post(rep_link(failed_repeaters(j),1),rep_link(failed_repeaters(j),2)) = 0;
	ADJ_post(rep_link(failed_repeaters(j),2),rep_link(failed_repeaters(j),1)) = 0;
      end
    end
    %node failure
    ADJ_post(failed_nodes,:) = 0;
    ADJ_post(:,failed_nodes) = 0;

    survived_nodes_indicator(survive_nodes) = 1;
    %check which pairs have survived
    for j=1:num_pairs
      if survived_nodes_indicator(pairs(j,1))==1&&...
	 survived_nodes_indicator(pairs(j,2))==1
	PAIRS_METRICS(j,1) = PAIRS_METRICS(j,1)+1;
	%check if the primary survived
	temp = true
	for k=1:length(shortest_ps(j).p)-1
          if ADJ_post(shortest_ps(j).p(k),shortest_ps(j).p(k+1))==0
	    %primary failed
            PAIRS_METRICS(j,3) = PAIRS_METRICS(j,3)+1;
	    temp = false;
	    break;
	  end
	end
	%primary survived
	if temp==true
          PAIRS_METRICS(j,2) = PAIRS_METRICS(j,2)+1;
	else
	  temp2 = true;
	  for k=1:length(backup_ps)
	    if ADJ_post(backup_ps(j).p(k),backup_ps(j).p(k+1))==0
	      PAIRS_METRICS(j,5) = PAIRS_METRICS(j,5)+1;
	      temp2 = false;
	      break;
	    end
	  end
	  if temp2==true
	    PAIRS_METRICS(j,4) = PAIRS_METRICS(j,4)+1;
	  end
	end
      end
    end
  end
