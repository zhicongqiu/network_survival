function [rep_list rep_link] = get_repeater(core_list, adj_mtx, az_mtx)
%put repeaters along the link with distance larger than l nautical miles
%optimize allocation of repeaters (partition the link into equal-length segments)
%output: a lister of repeater in lon,lat and their 'belonging'

%
%l = 434.488; %=500 miles, limit that we need to add a repeater if longer
l = 43.1965; %= 80 kms or 49.71 miles
%temp_arclen = nm2deg(l); %used in retriving lon,lat of a repeater along the azimuth
N = size(adj_mtx,1);
count = 0;

%upper triangular
for i=1:N-1
  for j=i+1:N
    if adj_mtx(i,j)>=l
      opt_num = ceil(adj_mtx(i,j)/l);
      opt_all = nm2deg(adj_mtx(i,j)/opt_num);
      count2 = 0;
      while count2<opt_num
	count = count+1;
	count2 = count2+1;
	pt = zeros(1,2);
	if count2==1
	  %pt = reckon(core_list(i,2),core_list(i,1),temp_arclen,az_mtx(i,j));
	  [pt(1),pt(2)] = reckon(core_list(i,2),core_list(i,1),opt_all,az_mtx(i,j));
	else
	  %pt = reckon(pt(1),pt(2),temp_arclen,temp_az);
	  [pt(1),pt(2)] = reckon(pt(1),pt(2),opt_all,temp_az);
	end
	rep_list(count,1) = pt(2);
	rep_list(count,2) = pt(1);
	rep_link(count,1) = i;
	rep_link(count,2) = j;
	[dist temp_az] = lon_lat_dist(pt(2),pt(1),core_list(j,1),core_list(j,2));
	if dist<l
	  break;
	end
      end
      
    end
  end
end
