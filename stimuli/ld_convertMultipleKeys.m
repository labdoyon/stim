function [keys] = ld_convertMultipleKeys(keys, currentKeyboard)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Map keys code according to the task mapping
% MRI compatible keyboard 
% 
%
%
%
%
%

for nbKeys = 1:length(keys)
    strDecoded = ld_convertKeyCode(keys(nbKeys), currentKeyboard);
    keys(nbKeys) = ld_convertOneKey(strDecoded);
end
