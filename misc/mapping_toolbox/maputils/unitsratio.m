function ratio = unitsratio(to, from)
%UNITSRATIO Unit conversion factors
%
%   RATIO = UNITSRATIO(TO, FROM) returns the number of TO units per one
%   FROM unit.  For example, UNITSRATIO('cm', 'm') returns 100 because
%   there are 100 centimeters per meter.  UNITSRATIO makes it easy to
%   convert from one system of units to another.  Specifically, if X is
%   in units FROM and
%
%                  Y = UNITSRATIO(TO, FROM) * X,
%
%   then Y is in units TO.
%
%   TO and FROM may be any strings from the second column of one of the
%   following tables. (Both must come from the same table.)  TO and FROM
%   are case-insensitive and may be either singular or plural.
%
%   Units of Length
%   ---------------
%
%     Unit Name            String(s)
%     ---------            ---------
%     meter                'm', 'meter(s)', 'metre(s)'
%
%     centimeter           'cm', 'centimeter(s)', 'centimetre(s)'
%
%     millimeter           'mm', 'millimeter(s)', 'millimetre(s)'
%
%     micron               'micron(s)'
%
%     kilometer            'km', 'kilometer(s)', 'kilometre(s)'
%
%     nautical mile        'nm', 'naut mi', 'nautical mile(s)
%
%     international foot   'ft',   'international ft',
%                          'foot', 'international foot',
%                          'feet', 'international feet'
%
%     inch                 'in', 'inch', 'inches'
%
%     yard                 'yd', 'yard(s)'
%
%     international mile   'mi', 'mile(s)', 'international mile(s)'
%
%     U.S. survey foot     'sf',
%                          'survey ft',   'U.S. survey ft',
%                          'survey foot', 'U.S. survey foot',
%                          'survey feet', 'U.S. survey feet',
%
%     U.S. survey mile     'sm', 'survey mile(s)', 'statute mile(s)',
%     (statute mile)       'U.S. survey mile(s)'
%
%
%   Units of Angle
%   ---------------
%
%     Unit Name            String(s)
%     ---------            ---------
%     radian               'rad', 'radian(s)'
%     degree               'deg', 'degree(s)'
%
%
%   Examples
%   --------
%   % Approximate mean earth radius in meters
%   radiusInMeters = 6371000
%   % Conversion factor
%   feetPerMeter = unitsratio('feet', 'meter')
%   % Radius in (international) feet:
%   radiusInFeet = feetPerMeter * radiusInMeters
%
%   % The following prints a true statement for any valid TO, FROM pair:
%   to   = 'feet';
%   from = 'mile';
%   sprintf('There are %g %s per %s.', unitsratio(to,from), to, from)
%
%   % The following prints a true statement for any valid TO, FROM pair:
%   to   = 'degrees';
%   from = 'radian';
%   sprintf('One %s is %g %s.', from, unitsratio(to,from), to)

% Copyright 2002-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2010/09/13 16:22:41 $

% Exact definitions: Each unit on the left is defined in terms of the unit
% on the right via the factor provided, which is the value that will be
% computed by 1 / UNITSRATIO(LEFT,RIGHT).   [Note the inverse.]
% (All strings must be in lower case only.)

validateattributes(to,  {'char'},{'nonempty','row'},'UNITSRATIO','TO',1)
validateattributes(from,{'char'},{'nonempty','row'},'UNITSRATIO','FROM',2)

definitions = {...
  'micron',     'm',   1e-6;
      'mm',     'm',   1e-3;...
      'cm',     'm',   1e-2;...
      'km',     'm',   1e+3;...
      'nm',     'm',   1852;...
      'ft',     'm',   0.3048;...
      'sf',     'm',   1200/3937;...
      'mi',    'ft',   5280;...
      'sm',    'sf',   5280;...
      'in',    'ft',   1/12;...
      'yd',    'ft',   3;...
     'deg',   'rad',   pi/180 };

% Synonyms: Values of TO and FROM found in the left hand column are
% are converted to the corresponding values in the right hand column.
% (All strings must be in lower case only.)
synonyms = {...
                'microns',  'micron';...
                  'meter',       'm';...
                  'metre',       'm';...
             'centimeter',      'cm';...
             'centimetre',      'cm';...
             'millimeter',      'mm';...
             'millimetre',      'mm';...
              'kilometer',      'km';...
              'kilometre',      'km';...
           'nauticalmile',      'nm';...
                 'nautmi',      'nm';...
                   'inch',      'in';...
                 'inches',      'in';...
                   'yard',      'yd';...
        'internationalft',      'ft';...
                   'foot',      'ft';...
      'internationalfoot',      'ft';...
                   'feet',      'ft';...
      'internationalfeet',      'ft';...
                   'mile',      'mi';...
      'internationalmile',      'mi';...
               'surveyft',      'sf';...
           'u.s.surveyft',      'sf';...
             'surveyfoot',      'sf';...
         'u.s.surveyfoot',      'sf';...
             'surveyfeet',      'sf';...
         'u.s.surveyfeet',      'sf';...
             'surveymile',      'sm';...
            'statutemile',      'sm';...
         'u.s.surveymile',      'sm';...
                 'radian',     'rad';...
                 'degree',     'deg' };

