function [METRICS] = backup_protection_sim(GRAPH,rep_link,rep_list,ADJ,...
					   pairs,shortest_p,backup_p,...
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

