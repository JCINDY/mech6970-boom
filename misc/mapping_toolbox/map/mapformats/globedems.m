function fname = globedems(latlim,lonlim)
%GLOBEDEMS GLOBE data filenames for latitude-longitude quadrangle
%
%  FNAME= GLOBEDEMS(LATLIM,LONLIM) returns a cellarray of the file names
%  covering the geographic region for GLOBEDEM digital elevation maps. The
%  region is specified by scalar latitude and longitude points, or two 
%  element vectors of latitude and longitude limits in units of degrees.
%
%  See also GLOBEDEM.

% Copyright 1996-2007 The MathWorks, Inc.
% Written by:  A. Kim, W. Stumpf, L. Job
% $Revision: 1.1.6.4 $    $Date: 2007/10/10 20:49:05 $

if nargin~=2
	error(['map:' mfilename ':mapformatsError'], 'Incorrect number of arguments')
end

% ensure row vectors
latlim = latlim(:)';
lonlim = lonlim(:)';

if  isequal(size(latlim),[1 1])
	latlim = latlim*[1 1];
elseif ~isequal(size(latlim),[1 2])
    error(['map:' mfilename ':mapformatsError'], 'Latitude limit input must be a scalar or 2 element vector')
end

if isequal(sort(size(lonlim)),[1 1])
	lonlim = lonlim*[1 1];
elseif ~isequal(sort(size(lonlim)),[1 2])
    error(['map:' mfilename ':mapformatsError'], 'Longitude limit input must be a scalar or 2 element vector')
end

% read names and bounding rectangle limits

[fnames,YMIN,YMAX,XMIN,XMAX,rtile,ctile] = textread('globedems.dat','%s %d %d %d %d %d %d');

% case where dateline is not crossed
if lonlim(1) <= lonlim(2)
	do = ...
	 find( ...
			(...
			(latlim(1) <= YMIN & latlim(2) >= YMAX) | ... % tile is completely within region
			(latlim(1) >= YMIN & latlim(2) <= YMAX) | ... % region is completely within tile
			(latlim(1) >  YMIN & latlim(1) <  YMAX) | ... % min of region is on tile
			(latlim(2) >  YMIN & latlim(2) <  YMAX)   ... % max of region is on tile
			) ...
				&...
			(...
			(lonlim(1) <= XMIN & lonlim(2) >= XMAX) | ... % tile is completely within region
			(lonlim(1) >= XMIN & lonlim(2) <= XMAX) | ... % region is completely within tile
			(lonlim(1) >  XMIN & lonlim(1) <  XMAX) | ... % min of region is on tile
			(lonlim(2) >  XMIN & lonlim(2) <  XMAX)   ... % max of region is on tile
			)...
		);
end
	
% case where the dateline is crossed
if lonlim(1) > lonlim(2)
	lmin = lonlim(1); lmax = lonlim(2);
	lonlim(2) = 180;
	% do eastern side of the dateline first
	doEAST = ...
	 find( ...
			(...
			(latlim(1) <= YMIN & latlim(2) >= YMAX) | ... % tile is completely within region
			(latlim(1) >= YMIN & latlim(2) <= YMAX) | ... % region is completely within tile
			(latlim(1) >  YMIN & latlim(1) <  YMAX) | ... % min of region is on tile
			(latlim(2) >  YMIN & latlim(2) <  YMAX)   ... % max of region is on tile
			) ...
				&...
			(...
			(lonlim(1) <= XMIN & lonlim(2) >= XMAX) | ... % tile is completely within region
			(lonlim(1) >= XMIN & lonlim(2) <= XMAX) | ... % region is completely within tile
			(lonlim(1) >  XMIN & lonlim(1) <  XMAX) | ... % min of region is on tile
			(lonlim(2) >  XMIN & lonlim(2) <  XMAX)   ... % max of region is on tile
			)...
		);
	% do western side of the dateline second
	lonlim(1) = -180; lonlim(2) = lmax;	
	doWEST = ...
	 find( ...
			(...
			(latlim(1) <= YMIN & latlim(2) >= YMAX) | ... % tile is completely within region
			(latlim(1) >= YMIN & latlim(2) <= YMAX) | ... % region is completely within tile
			(latlim(1) >  YMIN & latlim(1) <  YMAX) | ... % min of region is on tile
			(latlim(2) >  YMIN & latlim(2) <  YMAX)   ... % max of region is on tile
			) ...
				&...
			(...
			(lonlim(1) <= XMIN & lonlim(2) >= XMAX) | ... % tile is completely within region
			(lonlim(1) >= XMIN & lonlim(2) <= XMAX) | ... % region is completely within tile
			(lonlim(1) >  XMIN & lonlim(1) <  XMAX) | ... % min of region is on tile
			(lonlim(2) >  XMIN & lonlim(2) <  XMAX)   ... % max of region is on tile
			)...
		);
	% concatenate indices
	do = [doEAST doWEST];
end
	
if ~isempty(do)
	fname = fnames(do);
else
	fname = [];
end

