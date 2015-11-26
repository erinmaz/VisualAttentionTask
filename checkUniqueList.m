for i=1:(length(unique_list)-1)
if unique_list(i) == unique_list(i+1)
sprintf('uhoh');
end
end

count=0;
for i=1:(length(val_list)-1)
if val_list(i) == val_list(i+1)
count=count+1;
end
end
count

doubles = [];
for i=1:(length(numbers)-1)
if numbers(i) == numbers(i+1)
doubles = [doubles i];
end
end

repeatblock1 = [5.5 4.5 5.5 3.5 2.5 6.5 ]; % first interval is 3.5 sec - done manually
repeatblock2 = [4.5 6.5 2.5 3.5 5.5 3.5 5.5 ];

%repeat = round(rand(1,16)*4+3); % list of ints between 3 and 7 (seconds between random repeating values)
repeat = [repeatblock1 repeatblock2];
repeat2Hz = repeat * 2;

repeatFlicker1 = [ 4.5000    5.5000    3.5000    6.5000    5.5000    2.5000    3.5000];
repeatFlicker2 = [ 5.5000    3.5000    2.5000    5.5000    4.5000    3.5000    6.5000];
repeatFlicker3 = [ 5.5000    6.5000    3.5000    5.5000    2.5000    3.5000    4.5000];
repeatFlicker4 = [ 6.5000    4.5000    5.5000    3.5000    2.5000    3.5000    5.5000];

repeatFlicker = [repeatFlicker1 repeatFlicker2 repeatFlicker3 repeatFlicker4];
%repeatFlicker = round(rand(1,1000)*4+3); % list of ints between 3 and 7 (seconds between flickers)


% Set the first section - each section has 6 to 14 non repeating numbers followed by one repeat.
val_list = randperm(9,7); % 7 non-repeating values (i.e., 3.5 sec) between 1 and 9 
repeat_val = val_list(7);
val_list = [val_list repeat_val];

% Add to the value list one non-repeating chunk at a time
for i = repeat2Hz % Numbers flicker at 2Hz so we multiply the repeat interval by 2
    triple = true;
    % Add a smaller chunk with no repeats if i > 9
    if i > 9
        while triple
            list_append = randperm(9,9);
            if list_append(1) == val_list(end)
                triple = true;
            else
                triple = false;
            end
        end
        val_list = [val_list list_append];
        smallchunk = i - 9;
    else
        smallchunk = i;
    end
    % Add the remaining chunk or small chunk
    list_append = randperm(9,smallchunk);
    while list_append(1) == val_list(end)
        list_append = randperm(9,smallchunk);
    end
    
    % Add the new section
    val_list = [val_list list_append];
    % Add the repeating value
    repeat_val = val_list(end);
    val_list = [val_list repeat_val];

   
    
    % End when the list is long enough (50% more #'s than needed at a rate of 2/sec)
 %   if length(val_list) > ((head_delay + tail_delay + time_on) * cycles_interleaved * 3)
  %      break
 %   end
end
 midsection=randperm(9,9);
    while midsection(1) == val_list(70)
        midsection=randperm(9,9);
    end
    list_append = randperm(9,5);
    while list_append(1) == midsection(end)
        list_append = randperm(9,5);
    end
    list_append = [midsection list_append];
    val_list =  [val_list(1:70) list_append val_list(71:end)];
    
    endsection=randperm(9,9);
    while endsection(1) == val_list(end)
        endsection=randperm(9,9);
    end
    list_append = randperm(9,5);
    while list_append(1) == endsection(end)
        list_append = randperm(9,5);
    end
    list_append = [endsection list_append];
    val_list = [val_list list_append];