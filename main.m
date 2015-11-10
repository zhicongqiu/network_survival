%load Uunet.mat

%load mapping package
%pkg load mapping;
%load octave-networks-toolbox
%addpath('octave-networks-toolbox');

%{
%shortest path of the complete graph
shortest_p = ones(size(adj_mtx,1),size(adj_mtx,1));
for i=1:size(adj_mtx_unweighted,1)-1
    for j=i+1:size(adj_mtx_unweighted,1)
      [shortest_p(i,j) P]= dijkstra(adj_mtx_unweighted,i,j);
      shortest_p(j,i) = shortest_p(i,j);
    end
end
%HEMP attack scenario
low_limit = 347.59;
high_limit = 608.28;
within_prob = 0.2;
near_prob = 0.8;

HEMP = struct;
HEMP(1).ground_zero = core_list(10,:);
HEMP(1).name = 'HEMP at D.C.';
HEMP(2).ground_zero = core_list(find(id_list==28),:);
HEMP(2).name = 'HEMP at St Louis';
HEMP(3).ground_zero = core_list(find(id_list==31),:);
HEMP(3).name = 'HEMP at Los Angeles';
HEMP(4).ground_zero = core_list(find(id_list==33),:);
HEMP(4).name = 'HEMP at Atlanta';
HEMP(5).ground_zero = core_list(find(id_list==13),:);
HEMP(5).name = 'HEMP at Dallas';
attack_mode = 'simple';
NUM = 300;

METRICS = struct;

for i=1:length(HEMP)
    HEMP(i).low_limit = low_limit;
    HEMP(i).high_limit = high_limit;
    HEMP(i).within_prob = within_prob;
    HEMP(i).near_prob = near_prob;

end
%}

for i=1:length(HEMP)
  METRICS(i) = survival_analysis(core_list,rep_id2,rep_list2,...
				 adj_mtx_unweighted,[],[],...
				 shortest_p,HEMP(i),NUM,attack_mode);
end

