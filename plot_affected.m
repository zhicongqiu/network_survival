function [] = plot_affected(GRAPH,ADJ,HEMP,s,s_name)

%plot the simple HEMP attack scenario
%[] = plot_affected(GRAPH,ADJ,HEMP,s,s_name)
plot_topology(GRAPH,[],ADJ);
%getting the subset of affected nodes/links
[hi_affected_nodes low_affected_nodes] = get_affected(GRAPH,HEMP,'simple');
hold on;
h(1) = plot(GRAPH(hi_affected_nodes,1),GRAPH(hi_affected_nodes,2),...
	    'ro','linewidth',2);
h(2) = plot(GRAPH(low_affected_nodes,1),GRAPH(low_affected_nodes,2),...
	    'go','linewidth',2);
h(3) = plot(HEMP.ground_zero(1),HEMP.ground_zero(2),'kx','linewidth',3);
legend([h(1) h(2) h(3)],'nodes failure with high prob'...
       ,' nodes failure with low prob','ground zero');
tp = HEMP.name;
title(tp);
hold off;

if s==true
  print(s_name,'-dpng');
  %close(gcf);
end
