function NEWFILE_LBox(varargin)

%%
%%	NEWFILE.M	Open a New Data File, Put Up First Trace
%%

global datafilepath datafilename HFmain;
FInfo = get(HFmain,'UserData'); 
HGUI = 	 FInfo(1,:);  

% Open File and Get Infoblock

if exist(datafilepath) == 7 
    if ~strcmp(datafilepath(end),'\')
        datafilepath = [datafilepath '\'];
    end
    eval(strcat('cd ''c:\',datafilepath(4:(length(datafilepath)-1)),''';'));    %need part after 4 spaces in quotes to accomodate spaces
else
    datafilepath = 'c:\';
    eval(strcat('cd c:\'));
end
      
Hlistbox = HGUI(21);
myfilelist = get(Hlistbox,'string');
myfile = myfilelist{get(Hlistbox,'Value')};
fileOK = 0;
datafilename = myfile;  % DEAL w/. THIS -- MBJ
datafile = [datafilepath datafilename];

while (fileOK == 0) 
	
	while isempty(datafilename)
		[datafilename,datafilepath] = uigetfile('*.*','Select Data File');
		datafile=[datafilepath datafilename];
    end
        datafileID = fopen(datafile,'rb');
        [dirblock,count]=fread(datafileID,256,'short');
        maxrun=dirblock(1);
    
	rnum = 1;
	infoADRS = 2*256*dirblock(rnum*2+1);
	status = fseek(datafileID,infoADRS,-1);
	[infoblock,count]=fread(datafileID,128,'short');

	if infoblock(1) == 32100
		fileOK = 1;
	else
		datafilename = 0;
	end
end

% Rename the Current Window to Datafilename

set(HFmain,'Name', datafilename);

% Set pointer to first sweep

swpnum = 1;

% Plot the Sweep and Create a Trace Object for It

plotswp(datafile, rnum, swpnum);

HGUI = 	 FInfo(1,:);        
Hinfobar = HGUI(22);

head = getheader();
mytext = head.raw;
%infostr = ['Run: ' num2str(rnum) '\t' num2str(maxrun) ',' mytext{1} ',' mytext{2} ',' mytext{3} ',' mytext{4}];
infostr = sprintf('Run: %2d/%2d     Internal: %s     External: %s     Comments: %s',rnum, maxrun, mytext{1},mytext{2},mytext{4});
set(Hinfobar,'string', infostr);
