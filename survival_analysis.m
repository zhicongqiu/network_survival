function [METRICS] = survival_analysis(GRAPH,rep_link,rep_list,ADJ,...
				       CC_node,AC_node,shortest_p,mincut_mtx,...
				       HEMP,NUM,attack_mode)

%%%%%input%%%%%
%GRAPH: 2-D matrix: each row specifies a node's geo-location in
%(lon,lat)
%
%ADJ: weighted/unweighted network graph with same number of nodes as
%
%GRAPH, an adjacency matrix specifying connections between nodes
%
%rep_link: links associated with each repeater
%
%rep_list: repeater locations in (lon,lat), put to [] if no repeaters
%
%CC_node: node index to indicate Command and Control nodes, put to []
%if not used
%
%AC_node: node index to indicate Asset nodes, put to [] if not used
%
%HEMP: 
%a struct representing a HEMP attack scenario, there are several kinds of HEMP attacks:
%1)simple two-disk HEMP: 
%there should be 5 fields:
%ground_zero: (lon,lat) location of the ground-zero
%low_limit: low limit radius in nautical miles, in [0,low_limit] the prob. of node failure is near_prob
%near_prob: prob. of failure within the low_limit radius [0,1].
%high_limit: high limit radius in nautical miles, in [low_limit,high_limit] the prob. of node failure is within_prob
%within_prob: prob. of failure within the high_limit radius: [0,1]. 
%2)squared distance model HEMP:
%
%NUM: number of monte carlo trials
%
%attack_mode: simple to indicate simplied HEMP attack; otherwise, squared distance model HEMP
%
%%%%%%%%%%%%%%%%
%%%%%output%%%%%
%performance metrics in each random trials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
METRICS = struct;
N = size(GRAPH,1); %number of primary nodes
index4original = cumsum(ones(1,N));
%%%%%%%%%%%%%%%%%%%trivial cases:%%%%%%%%%%%%%%%%%%%%%%%%%%
if size(GRAPH,1)<=1
   fprintf('trivial graph with one node, return empty metrics.\n');
   return
end
if isempty(HEMP)
  METRICS.isConnected = 1*ones(1,NUM);
  METRICS.largest_comp = 1*ones(1,NUM);
  METRICS.num_comp = 1*ones(1,NUM);
  METRICS.avg_shortest = 0*ones(1,NUM);
  METRICS.avg_mincut = 0*ones(1,NUM);
  METRICS.file_node_count = 0*ones(1,NUM);
  METRICS.fail_repeater_count = 0*ones(1,NUM);  
  fprintf('no HEMP attack, return metrics with the whole network intact.\n');
  return
end

%%%%%%%%%%%%%%%%%%%initialization%%%%%%%%%%%%%%%%%%%%%%%%%%
%put AC and CC nodes in sorted order index
if length(CC_node)>1
  CC_node = sort(CC_node);
end
if length(AC_node)>1
  AC_node = sort(AC_node);
end

%index for original GRAPH
%index4original = cumsum(ones(1,N));
sim_count = 0;

%plot the original graph
%plot_affected(GRAPH,ADJ,HEMP,attack_mode);
%global GRAPH rep_id rep_list ADJ CC_node AC_node shortest_p HEMP;
%{
Idx = 1:NUM;
[isConnected largest_comp num_comp avg_shortest]  = ...
ndpar_arrayfun(nproc,@parallel_survival_analysis,attack_mode,index4original,Idx,...%
				    'Vectorized', false, 'ChunksPerProc',(NUM/nproc),...
				    'VerboseLevel', 1,'IdxDimensions', ...
				    [0 0 2],'CatDimensions', [2 2 2 2]);

%}

