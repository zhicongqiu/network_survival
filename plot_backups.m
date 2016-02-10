function plot_backups(node_list,repeater,adj_mtx,...
		      shortest,backup,baseline,gz,simple)
%plot the topological network, given lon,lat of nodes and repeater
%show repeater in red and regular node/link in blue
%[] = plot_topology(node_list,repeater,adj_mtx)

%hold off;
h = figure;
hold on;
N = size(adj_mtx,1);

%background graph
for i=1:N-1
  for j=i+1:N
    if adj_mtx(i,j)~=0
       if simple==1
	 plot([node_list(i,1) node_list(j,1)],...
	      [node_list(i,2) node_list(j,2)],'sg');
       else
	 plot([node_list(i,1) node_list(j,1)],...
	      [node_list(i,2) node_list(j,2)],'-sg');
       end
    end
  end
end

%pin point ground zero
h(1) = plot(gz(1),gz(2),'kh');

%shortest path
h(2) = plot([node_list(shortest(1),1) node_list(shortest(end),1)],...
	    [node_list(shortest(1),2) node_list(shortest(end),2)],...
	     'ko');
for i=1:length(shortest)-1
    h(3) = plot([node_list(shortest(i),1) node_list(shortest(i+1),1)],...
		[node_list(shortest(i),2) node_list(shortest(i+1),2)],...
		'-k','linewidth',2);
end



%baseline
for i=1:length(baseline)-1
    h(4) = plot([node_list(baseline(i),1) node_list(baseline(i+1),1)],...
		[node_list(baseline(i),2) node_list(baseline(i+1),2)],...
		'--b','linewidth',2);
end

%backup path
for i=1:length(backup)-1
    h(5) = plot([node_list(backup(i),1) node_list(backup(i+1),1)],...
		[node_list(backup(i),2) node_list(backup(i+1),2)],...
		'-.k','linewidth',2);
end

legend([h(1),h(2),h(3),h(4),h(5)],...
       'ground zero','a pair of AC nodes',...
       'shortest path',...
       '2nd shortest path (baseline)',...
       'proposed backup path',...
       'Location','southwest');

xlabel('longtitude','fontsize',18);
ylabel('latitude','fontsize',18);
if simple
  title('Level-3 Graph with only Nodes Shown, prior attack','fontsize',18);
else
  title('Level-3 Graph, prior attack','fontsize',18);
end
set(gca,'fontsize',18);
set(h(1),'markers',10);
set(h(2),'markers',10);
