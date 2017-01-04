function s=csv2struct(filename)
headerList = textread(filename,'%s',1);
headerList = headerList{1};
M = csvread(filename,1,0);
i = 0;
while ~isempty(headerList)
   i = i+1;
   [header,headerList] = strtok(headerList,',');
   eval(['s.' header '= M(:,i);']);
end