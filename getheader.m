function head = getheader()
%% takes the final 128 integer-valued vector of infoblock% Returns the comments found in infoblock along with the times of:
%	- first sweep
%	- last sweep
%	- infoblock save
%%%%%% Open the file and get infoblock %%%%%%

global datafilepath datafilename HFmain;
%% Check that a file has been opened
datafile=[datafilepath datafilename];
if strcmp(datafilename,'0')
	errcall('OPEN A FILE FIRST');
	return;
end
	
%% If file opened, then get run number
FInfo = get(HFmain,'UserData'); 
hlines= FInfo(2,:);
TP = get(hlines(2),'UserData');			% current active sweep
rnum = TP(2,1);

%% Get dirblock and info block
datafileID = fopen(datafile,'rb');
[dirblock,count]=fread(datafileID,256,'short');
maxrun=dirblock(1);

infoADRS = dirblock(rnum*2+1);
status = fseek(datafileID,512*infoADRS,-1);
[infoblock,count]=fread(datafileID,256,'short');

%% Retrieve first and last sweep for purposes of getting the timestamp
maxswp = infoblock(1+1);			% number of sweeps
LF = infoblock(8+1);				% leak flag
NB = infoblock(13+1);				% number of blocks per sweep
CW  =    infoblock(46+1)/1000; % Whole cell capacitance
RS  =    infoblock(47+1)/100;  % Series resistance
if LF,	maxswp = maxswp/2; end

%% For first sweep (swpnum=1):
if LF,	traceADRS = infoADRS+2+NB+2*NB*(1-1);
else	traceADRS = infoADRS+2+NB+NB*(1-1);
end
fseek(datafileID,512*traceADRS,-1);
[dtrace0,count]=fread(datafileID,256*NB,'short');

%% For last sweep (swpnum=maxswp):
if LF,	traceADRS = infoADRS+2+NB+2*NB*(maxswp-1);
else	traceADRS = infoADRS+2+NB+NB*(maxswp-1);
end
fseek(datafileID,512*traceADRS,-1);
[dtrace1,count]=fread(datafileID,256*NB,'short');

fclose(datafileID);
headerinfo = infoblock(128:256);

mytext{1} = processtext(headerinfo(1:40));
mytext{2} = processtext(headerinfo(41:80));
mytext{3} = processtext(headerinfo(81:86));
mytext{4} = processtext(headerinfo(87:end));

Internal = mytext{1};
External = mytext{2};
curdate = mytext{3};
head = {};
try
    head = extractinfo(mytext{4});
catch
    disp('Error Interpreting the comment')
    disp(mytext{4})
end
head.raw = mytext;
if ~isfield(head,'rs')
    head.rs = RS;
end
if ~isfield(head,'cm')
    head.cm = CW;
end
if ~isfield(head,'comp')
    head.comp = '70%';
end
if ~isfield(head,'leak')
    head.leak = '???';
end
if ~isfield(head,'comment')
    head.comment = mytext{4};
end

mystr = sprintf('%s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s\t %s\t %s\t %s\t %s\n Comments:\t%s', datafilename,curdate(1:end-1),' ', num2str(rnum),' ',' ',num2str(head.rs),num2str(head.cm), num2str(head.comp), ...
                head.leak,' ',Internal,'TEA-MS',External,mytext{4});
% head

disp(mytext{1})
disp(mytext{2})
disp(mytext{3})
disp(mytext{4})

clipboard('copy',mystr);
function textstr = processtext(mytextarray)

