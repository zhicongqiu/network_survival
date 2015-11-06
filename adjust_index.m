function [target_out]=adjust_index(index_arr,target_arr)
%adjust index of arr1 and arr2
	i = 1; j = 1;
	target_out = [];
	while i <= length(index_arr) && j <= length(target_arr)
		if index_arr(i) == target_arr(j)
			target_out(j) = i;
			j = j+1;
			i = i+1;
		elseif index_arr(i) < target_arr(j)
			i = i+1;
		else
			error('either of them are not sorted, redo...\n');
		end
	end

end