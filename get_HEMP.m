function HEMP = get_HEMP(city_name,location,near_prob,far_prob,...
			 near_dist,far_dist,std,option)
  %specify the hemp model
  %currently there are two options:
  %0: cookie cutter model, within far_dist from location all links failed
  %1: simple HEMP, with two prob. of failure
  %2: Gaussian HEMP with mean at location and std
  HEMP = struct;
  HEMP.name = city_name;
  HEMP.gz = location;
  if option=='0'
    HEMP.dist = far_dist;
    HEMP.model_name = 'cookie_cutter';
  elseif option=='1'
    HEMP.low_limit = near_dist;
    HEMP.high_limit = far_dist;
    HEMP.within_prob = far_prob;
    HEMP.near_prob = near_prob;
    HEMP.model_name = 'two_prob';
  elseif option=='2'
    HEMP.mean = location;
    HEMP.std = std;
    HEMP.model_name = 'gaussian';
  end
