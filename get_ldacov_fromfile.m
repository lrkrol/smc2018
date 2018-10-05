
function ldacov = get_ldacov_fromfile(file, variablename, index)

ldacov = load(file);
ldacov = ldacov.(variablename);
if iscell(ldacov), ldacov = ldacov{index{:}};
else ldacov = ldacov(index{:}); end

end