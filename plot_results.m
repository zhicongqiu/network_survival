## Copyright (C) 2015 zhicong
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{retval} =} plot_results (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Zhicong Qiu <zzq101@psu.edu>
## Created: 2015-11-14

function [] = plot_results (METRICS)
  subplot(2,2,1);
  hist(METRICS.largest_comp);
  temp_str = strcat('size of LCC: ',...
		    num2str(mean(METRICS.largest_comp)),...
		    ' +- ',num2str(sqrt(var(METRICS.largest_comp))));

  title(temp_str);
  subplot(2,2,2);
  hist(METRICS.num_conn_pairwise(:,2));
  temp_str = strcat('ratio of pair conn. survived: ',...
		    num2str(mean(METRICS.num_conn_pairwise(:,2))),...
		   ' +- ',num2str(sqrt(var(METRICS.num_conn_pairwise(:,2)))));
  title(temp_str);
  subplot(2,2,3);
  hist(METRICS.avg_shortest);
  temp_str = strcat('shortest path diff. bef./aft. HEMP: ',...
		    num2str(mean(METRICS.avg_shortest)),...
		   ' +- ', num2str(sqrt(var(METRICS.avg_shortest))));
  title(temp_str);
  subplot(2,2,4);
  hist(METRICS.avg_mincut);
  temp_str = strcat('min-cut diff. bef./aft. HEMP: ',...
		    num2str(mean(METRICS.avg_mincut)),...
		    ' +- ', num2str(sqrt(var(METRICS.avg_mincut))));
  title(temp_str);



endfunction
