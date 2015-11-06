function [dist temp_az] = lon_lat_dist(lon1,lat1,lon2,lat2)
%%%%%%%%%%
%distance btw two lon,lat point on earth, in nautical miles, and azimuth
	[temp_arc temp_az]= distance(lat1,lon1,lat2,lon2);
	dist = deg2nm(temp_arc);