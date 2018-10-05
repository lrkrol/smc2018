
function ldaweights = get_ldaweights_fromfile(file, variablename, index)

ldaweights = load(file);
ldaweights = ldaweights.(variablename);
if iscell(ldaweights), ldaweights = ldaweights{index{:}};
else ldaweights = ldaweights(index{:}); end

end