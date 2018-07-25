function newswp(submenu)

%%
%%	NEWSWP.M	Allows Selection of a New Run in most recent datafile
%%
%%

global datafilepath datafilename HFmain;


% Check that a file has been opened

datafile=[datafilepath datafilename];

if strcmp(datafilename,'0')
	errcall('OPEN A FILE FIRST');
	return;
end
	

% If file opened, then get maxswp and swpnum of currently active sweep

FInfo = get(HFmain,'UserData'); 
hlines= FInfo(2,:);
TP = get(hlines(2),'UserData');			% current active sweep

rnum = TP(2,1);
swpnum = TP(2,3);
maxswp = TP(2,4);


% Act according to the submenu selected

if strcmp(submenu,'back')
	
	if (swpnum > 1) 
		swpnum = swpnum - 1;
	end
end

if strcmp(submenu,'jump')
	
	swpnum=0;

	while (swpnum < 1) | (swpnum > maxswp)
 		
		s = ['Enter Sweep Number (Max ' num2str(maxswp) '): '];
		swpnum = input(s);
	end
end

if strcmp(submenu,'next')
	
	if (swpnum < maxswp) 
		swpnum = swpnum + 1;
	end

end

if strcmp(submenu,'skip')
	
	if (swpnum + 1 < maxswp) 
		swpnum = swpnum + 2;
	end

end

% Plot the Sweep and Create a Trace Object for It

plotswp(datafile, rnum, swpnum);

global mCDI
if mCDI.flag == 1;
    manualCDI(3);    
end