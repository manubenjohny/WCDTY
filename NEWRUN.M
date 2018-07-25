function newrun(submenu)

%%
%%	NEWRUN.M	Allows Selection of a New Run in most recent datafile
%%
%%

global datafilepath datafilename HFmain;
global bubba ncount;

% Check that a file has been opened

datafile=[datafilepath datafilename];

if strcmp(datafilename,'0')
	errcall('OPEN A FILE FIRST');
	return;
end
	
% Clear bubba
clearbubba

% If file opened, then get maxrun and rnum of currently active sweep

Finfo = get(HFmain,'UserData');
TP = get(Finfo(2,2),'UserData');

rnum = TP(2,1);
maxrun = TP(2,2);

% Act according to the submenu selected

if strcmp(submenu,'back')
	
	if (rnum > 1) 
		rnum = rnum - 1;
	end
end

if strcmp(submenu,'jump')
	
	rnum=0;

	while (rnum < 1) | (rnum > maxrun)
 		
		s = ['Enter Run Number (Max ' num2str(maxrun) '): '];
		rnum = input(s);
	end
end

if strcmp(submenu,'next')
	
	if (rnum < maxrun) 
		rnum = rnum + 1;
	end

end

% Set pointer to first sweep

swpnum = 1;

% Plot the Sweep and Create a Trace Object for It

plotswp(datafile, rnum, swpnum);


HGUI = 	 Finfo(1,:);        
Hinfobar = HGUI(22);

head = getheader();
mytext = head.raw;
%infostr = ['Run: ' num2str(rnum) '\t' num2str(maxrun) ',' mytext{1} ',' mytext{2} ',' mytext{3} ',' mytext{4}];
infostr = sprintf('Run: %2d/%2d     Internal: %s     External: %s     Comments: %s',rnum, maxrun, mytext{1},mytext{2},mytext{4});
set(Hinfobar,'string', infostr);
global mCDI
if mCDI.flag == 1;
    manualCDI(3);    
end