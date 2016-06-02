function [keys] = convertMultipleKeys(keys)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Map keys code according to the task mapping
% MRI compatible keyboard 
% 
% INPUT
%   keys    ASCII code of the pressed keys 
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
%
% OUTPUT
%   keys     keys code according to the task mapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for nbKeys = 1:length(keys)
%% ergonomic position of MR compatible keypad
    switch keys(nbKeys)
        case {65}   % the pressed number is 1
            keys(nbKeys) = 1;
        case {66}   % the pressed number is 2
            keys(nbKeys) = 2;
        case {67}   % the pressed number is 3
            keys(nbKeys) = 3;    
        case {68}   % the pressed number is 4
            keys(nbKeys) = 4;
        otherwise
%             disp('Which key:' num2str(keys(nbKeys)))
            keys(nbKeys) = 0;
    end

%% upside-down position of MR compatible keypad
%     switch keys(nbKeys)
%         case {54}   % the pressed number is 6
%             keys(nbKeys) = 1;
%         case {52}   % the pressed number is 4
%             keys(nbKeys) = 2;
%         case {51}   % the pressed number is 3
%             keys(nbKeys) = 3;
%         case {50}   % the pressed number is 2
%             keys(nbKeys) = 4;
%         otherwise
%             keys(nbKeys) = 0;
%     end

end

