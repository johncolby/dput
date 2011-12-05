function pastedata = dput(varargin)
%DPUT - Print ASCII representations of MATLAB variables
%This function emulates the 'dput' command in R. It makes ASCII
%representations of MATLAB variables, which can then be pasted into online
%forums, email, etc.. This makes it easy to distribute reproducible
%examples, without having to send along file attachments.
%
% Syntax: pastedata = dput(var1 [, var2, ...] [, 'precision', precision])
%
% Inputs:
% var1, etc. - MATLAB variables. Currently supported classes for variables
%              (and for individual elements of structs and cells) are:
%              double (including complex), logical, char, struct, cell,
%              int*, uint*.
% precision  - (optional) Name-value pair specifying decimal precision for 
%              floats (Default: 6) 
%
% Outputs:
% pastedata - A paste-able ASCII representation of the input variables.
%             Unsupported types are returned as [].
%
% Example:
% x        = 1:10;
% y        = 3;
% z        = magic(3);
% mystr    = ['line1'; 'line2'];
% mystruct = struct('index', num2cell(1:3), 'color', {'red', 'blue',...
%            'green'}, 'misc', {'string' 4 num2cell(magic(3))});
% mycell   = {1:3, 'test'; [], 1};
% mask     = logical(randi([0 1], 3));
% bigint   = intmax('uint64');
% dput(x, y, z, mystr, mystruct, mycell, mask, bigint)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: CLASS, TEST_DPUT
%           http://github.com/johncolby/dput
%           http://stackoverflow.com/questions/8377575/is-there-an-equivalent-of-rs-dput-for-matlab/
%           http://stat.ethz.ch/R-manual/R-patched/library/base/html/dput.html

% Author: John Colby (johncolby@ucla.edu)
% Dec 2011

nargs = nargin;
error(nargchk(1, Inf, nargs))

% Assign custom precision value (if given and not in recursive mode)
persistent precision
if any(strcmp('precision', varargin))
    ind = find(strcmp('precision', varargin));
    precision = varargin{ind+1};
    varargin([ind ind+1]) = [];
    nargs = nargs - 2;
elseif isempty(precision)
    precision = 6;
end

pastedata = cell(nargs, 1);

% Loop over input variables
for i=1:nargs
   vardata = varargin{i};
   
   switch class(vardata)
       case 'double'
           if isreal(vardata)
               pastedata{i} = ['reshape([' sprintf('%.*f ', [repmat(precision, length(vardata(:)), 1) vardata(:)]') '],' '[' num2str(size(vardata)) '])'];
           else
               pastedata{i} = ['reshape([' sprintf('%.*f+%.*fi ', [repmat(precision, length(vardata(:)), 1) vardata(:) repmat(precision, length(vardata(:)), 1) imag(vardata(:))]') '],' '[' num2str(size(vardata)) '])'];
           end
           
       case 'char'
           pastedata{i} = ['reshape(''' sprintf('%s', vardata) ''',' '[' num2str(size(vardata)) '])'];
       
       case 'cell'
           celldata = cellfun(@dput, vardata, 'UniformOutput', false);
           pastedata{i} = ['reshape({' sprintf('%s ', celldata{:}) '},' '[' num2str(size(vardata)) '])'];
       
       case 'struct'
           fields = fieldnames(vardata);
           vardata = mat2cell(squeeze(struct2cell(vardata)), ones(1, length(fields)), length(fields));
           fielddata = cellfun(@dput, vardata, 'UniformOutput', false);
           fielddata = [fields fielddata]';
           fielddata = ['struct(' sprintf('''%s'',%s,', fielddata{:})];
           pastedata{i} = [fielddata(1:(end-1)) ')'];
       
       case {'logical', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32' 'int64'}
           pastedata{i} = [class(vardata) '(reshape([' sprintf('%ld ', vardata) '],' '[' num2str(size(vardata)) ']))'];
       
       case 'uint64'
           pastedata{i} = [class(vardata) '(reshape([' sprintf('%lu ', vardata) '],' '[' num2str(size(vardata)) ']))'];
           
       otherwise
           pastedata{i} = '[]';
           warning(sprintf('''%s'' not written. Class ''%s'' not supported.', inputname(i), class(vardata)))
   end
end

clear precision
varnames = char(arrayfun(@inputname, 1:nargs, 'UniformOutput', false));

pastedata = char(pastedata);

% If we're finished recursing, make final assignments
if varnames
    pastedata = [varnames repmat(' = ', nargs, 1) pastedata repmat(';', nargs, 1)];
end