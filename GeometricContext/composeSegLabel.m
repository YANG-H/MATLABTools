function [confidIm, maxconfidIm, coloredIm]  = composeSegLabel(segs, seglabelconfid, colortable)

	confidIm = zeros([size(segs, 1)*size(segs, 2) size(seglabelconfid, 2)]);
	segs = segs + 1 - min(segs(:));
	for segid = 1:length(unique(segs))
		for labelid = 1:size(seglabelconfid, 2)
			confidIm(segs == segid, labelid) = seglabelconfid(segid, labelid);
		end
	end
	confidIm = reshape(confidIm, [size(segs) size(seglabelconfid, 2)]);
	[~, maxconfidIm] = max(confidIm, [], 3);

	if nargout >= 3
		if nargin <= 2
			colortable = [255 0 0; 0 255 0; 0 0 255; 255 255 0; 255 0 255; 0 255 255; 255 255 255];
		end
		coloredIm = zeros([size(segs) 3]);
		for segidx=1:size(seglabelconfid, 1)
			seg  = segs == segidx;
			lbcolor = dot(repmat(seglabelconfid(segidx, :)', 1, 3), colortable);
			for channel = 1:3
				coloredIm(:, :, channel) = coloredIm(:, :, channel) + (seg * lbcolor(channel));
			end
		end
		for channel = 1:3
			coloredIm(:, :, channel) = coloredIm(:, :, channel) ./ sum(coloredIm, 3) * 255;
		end
	end

end