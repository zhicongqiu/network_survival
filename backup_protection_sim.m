function [PAIRS_METRICS BASELINE_METRICS] = ...
	 backup_protection_sim(GRAPH,rep_link,rep_list,ADJ,...
			       pairs,shortest_ps,backup_ps,...
			       BASELINE,HEMP,NUM,use_repeater)

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
%use_repeater - 0 if not using
%OUTPUT:
%not decided?
  num_pairs = size(pairs,1);
  PAIRS_METRICS = zeros(num_pairs,6);
  for i=1:length(BASELINE)
    BASELINE_METRICS(i).PAIRS_METRICS = zeros(num_pairs,6);
  end
  for i=1:NUM
    fprintf('this is %d iteration\n',i);
    %post attack graph
    %initialize GRAPH and ADJ post-attack
    ADJ_post = ADJ;
    survived_nodes_indicator = zeros(1,size(GRAPH,1));
    %getting survival and failed nodes
    [survive_nodes failed_nodes count_survived count_failed] = ...
    generate_failures(GRAPH,HEMP,'gaussian');
    fail_node_count(i) = count_failed;
    
    if use_repeater==1
      %get failed repeaters index, and hence failed links
      [survived_repeaters failed_repeaters count_survived count_failed] = ...
      generate_failures(rep_list,HEMP,'gaussian');
      fail_repeater_count(i) = count_failed;
      if size(failed_repeaters,1)>0
	for j=1:size(failed_repeaters,1) %link failures
	  ADJ_post(rep_link(failed_repeaters(j),1),...
		   rep_link(failed_repeaters(j),2)) = 0;
	  ADJ_post(rep_link(failed_repeaters(j),2),...
		   rep_link(failed_repeaters(j),1)) = 0;
	end
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
	temp = calculate_backup_survive(ADJ_post,shortest_ps(j).p);
	%primary survived
	if temp==true
          PAIRS_METRICS(j,2) = PAIRS_METRICS(j,2)+1;
	else %primary failed
	  PAIRS_METRICS(j,3) = PAIRS_METRICS(j,3)+1;

	  isBackupConnected = false;
	  %out of connected pairs, are backup paths survived?
	  temp(1) = calculate_backup_survive(ADJ_post,backup_ps(j).p);
	  if temp(1)==true
	    isBackupConnected = true;
	    %primary failed, but backup survived
	    PAIRS_METRICS(j,5) = PAIRS_METRICS(j,5)+1;
	  end
	  for k=1:length(BASELINE)
	    temp(k+1) = calculate_backup_survive(ADJ_post,BASELINE(k).backup_ps(j).p);
	    if temp(k+1)==true
	      isBackupConnected = true;
	      %primary failed, but backup survived
	      BASELINE_METRICS(k).PAIRS_METRICS(j,5) = ...
	      BASELINE_METRICS(k).PAIRS_METRICS(j,5)+1;
	    end
	  end
	  if isBackupConnected == true
	    %the pairs are connected post attack
	    PAIRS_METRICS(j,4) = PAIRS_METRICS(j,4)+1;
	    %the pairs are connected post attack but backup failed
	    for k=1:length(temp)
	      if temp(k)==false
		if k==1
		  PAIRS_METRICS(j,6) = PAIRS_METRICS(j,6)+1;
		else
		  BASELINE_METRICS(k-1).PAIRS_METRICS(j,6) = ...
		  BASELINE_METRICS(k-1).PAIRS_METRICS(j,6)+1;
		end
	      end
	    end  
	  else %none of the backup survived, is the node connected?
	    %check if the pairs are connected:  use simple dijkstra
	    temp_dist = ...
	    simpleDijkstra(ADJ_post,pairs(j,1));   

	    if ~isinf(temp_dist(pairs(j,2))) %the pairs are connected post attack
	      PAIRS_METRICS(j,4) = PAIRS_METRICS(j,4)+1;
	      %all the backup failed
	      for k=1:length(temp)
		if k==1
		  PAIRS_METRICS(j,6) = PAIRS_METRICS(j,6)+1;
		else
		  BASELINE_METRICS(k-1).PAIRS_METRICS(j,6) = ...
		  BASELINE_METRICS(k-1).PAIRS_METRICS(j,6)+1;
		end
	      end
	    end 
	  end
  
	end
      end
    end
  end
