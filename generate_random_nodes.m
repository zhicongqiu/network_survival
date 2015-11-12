function [GRAPH ADJ] = generate_random_nodes(core_list,core_ADJ,RAD,US_RAD,num_node,num_scatter,max_length)
%%%%%%%%%%%%%%%%
%generate random nodes around major cities
%input: 
%core_list: each row specify the (x,y) location of each major city
%RAD: city diameter in nautical mile; we will generate nodes within this square
%USA_RAD: contry map diameter. All nodes/links will be within this map
%num_node: number of randomly generated nodes around a major city
%num_scatter: number of scattered nodes generated across America
%max_length: the maximum length a link can be used between nodes

%output:
%GRAPH: graph representing nodal geolocation
%ADJ: adjacency matrix


%number of nodes around a city
%num_node = 100;

ADJ = zeros(size(core_list,1)*(num_node+1)+num_scatter,size(core_list,1)*(num_node+1)+num_scatter);
GRAPH = zeros(size(core_list,1)*(num_node+1)+num_scatter,2);
%add back the previous links
for i=1:size(core_ADJ,1)-1
  for j=i+1:size(core_ADJ,1)
    if core_ADJ(i,j) ~=0
      ADJ((num_node+1)*i,(num_node+1)*j) = core_ADJ(i,j);
      ADJ((num_node+1)*j,(num_node+1)*i) = core_ADJ(i,j);
    end
  end
end

count_ADJ_last = 1;
count_ADJ_next = 1;
%%randomly generate num_node nodes around each of the major city and add links until specified density and connected
for i=1:size(core_list,1)
  %fprintf('begin to add inter city %d nodes...\n',i);
  temp_loc = zeros(num_node,2);
  r = RAD(i)*rand(num_node,1);
  azi = 360*rand(num_node,1);
  for j=1:num_node
    [temp_loc(j,2),temp_loc(j,1)] = reckon(core_list(i,2),core_list(i,1),nm2deg(r(j)),azi(j));
  end
  temp_loc = [core_list(i,:);temp_loc];
  %there are num_node+1 nodes in each city
  temp_ADJ = zeros(num_node+1,num_node+1);
  %add links until the density reaches 'dens_city'
  count_total_link = 0;
  all_connected=false;
  while all_connected==false
    temp_1 = randi(num_node+1);
    temp_2 = randi(num_node+1);
    if temp_1~=temp_2&&temp_ADJ(temp_1,temp_2)==0
      [temp_ADJ(temp_1,temp_2) temp_azi]=...
      lon_lat_dist(temp_loc(temp_1,2),temp_loc(temp_1,1),temp_loc(temp_2,2),temp_loc(temp_2,1));
      %bi-directional link
      temp_ADJ(temp_2,temp_1) = temp_ADJ(temp_1,temp_2);
      count_total_link = count_total_link+1;
      if count_total_link>=num_node
	all_connected = isConnected(temp_ADJ);
      else
	all_connected = false;
      end
    end
  end
  count_ADJ_next = count_ADJ_last+size(temp_ADJ,1)-1;
  ADJ(count_ADJ_last:count_ADJ_next,count_ADJ_last:count_ADJ_next) = temp_ADJ;
  GRAPH(count_ADJ_last:count_ADJ_next,:) = temp_loc;
  count_ADJ_last = count_ADJ_next+1;
end
clear count_ADJ_next;

