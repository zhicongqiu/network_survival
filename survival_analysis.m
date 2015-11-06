function [METRICS fail_num] = survival_analysis(GRAPH,rep_id,rep_list,ADJ,CC_node,AC_node,HEMP,NUM,attack_mode)

%%%%%input%%%%%
%GRAPH: 2-D matrix: each row specifies a node's geo-location in (x,y)
%ADJ: network graph with same number of nodes as GRAPH, an adjacency matrix specifying connections between nodes
%rep_id: repeater locations in (lon,lat)
%rep_list: links associated with each repeater
%CC_node: node index to indicate CC nodes
%AC_node: node index to indicate AC nodes
%HEMP: HEMP attack scenario
%NUM: number of monte carlo trials
%%%%%
%%%%%output%%%%%
%performance metrics in each random trials
METRICS = struct;
%put AC and CC nodes in sorted order index
CC_node = sort(CC_node);
AC_node = sort(AC_node);

N = size(GRAPH,1); %number of primary nodes

%index for original GRAPH
index4original = cumsum(ones(1,N));
sim_count = 0;

%plot the original graph
plot_affected(GRAPH,ADJ,HEMP,attack_mode);

%%begin NUM simulations
while sim_count<NUM
	sim_count = sim_count+1;
	count_failed = 0;
	count_survived = 0;
	%getting survival and failed nodes
	[survive_nodes failed_nodes count_survived count_failed] = generate_failures(GRAPH,HEMP,attack_mode);
	fprintf('%d nodes are failed\n',count_failed);
	fail_num(sim_count) = count_failed;
	%get failed repeaters index, and hence failed links
	[survived_repeaters failed_repeaters count_survived count_failed] = generate_failures(rep_id,HEMP,attack_mode);
	fprintf('%d repeaters are failed\n',count_failed);
	
	%post attack graph
	%initialize GRAPH and ADJ post-attack
	ADJ_post = ADJ;
	ADJ_failed = ADJ;
	GRAPH_post = GRAPH;
	GRAPH_failed = GRAPH;
	index4post = index4original;
	if size(failed_repeaters,1)>0
	  for i=1:size(failed_repeaters,1) %link failures
	    ADJ_post(rep_list(failed_repeaters(i),1),rep_list(failed_repeaters(i),2)) = 0;
	    ADJ_post(rep_list(failed_repeaters(i),2),rep_list(failed_repeaters(i),1)) = 0;
	  end
	end
	GRAPH_post = GRAPH_post(survive_nodes,:); %nodes survived
	ADJ_post = ADJ_post(survive_nodes,:); %nodes survived
	ADJ_post = ADJ_post(:,survive_nodes); %nodes survived
	index4post = index4post(survive_nodes); %original index post-attack
	%post attack surviving AC&CC nodes
	[CC_node_post]=output_common_elements(survive_nodes,CC_node);
	[AC_node_post]=output_common_elements(survive_nodes,AC_node);
	%post attack failed AC&CC nodes
	CC_node_failed = setdiff(CC_node,CC_node_post);
	AC_node_failed = setdiff(AC_node,AC_node_post);
	%adjust index post-attack for surviving AC&CC nodes
	[CC_node_post_adjusted]=adjust_index(index4post,CC_node_post);
	[AC_node_post_adjusted]=adjust_index(index4post,AC_node_post);
	%plot topology post attack
	%plot_topology(GRAPH_post,[],ADJ_post);
	%title('Survived Network Post-attack');
	[METRICS(sim_count)] = ...
	vulnerability_metrics(ADJ,index4post,ADJ_post,AC_node_post_adjusted,CC_node_post_adjusted);
		
end




