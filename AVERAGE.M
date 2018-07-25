function average(submenu)

%%
%%	AVERAGE accumulates running average in separate figure window
%%		in conjunction with PGP wc program.

global HFmain			%% handle to main figure window

%% Get Key Handles 

FInfo = get(HFmain,'UserData');		% FInfo has detailed information about main figure window
HMavg1 = FInfo(1,18);			% Handle for avg1 button in main figure window
HMavgclear = FInfo(1,19);		% Handle for clear average window button in main figure window
FInfo1 = get(HMavg1,'UserData');	% FInfo1 has detailed information about avg1 button in main figure window
					% [window created/not; #traces averaged so far; handle for avg1 figure; handle for trace in avg1 figure]
figure(HFmain)
xlimits = get(gca,'Xlim');
set(gca,'Xlim',xlimits);

Naveraged = 0;



%% Make decisions on what to do

if strcmp(submenu,'avg1')
	
	if (FInfo1(1,1)==0) 				% check to see if avg1 figure window doesn't exist

		HFavg1=figure(	'Name',	'Running Average 1', ...
		'NumberTitle', 'off', ...
		'Units', 'normal',...
		'Position', [.60 .33 .66 .60],...
		'UserData', [0 0 0] );
		HFaxis = subplot(1,1,1);
		

		FInfo1(1,1) = 1;			% Figure flag ON
		Naveraged = 1;
		FInfo1(1,2) = Naveraged;		% Zero counter of No averaged traces
		FInfo1(1,3) = HFavg1;			% Store handle to figure
		set(HMavg1,'UserData', FInfo1);		% Update UserData of avg1 button

		%% Get current trace

		kids = FInfo(2,2);
		ynew = get(kids,'ydata');
		xdata = get(kids,'xdata');
		yupdate = ynew;

	elseif (FInfo1(1,1)==1)				% if avg1 figure window already exists
		
		HFavg1 = FInfo1(1,3);			% get handle for avg1 figure window
		figure(HFavg1)				% make avg1 figure window current
		Naveraged = FInfo1(1,2);		% read in the number of traces averaged so far

		%% Update average

		Naveraged = Naveraged + 1;
		FInfo1(1,2) = Naveraged;		% Update FInfor for new averaged traces
		set(HMavg1,'UserData', FInfo1);		% Update UserData for avg 1 button

		%% Get current trace

		kids = FInfo(2,2);
		ynew = get(kids,'ydata');
		xdata = get(kids,'xdata');

		%% Get old average
		
		kidsold = get(gca,'children');
		yold = get(kidsold,'ydata');

		%% Update average

		yupdate = yold * (Naveraged -1) / Naveraged + ynew / Naveraged;

	end

	%% update plot in trace

	if (Naveraged == 1)				% if this is the first trace to be plotted

		HFavg1_line = line('xdata', xdata,'ydata', yupdate,'erasemode','xor', 'color', 'y');
		FInfo1(1,4) = HFavg1_line;
		set(HMavg1,'Userdata',FInfo1);
	else
		HFavg1_line = FInfo1(1,4);
		set(HFavg1_line,'xdata', xdata, 'ydata', yupdate);
	end
	set(gca,'Xlim',xlimits);

end

if strcmp(submenu,'avgclear')
	
	if (FInfo1(1,1)==1)
		
		HFavg1 = FInfo1(1,3);
		delete(figure(HFavg1))
		FInfo1(1,1)=0;
		set(HMavg1,'UserData', FInfo1);		% Write to UserData

	end
end




figure(HFmain)