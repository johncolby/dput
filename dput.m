function pastedata = dput(varargin)

pastedata = cell(nargin, 1);

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
if varnames
    pastedata = [varnames repmat(' = ', nargin, 1) pastedata repmat(';', nargin, 1)];
end