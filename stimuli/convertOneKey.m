function key = convertOneKey(keycode)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Map the key code according to the task mapping
% MRI compatible keyboard 
% 
% INPUT
%   key     ASCII code of the pressed key
%       ASCII code      corresponding number
%           48              0
%           49              1
%           50              2
%           51              3
%           52              4
%           53              5
%           54              6
%           55              7
%           56              8
%           57              9
%           ...             ...
%           97              a
%           98              b
%           99              c
%           100             d
% OUTPUT
%   key     the key code according to the task mapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ergonomic position of MR compatible keypad
if length(keycode) > 1 
    if  sum(keycode == [16 84 160]) == 3
        keycode = 84;
    else
        keycode = 0;
    end
end

switch keycode
    case {65}  % the pressed number is 1
        key = 1;
    case {66}   % the pressed number is 2
        key = 2;
    case {67}   % the pressed number is 3
        key = 3;
    case {68}   % the pressed number is 4
        key = 4;
    otherwise
        key = 0;
end
    disp(key)