% Check class of TO and FROM and attempt to convert synomyms
% to 'standard abbreviations', if necessary.
[to, from] = parseInputs(to, from, definitions, synonyms);

% Do a depth-first search of the directed graph corresponding
% to the definitions array, recursively searching for a
% path from FROM to TO.
ratio = searchgraph(to, from, definitions, {});

% A return value of NaN in RATIO indicates that no connection exists.
if isnan(ratio)
    error('Shared:maputils:unableToConvertUnits', ...
        'Unable to convert to %s from %s.', to, from);
end

%-------------------------------------------------------------------

function [to, from] = parseInputs(to, from, definitions, synonyms)

% Extract a list of the units included in the definitions array.
units = definitions(:,1:2);
units = unique(units(:));

% Ensure case-insensitivity.
to   = lower(to);
from = lower(from);

% Ignore any white space characters.
to(isspace(to)) = [];
from(isspace(from)) = [];

% Look for exact matches in the units list; if necessary,
% check the synonyms table.
if ~any(strcmp(to, units))
    to = findSynonym(to, synonyms);
end    

if ~any(strcmp(from, units))
    from = findSynonym(from, synonyms);
end    

%-------------------------------------------------------------------

function unit = findSynonym(unit, synonyms)

% See if there's an exact match.
k = find(strcmp(unit, synonyms(:,1)));
if ~isempty(k)
    unit = synonyms{k,2};
else
    % See if there's an exact match after stripping off a trailing 's'.
    k = find(strcmp(unit(1:end-1), synonyms(:,1)));
    if (unit(end) == 's') && ~isempty(k)
        unit = synonyms{k,2};
    else
        % No match with or without trailing 's'.
        error('Shared:maputils:unsupportedUnit', ...
            'Unit %s is not supported.', unit);
    end
end

%-------------------------------------------------------------------

function [ratio, history] = searchgraph(to, from, graph, history)

% Assume a dead-end unless/until a path is found from FROM to TO.
ratio = NaN;

% Stop here if FROM has already been checked (avoid loops in the graph).
if any(strcmp(from,history))
    return;
end

% Append FROM to the list of nodes that have been visited.
history{end+1} = from;

% Find occurrences of FROM and TO in columns 1 and 2 of GRAPH.
from1 = find(strcmp(from, graph(:,1)));
from2 = find(strcmp(from, graph(:,2)));
to1   = find(strcmp(to,   graph(:,1)));
to2   = find(strcmp(to,   graph(:,2)));

% See if there's a direct conversion from TO to FROM:
% If there's a row with TO in column 1 and FROM in column 2, then
% column 3 of that row contains the conversion factor
% from FROM to TO.
i = intersect(to1, from2);
if numel(i) == 1
    ratio = 1 / graph{i,3};
    return;
end

% See if there's a direct conversion from FROM to TO:
% If there's a row with FROM in column 1 and TO in column 2,
% then column 3 of that row contains the conversion factor.
i = intersect(to2, from1);
if numel(i) == 1
    ratio = graph{i,3};
    return;
end

% Recursively search for conversion to TO from each node adjacent
% to FROM.

% Search from the adjacent nodes with a direct conversion _from_
% FROM.  If a conversion factor (non-NaN) to TO is found from
% one of these adjacent nodes, then multiply it by the conversion
% factor from FROM to that neighbor (divide by the defining
% factor in column 3 of GRAPH).
for i = 1:numel(from2)
   n = from2(i);
   [ratio, history] = searchgraph(to, graph{n,1}, graph, history);
   if ~isnan(ratio)
       ratio = ratio / graph{n,3};
       return;
   end
end

% Search from the adjacent nodes with a direct conversion _to_ FROM.
% If a conversion factor (non-NaN) to TO is found from one of these
% adjacent nodes, then divide it by the conversion factor from FROM
% to that neighbor (multiply by the defining factor in column 3).
for i = 1:numel(from1)
   n = from1(i);
   [ratio, history] = searchgraph(to, graph{n,2}, graph, history);
   if ~isnan(ratio)
       ratio = ratio * graph{n,3};
       return;
   end
end
