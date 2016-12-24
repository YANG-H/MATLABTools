function [ vp, f, lineclasses ] = panoramix_wrapper_vpdetection( lines, projcenter )
%PANORAMIX_WRAPPER_VPDETECTION

% input: lines [n x 4] lines data

% convert lines to structs
ls = [];
nlines = size(lines, 1);
ls(nlines).point1 = [];
ls(nlines).point2 = [];

for i = 1:nlines
    ls(i).point1 = lines(i, [1 2]);
    ls(i).point2 = lines(i, [3 4]);
end

[vp, f] = vanish_from_minevidence(ls, projcenter * 2);
ls = assign_lineclass(ls, vp);

lineclasses = zeros(nlines, 1);
for i = 1:nlines
    lineclasses(i) = ls(i).lineclass;
end

vp = [vp{1}; vp{2}; vp{3}];

end

