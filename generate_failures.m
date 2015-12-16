function [survive_nodes failed_nodes count_survived count_failed] =...
	 generate_failures(node_list,HEMP,attack_mode)
  %generate failure event
  %return survive and failed nodes indices
	 
  count_failed = 0;
  count_survived = 0;
  failed_nodes = [];
  survive_nodes = [];
  for i=1:size(node_list,1)
    [temp_dist temp_az] = ...
    lon_lat_dist(HEMP.ground_zero(1),HEMP.ground_zero(2),...
		 node_list(i,1),node_list(i,2));
    %squared distance HEMP model
    if strcmp(attack_mode,'gaussian')
      %p-value associated with x and y
      temp_prob = normcdf(temp_dist,0,HEMP.std);
      if temp_prob<0.5
	 temp_prob = 2*temp_prob;
      else
	temp_prob = 2*(1-temp_prob);
      end
      %within the affected area and failed
      if temp_prob>=rand 
	count_failed = count_failed+1;
	failed_nodes(count_failed) = i;	
      else
	count_survived = count_survived+1;
	survive_nodes(count_survived) = i;
      end	    
    %a sample model with fixed low/high range prob. of failure
    elseif strcmp(attack_mode,'simple')
      temp = rand;
      if temp_dist<=HEMP.high_limit&&temp_dist>=HEMP.low_limit&&HEMP.within_prob>=temp
	count_failed = count_failed+1;
	      failed_nodes(count_failed) = i;	
      elseif temp_dist<HEMP.low_limit&&HEMP.near_prob>=temp
	count_failed = count_failed+1;
	failed_nodes(count_failed) = i;	
      else
	count_survived = count_survived+1;
	survive_nodes(count_survived) = i;			
      end
    elseif strcmp(attack_mode,'cookie_cutter')||...
	   strcmp(attack_mode,'worst_case')
      if temp_dist<=HEMP.r
	count_failed = count_failed+1;
	failed_nodes(count_failed) = i;	
      else
	count_survived = count_survived+1;
	survive_nodes(count_survived) = i;
      end
    else
	error('HEMP attack not specified...\n');
    end				
  end
