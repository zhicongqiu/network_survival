function [arr_out]=output_common_elements(arr1,arr2)
%output_common_elements of arr1 and arr2
	i = 1; j = 1;
	arr_out = [];
	count = 0;
	while i <= length(arr1) && j <= length(arr2)
		if arr1(i) > arr2(j)
			j = j+1;
		elseif arr1(i) < arr2(j)
			i = i+1;
		else
			count = count+1;
			arr_out(count) = arr1(i);
			j = j+1;
			i = i+1;
		end
	end

end