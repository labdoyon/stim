function key = ld_convertOneKey(strDecoded)
%
%
%
%
%
%

key = 0;

if ~isempty(strfind(strDecoded, '1'))
    key = 1;
elseif ~isempty(strfind(strDecoded, '2'))
    key = 2;
elseif ~isempty(strfind(strDecoded, '3'))
    key = 3;
elseif ~isempty(strfind(strDecoded, '4'))
    key = 4;
end