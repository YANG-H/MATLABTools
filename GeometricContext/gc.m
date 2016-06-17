function [imseg, seg_im, slabelConfMap, slabelConfMap_im] = gc( rim )
%GC Summary of this function goes here
%   Detailed explanation goes here

    eclassifier = {};
    labelclassifier = {};
    segclassifier = {};
    ecal = [];
    load Classifiers_gc;

% segmentation
	fprintf('performing segmentation ...\n');
	tmpimdir = [tempdir 'gc_temp_name.ppm'];
	tmpsegdir = [tempdir 'gc_temp_seg.pnm'];
	imwrite(rim, tmpimdir);
    [folder, name, ext] = fileparts(mfilename('fullpath'));
	system(['"' folder '/segmentation" 0.8 100 100 ' tmpimdir ' ' tmpsegdir]);
	imseg = processSuperpixelImage(tmpsegdir);
	delete(tmpimdir);
	delete(tmpsegdir);

	seg_im = label2rgb(imseg.segimage, 'jet', 'w', 'shuffle');

	% initial gc
    fprintf('estimating geometric context feature ...\n');

	%disp('retrieving superpixel features');
	spfea = mcmcGetSuperpixelData(im2double(rim), imseg);
	[edgefea, adjlist, ~, ~] = mcmcGetEdgeData(imseg, spfea);
	
	confidences = test_boosted_dt_mc(eclassifier, edgefea);
	confidences = 1 ./ (1+exp(ecal(1)*confidences+ecal(2)));

	%disp('creating multiple segmentations');
	smaps = generateMultipleSegmentations2(confidences, adjlist, ...
		imseg.nseg, [5 15 25 35 40 60 80 100]);
    %smaps = msCreateMultipleSegmentations(confidences, adjlist, ...
	%	imseg.nseg, [5 15 25 35 40 60 80 100]);
	imdata = mcmcComputeImageData(im2double(rim), imseg);
    segfea = {};
	for jdx=1:size(smaps, 2)
		if max(smaps(:, jdx)) > 0
			segfea{jdx} = mcmcGetSegmentFeatures(imseg, ...
				spfea, imdata, smaps(:, jdx), 1:max(smaps(:, jdx)));
		end
	end

	% get surface label confidences initial
	%disp('predicting surface label confidences');
	initSlabelConfidence = msTest(imseg, segfea, {smaps}, labelclassifier, segclassifier, 1);
	initSlabelConfidence = initSlabelConfidence{1};

	[slabelConfMap, ~, slabelConfMap_im] = ...
		composeSegLabel(imseg.segimage, initSlabelConfidence);
	slabelConfMap_im = slabelConfMap_im / max(slabelConfMap_im(:));

end

