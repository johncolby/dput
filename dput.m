function pastedata = dput(vars)

pastedata = cell(length(vars), 1);

for i=1:length(vars)
   vardata = evalin('caller', vars{i});
   
   switch class(vardata)
       case 'double'
           pastedata{i} = [vars{i} '=' 'reshape([' sprintf('%f ', vardata) '],' '[' num2str(size(vardata)) ']);'];
       case 'char'
           pastedata{i} = [vars{i} '=' 'reshape(''' sprintf('%s', vardata) ''',' '[' num2str(size(vardata)) ']);'];
       otherwise
           pastedata{i} = '';
           warning(sprintf('''%s'' not written. Class ''%s'' not supported.', vars{i}, class(vardata)))
   end
end

pastedata = char(pastedata);