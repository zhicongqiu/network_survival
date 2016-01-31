function plot_topology(node_list,repeater,adj_mtx)
%plot the topological network, given lon,lat of nodes and repeater
%show repeater in red and regular node/link in blue
%[] = plot_topology(node_list,repeater,adj_mtx)

%hold off;
h = figure;
hold on;
N = size(adj_mtx,1);

for i=1:N-1
  for j=i+1:N
    if adj_mtx(i,j)~=0
      plot([node_list(i,1) node_list(j,1)],...
	   [node_list(i,2) node_list(j,2)],'-sb');
    end
  end
end
%{
h(1) = plot(node_list(end-41:end,1),...
	    node_list(end-41:end,2),'ro','linewidth',2);
%legend(h(1),'inter-city nodes');
h(2) = plot(node_list(6:6:end-40,1),...
	    node_list(6:6:end-40,2),'go','linewidth',2);
legend([h(1),h(2)],'inter-city nodes','Uunet original nodes');
%}
%{
for i=1:size(repeater,1)
	plot(repeater(i,1),repeater(i,2),'or');
end
axis([-130 -60 25 55]);
%}
%savefig(h,'NetworkTop.fig');
%close(h);
