function holdswp(submenu)

%%
%%	HOLDSWP.M	Keeps sweep or wipes kept sweeps
%%
%%

global datafilepath datafilename HFmain;


% Check that a file has been opened

datafile=[datafilepath datafilename];

if strcmp(datafilename,'0')
	errcall('OPEN A FILE FIRST');
	return;
end
	

% Get handles for lines

FInfo = get(HFmain,'UserData');
hlines = FInfo(2,:);

TP = get(hlines(2),'UserData');			% current active sweep

rnum = TP(2,1);
swpnum = TP(2,3);

% Act according to the submenu selected

if strcmp(submenu,'keep')
	
	current = hlines(2);
	set(current,'Color',[.7 .7 1]);
	
	hlines(1) = hlines(1)+1;		% increment # kept sweeps
	hlines(2) = 0;				% no unkept current sweep
	hlines(hlines(1)+2)=current;		% save handle of kept sweep
	
end

if strcmp(submenu,'wipe')
	
	current = hlines(2);	
	keptswps = nonzeros(hlines(3:length(hlines)));
	delete(keptswps);

	hlines = zeros(size(hlines));
	hlines(2)=current;
	
end

% Update FInfo

FInfo(2,:)=hlines;
set(HFmain,'UserData',FInfo);

% Plot Sweep

plotswp(datafile,rnum,swpnum);
