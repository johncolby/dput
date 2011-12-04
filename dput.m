function pastedata = dput(varargin)
%DPUT - Print ASCII representations of MATLAB variables
%This function emulates the 'dput' command in R. It makes ASCII
%representations of MATLAB variables, which can then be pasted into online
%forums, email, etc.. This makes it easy to distribute reproducible
%examples, without having to send along file attachments.
%
% Syntax: pastedata = dput(var1 [var2, ...])
%
% Inputs:
% var1, etc. - MATLAB variables. Currently supported classes for variables
%              (and for individual elements of structs and cells) are:
%              double, char, struct, and cell.
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
% mystruct = mystruct = struct('index', num2cell(1:3), 'color', {'red', 'blue', 'green'}, 'misc', {'string' 4 num2cell(magic(3))})
% mycell   = {1:3, 'test'; [], 1};
% dput(x, y, z, mystr, mystruct, mycell)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: http://stackoverflow.com/questions/8377575/is-there-an-equivalent-of-rs-dput-for-matlab/
%           http://stat.ethz.ch/R-manual/R-patched/library/base/html/dput.html

% Author: John Colby (johncolby@ucla.edu)
% Dec 2011

error(nargchk(1, Inf, nargin))

pastedata = cell(nargin, 1);

% Loop over input variables
for i=1:nargin
   vardata = varargin{i};
   
   switch class(vardata)
       case 'double'
           pastedata{i} = ['reshape([' sprintf('%f ', vardata) '],' '[' num2str(size(vardata)) '])'];
       
       case 'char'
           pastedata{i} = ['reshape(''' sprintf('%s', vardata) ''',' '[' num2str(size(vardata)) '])'];
       
       case 'cell'
           celldata = cell(length(vardata(:)), 1);
           for icell=1:length(vardata(:))
               celldata{icell} = dput(vardata{icell});
           end
           pastedata{i} = ['reshape({' sprintf('%s ', celldata{:}) '},' '[' num2str(size(vardata)) '])'];
       
       case 'struct'
           fields = fieldnames(vardata);
           fielddata = cell(length(fields), 1);
           for ifield=1:length(fields)
               vardata2 = {vardata.(fields{ifield})};
               celldata = cell(length(fields), 1);
               for icell=1:length(vardata2(:))
                   celldata{icell} = dput(vardata2{icell});
               end
               fielddata{ifield} = ['reshape({' sprintf('%s ', celldata{:}) '},' '[' num2str(size(vardata2)) '])'];
           end
           fielddata = [fields fielddata]';
           fielddata = ['struct(' sprintf('''%s'',%s,', fielddata{:})];
           pastedata{i} = [fielddata(1:(end-1)) ')'];
       
       otherwise
           pastedata{i} = '[]';
           warning(sprintf('''%s'' not written. Class ''%s'' not supported.', inputname(i), class(vardata)))
   end
end

varnames = char(arrayfun(@inputname, 1:nargin, 'UniformOutput', false));

pastedata = char(pastedata);

% If we're finished recursing, make final assignments
if varnames
    pastedata = [varnames repmat(' = ', nargin, 1) pastedata repmat(';', nargin, 1)];
end