%%%%%%%%%%%%%%%%%%%%%begin NUM simulations%%%%%%%%%%%%%%%%%
while sim_count<NUM
	sim_count = sim_count+1;
	count_failed = 0;
	count_survived = 0;
	%getting survival and failed nodes
	[survive_nodes failed_nodes count_survived count_failed] = ...
	generate_failures(GRAPH,HEMP,attack_mode);
	%fprintf('%d nodes are failed\n',count_failed);
	fail_node_count(sim_count) = count_failed;
	%get failed repeaters index, and hence failed links
	[survived_repeaters failed_repeaters count_survived count_failed] = ...
	generate_failures(rep_list,HEMP,attack_mode);
	%fprintf('%d repeaters are failed\n',count_failed);
	fail_repeater_count(sim_count) = count_failed;
	
	%post attack graph
	%initialize GRAPH and ADJ post-attack
	ADJ_post = ADJ;
	ADJ_failed = ADJ;
	GRAPH_post = GRAPH;
	GRAPH_failed = GRAPH;
	index4post = index4original;
	if size(failed_repeaters,1)>0
	  for i=1:size(failed_repeaters,1) %link failures
	    ADJ_post(rep_link(failed_repeaters(i),1),rep_link(failed_repeaters(i),2)) = 0;
	    ADJ_post(rep_link(failed_repeaters(i),2),rep_link(failed_repeaters(i),1)) = 0;
	  end
	end
	%check if there are at least two surviving nodes
	if length(survive_nodes)>1
	  GRAPH_post = GRAPH_post(survive_nodes,:); %nodes survived
	  ADJ_post = ADJ_post(survive_nodes,survive_nodes); %nodes survived
	  index4post = index4post(survive_nodes); %original index post-attack
	  %post attack surviving AC&CC nodes
	  if isempty(CC_node)==false
	    [CC_node_post]=output_common_elements(survive_nodes,CC_node);
	    %post attack failed AC&CC nodes
	    CC_node_failed = setdiff(CC_node,CC_node_post);
	    %adjust index post-attack for surviving AC&CC nodes
	    [CC_node_post_adjusted]=adjust_index(index4post,CC_node_post);
	  end
	  if isempty(AC_node)==false	
	    [AC_node_post]=output_common_elements(survive_nodes,AC_node);
	    %post attack failed AC&CC nodes
	    AC_node_failed = setdiff(AC_node,AC_node_post);
	    [AC_node_post_adjusted]=adjust_index(index4post,AC_node_post);
	  end
	  %plot topology post attack
	  %plot_topology(GRAPH_post,[],ADJ_post);
	  %title('Survived Network Post-attack');
	  [isConnected(sim_count) largest_comp(sim_count)...
		      num_comp(sim_count) avg_shortest(sim_count)  avg_mincut(sim_count)] = ...
	  vulnerability_metrics(ADJ,index4post,ADJ_post,[],[],shortest_p,mincut_mtx);
	else %black-out case
	  fprintf('all blacked out...\n');
	  isConnected(sim_count)=-1;
	  largest_comp(sim_count)=0;
	  num_comp(sim_count)=0;
	  avg_shortest(sim_count)=-1;
	  avg_mincut(sim_count) = -1;
	end
	%plot topology post attack
	%plot_topology(GRAPH_post,[],ADJ_post);
	%title('Survived Network Post-attack');
	
	%[isConnected(sim_count) largest_comp(sim_count) num_comp(sim_count) ...
	%	    avg_shortest(sim_count) avg_mincut(sim_count)] = ...
	%vulnerability_metrics(ADJ,index4post,ADJ_post,[],[],shortest_p,mincut_mtx);
end
%%%%%%%%%%%%%%%%%%%%%%return performance measure%%%%%%%%%%%%%%%%%%%%
METRICS.isConnected = isConnected;
METRICS.largest_comp = largest_comp;
METRICS.num_comp = num_comp;
METRICS.avg_shortest = avg_shortest;
METRICS.avg_mincut = avg_mincut;
METRICS.file_node_count = fail_node_count;
METRICS.fail_repeater_count = fail_repeater_count;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