%mytextarray = mytextarray(mytextarray>32);
%mytextarray = mytextarray(mytextarray~=0);
A = floor(mytextarray/256);
B = mod(mytextarray, 256);
tempcharmat = reshape([B A]',length(A)*2,1)';
textstr = char(tempcharmat(tempcharmat>31));

function head = extractinfo(mystr)
% % REPLACE THIS W/ APPROPRIATE FORMAT. 
% delimitpos = findstr(mystr, ',');
% head.construct = mystr(1:delimitpos(1)-1); %assume by default that this is construct
% leakpos = findstr(mystr,'leak')+4;
% leaktxt min(delimitpos(delimitpos>leakpos))
% 
% head.leak
% cellnumpos = findstr(mystr,'cell')+4;

% First Search for  tagged fields like Cell Number, leak etc
tagged    = {'cell', 'leak','rs','cm','comp'}; % add more fields if you'd like
untagged  = {'construct', 'comment'}; % add more fields

tag_str = {{'cell', 'cellnum'}, {'leak','lk'},{'rs'},{'cm'},{'comp'}};
mystr = lower(mystr);
% FIND POSITION OF EACH POTENTIAL FIELD
mydelimiter = {',',';'};
fieldpos = [];
for i = 1:length(mydelimiter)
    fieldpos = [fieldpos findstr(mystr,mydelimiter{i})];
end
fieldpos = sort(fieldpos);
if fieldpos(1)~= 1 
    fieldpos = [0 fieldpos];
else
    fieldpos(1) = 0;
end
if fieldpos(end)~=length(mystr)+1
    fieldpos = [fieldpos length(mystr)+1];
end
numtagged = 0;
% NOW SEARCH FOR TAGGED FIELDS
for i = 1:length(tagged)
    [temp_str temp_pos] = searchfield(mystr, fieldpos, tag_str{i}, tagged{i});
    if ~isempty(temp_str)
        head.(tagged{i}) = temp_str;
        numtagged = numtagged+1;
        tagged_field(numtagged) = find(fieldpos == max(fieldpos(fieldpos<temp_pos)));
    end
end
% NOW DEAL W/ UNTAGGED FIELDS -- the initial field is construct and final
% comment
myfields = 1:length(fieldpos)-1;
nuntaggedfield = 0;
for i = myfields
    if ~(sum(myfields(i) == tagged_field)>0)
        nuntaggedfield = nuntaggedfield+1;
        untagged{nuntaggedfield} = deblank(strtrim(mystr(fieldpos(i)+1:fieldpos(i+1)-1)));
    end
end
head.construct = deblank(strtrim(untagged{1}));
head.comment = [];

head.comment = deblank(strtrim(sprintf('%s\t',untagged{2:end})));


function [fielddata, fieldtxtpos] = searchfield(mystr, fieldpos, fieldtxt, fieldname)
    % let us do an initial search for the text(s)  and then categorize it
    % to a field t
    fieldtxtpos = [];
    for i = 1:length(fieldtxt)
        fieldtxtpos = [fieldtxtpos findstr(mystr,fieldtxt{i})];
    end
    if isempty(fieldtxtpos)
        fielddata = ''; %Return empty field
        return;
    end
    % Remove any repition that may exist.
    fieldtxtpos = sort(fieldtxtpos);
    fieldtxtpos = fieldtxtpos([boolean(1) diff(fieldtxtpos)>0]);
    
    % OK So we have the position of possible culprit fields but which ones
    % are real? To do so we extract the possible fieldvalues:
    % min(fieldpos(fieldpos>fieldtxtpos(i)))-1 is the end of position
    fieldvalid = ones(size(fieldtxtpos));
    for i = 1:length(fieldtxtpos)
        endfield(i) = min(fieldpos(fieldpos>fieldtxtpos(i)))-1;
        spacepos(i) = findstr(mystr(fieldtxtpos(i): endfield),' ');
        fieldval{i} = mystr(fieldtxtpos(i)+spacepos(i):endfield);
        fieldval{i} = strtrim(deblank(fieldval{i}));
        if isnumeric(str2num(fieldval{i}(1:min(2,length(fieldval{i}))))) || isnumeric(str2num(fieldval{i}(1)))
            fieldvald(i) = 1;
        else
            fieldvald(i) = 0;            
        end
    end
    fieldvalid = boolean(fieldvalid);
    fieldval = fieldval(fieldvalid);
    fielddata = fieldval{1};
   