fprintf('begin to add scattered nodes...\n');
%%adding num_scatter scattering nodes	
r = zeros(num_scatter,2);
r(:,1) = US_RAD(1) + (US_RAD(2)-US_RAD(1))*rand(num_scatter,1);
r(:,2) = US_RAD(3) + (US_RAD(4)-US_RAD(3))*rand(num_scatter,1);
GRAPH(count_ADJ_last:count_ADJ_last+num_scatter-1,:) = r;
%{
%the scattered nodes can only be between, not within major cities
count_scatter = 0;
while count_scatter<num_scatter
	r = -US_RAD(i) + 2*US_RAD(i)*rand(1,2);
	inside = false;
	for j=1:size(core_list,1)
		if l2norm(core_list(j,1)-r(1),l2norm(core_list(j,2)-r(2))<RAD(j)*sqrt(2)
			inside = true;
			break;
		end
	end
	if inside == false
		count_scatter = count_scatter+1;
		GRAPH(count_ADJ_last,:) = r;
		count_ADJ_last = count_ADJ_last+1;
	end
end
%%check isolated scattered nodes
count_isolated = 0;
temp_indicator = 1;
for i=1:num_scatter
	not_isolated = false;
	for j=1:size(ADJ,1)
		if l2norm(GRAPH(size(core_list,1)*num_node+i,1)-GRAPH(j,1),GRAPH(size(core_list,1)*num_node+i,2)-GRAPH(j,2))<max_length
			not_isolated = true;
			break;
		end
	end
	if not_isolated==false
	%delete this scattering node
		count_isolated = count_isolated+1;
		temp_indicator(count_isolated)=i;		
	end	
end
if length(temp_indicator)~=1
	fprintf('some nodes are isolated: get deleted.\n');
	GRAPH(temp_indicator,:)=[];
	ADJ(temp_indicator,temp_indicator)=[];
	num_scatter = num_scatter-length(temp_indicator);
end
%}


%%randomly add links between major cities and scattered nodes until the whole network is connected
%length of each link is subject to contraint in max_length meters
fprintf('begin to add links between scattered and city nodes...\n');
%temp_ADJ_scatter to calculate the density across USA
temp_ADJ_scatter = zeros(size(core_list,1)+num_scatter,size(core_list,1)+num_scatter);
temp_ADJ_scatter(1:size(core_list,1),1:size(core_list,1)) = core_ADJ;
all_connected = false;
count_total_link = 0;
%iteration = 0;
while all_connected == 0 %&& iteration<(size(core_list,1)+num_scatter)^2/2
	%choose a scattered node
	temp_11 = randi([size(core_list,1)+1 size(core_list,1)+num_scatter],1);
	temp_1 = size(core_list,1)*(num_node+1)+temp_11-size(core_list,1);
	%{
        if temp_11<size(core_list,1)
		temp1_within = randi(num_node+1);
		temp_1 = temp_11*(num_node+1)+temp1_within;
	else
		temp_1 = size(core_list,1)*(num_node+1)+temp_11-size(core_list,1);
	end
	%}
	temp_21 = randi(size(core_list,1)+num_scatter);
	if temp_11~=temp_21&&temp_ADJ_scatter(temp_11,temp_21)==0
	  if temp_21<size(core_list,1) %choose a node within a city
	    temp2_within = randi(num_node+1);
	    temp_2 = temp_21*(num_node+1)+temp2_within;
	  else
	    temp_2 = size(core_list,1)*(num_node+1)+temp_21-size(core_list,1);
	  end

	  [temp_dist temp_azi] = ...
	  lon_lat_dist(GRAPH(temp_1,1),GRAPH(temp_1,2),GRAPH(temp_2,1),GRAPH(temp_2,2));
	  %fprintf('this is %d iterations.\n',iteration);
	  %add this link into the ADJ matrix
	  ADJ(temp_1,temp_2) = temp_dist;
	  %bi-directional link
	  ADJ(temp_2,temp_1) = ADJ(temp_1,temp_2);
	  temp_ADJ_scatter(temp_11,temp_21) = 1;
	  temp_ADJ_scatter(temp_21,temp_11) = temp_ADJ_scatter(temp_11,temp_21);
	  count_total_link = count_total_link+1;
	  fprintf('adding the %d th links...\n',count_total_link);
	  if count_total_link>=size(core_list,1)+num_scatter-1
	    all_connected = isConnected(temp_ADJ_scatter);
	  end
	end
end

		
