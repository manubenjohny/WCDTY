function plotavg1 

%%
%%	PLOTAVG1.M 	This function plots a sweep on current axes given the
%%			datafile name, run number, and sweep number. Also performs
%%			isochronal measurement and displays result.
%%			

global FInfo Hlines;
global rnum maxswp infoblock dtrace NB;
global datafilepath datafilename;
global HFmain			% handle to main figure window

%% Get Key Handles 

FInfo = get(HFmain,'UserData');		% FInfo has detailed information about main figure window
HMavg1 = FInfo(1,18);			% Handle for avg1 button in main figure window
FInfo1 = get(HMavg1,'UserData');	% FInfo1 has detailed information about avg1 button in main figure window
					% [window created/not; #traces averaged so far; handle for avg1 figure; handle for trace in avg1 figure]
HFavg1 = FInfo1(1,3);			% Handle to avg1 figure



%% Create fake inputs to function

datafile=[datafilepath datafilename];	%required input

FInfo = get(HFmain,'UserData'); 
hlines= FInfo(2,:);
TP = get(hlines(2),'UserData');			% current active sweep

rnum = TP(2,1);				%required input
swpnum = TP(2,3);			%required input


%%
%% 	GET FIGURE INFORMATION AND REFRESH SCREEN
%%

figure(HFmain)
FInfo = get(HFmain,'UserData');

HGUI = 	 FInfo(1,:);			% GUI Handles
Hlines = FInfo(2,:);			% Line Handles
Hdel= 	 FInfo(4,:);			% Objects to Delete for Refresh

if (Hdel(1) ~= 0)
	delete(nonzeros(Hdel(2:length(Hdel))));
end

Hdel = zeros(size(FInfo(4,:)));	

%%
%%	GET INFORMATION FROM THE DATAFILE
%%


% Open the datafile to get all needed information


	datafileID = fopen(datafile,'rb');
	[dirblock,count]=fread(datafileID,256,'short');

	maxrun=dirblock(1);
	
	infoADRS = dirblock(rnum*2+1);
	status = fseek(datafileID,512*infoADRS,-1);
	[infoblock,count]=fread(datafileID,128,'short');

	fclose(datafileID);


% Calculate Intermediate Variables for the Run (Used to Calculate TracePrint)

	maxswp = 	infoblock(1+1);			% number of sweeps
	VH =		infoblock(2+1);			% holding potential
	I = 		infoblock(6+1);			% sample interval (usec)
	G = 		infoblock(7+1)/10;		% gain (mV/pA)
	LF = 		infoblock(8+1);			% leak flag

	if LF
		maxswp = maxswp/2;
	end;

	NB =		infoblock(13+1);		% number of blocks per sweep
	PR =		infoblock(15+1);		% points before first pulse
	ST =		infoblock(18+1);		% sample type (0-step, 1-ramp, 2-family)
	NI =		infoblock(19+1);		% variable changed in family
	HZ =		infoblock(21+1);		% lopass filter frequency

	family(1:3)=	infoblock(23:25);		% Family start,stop,increment
	PV(1:8) =	infoblock(29:36);		% Pulse Block PV(NI-3) incremented in family

	DE1 =		infoblock(38+1);		% First pulse saved
	DE2 =		infoblock(39+1);		% Last pulse saved

	
	if (PR == 0)

		PR = 1;
	end

	if (HZ == 0)

		PF = 0;
	else


		PF = 	1000*(3.48*exp(-HZ/150)+ ...
			0.73*exp(-HZ/650)+ ...
			0.2*exp(-HZ/2700)+ ...
			0.032*exp(-HZ/43500));

		PF = round(PF/infoblock(6+1));
	end

	
%%
%%
%%	GET TRACE AND PERFORM LEAK SUBTRACTION (Determined by Flags)
%%
%%

% No Interpulse leaks

	HFavg1_line = FInfo1(1,4);
	dtrace = get(HFavg1_line,'ydata');

%%
%%	PLOT THE (LEAK SUBTRACTED AND ZEROED) TRACE 
%%

pAtrace = dtrace;
time = I/1000*([1:NB*256]-(PR+PF+1));		% PR+PF+1 is where first pulse starts

if getFLAG('lock')
	set(gca,'XLimMode','manual','YLimMode','manual');
else
	set(gca,'XLimMode','auto','YLimMode','auto');
end

if (Hlines(2) == 0)							% Hlines(2) = current trace

	HIDline = line(time(1:NB*256-12),pAtrace(1:NB*256-12));
	Hlines(2) = HIDline;
else
	current=Hlines(2);
	delete(current);

	HIDline = line(time(1:NB*256-12),pAtrace(1:NB*256-12));
	Hlines(2) = HIDline;
end

if ~getFLAG('lock')
	xlimits = get(gca,'Xlim');
	xlimits(1) = round(-(PR+PF)*I/1000);
	xlimits(2) = sum(PV(5:8));
	set(gca,'Xlim',xlimits);
end


%%
%%	CREATE THE TRACEPRINT 
%%	
%%		The TracePrint is information stored in the UserData area of 
%%		each displayed sweep. The figure UserData is updated with the
%%		handle of the plotted trace.
%%
%%	TP: 	Row 1: Vector of ASCII values for filename
%%	    	Row 2: Vector for File Localization	
%%		Row 3: Vector of Details about the Trace (Trace Block) 
%%

TP = zeros(3,100);

TPName = abs(datafile);		% Row Vector With ASCII values of datafilename

TPVect = [rnum maxrun swpnum maxswp infoADRS NB ];

TBlock= zeros(1,100);

	TBlock(1) = DE1;		% First Saved Pulse
	TBlock(2) = DE2;  		% Last Saved Pulse

	TBlock(3) = VH;  		% Holding Potential

	TBlock(4) = PV(1);  		% V1 (mV)
	TBlock(5) = PV(2);  		% V2
	TBlock(6) = PV(3);  		% V3
	TBlock(7) = PV(4);  		% V4

	TBlock(8) = PV(5);  		% D1 (ms)
	TBlock(9) = PV(6);  		% D2
	TBlock(10) = PV(7);  		% D3
	TBlock(11) = PV(8);  		% D4

	TBlock(12) = 0; %dtrace(NB*256-1);			% patch Value of Familied Variable

	TBlock(13) = 0;  				% Offset (in points) of initial region
	TBlock(14) = PR+PF;  				% Length (in points) of initial region
	TBlock(15) = TBlock(14)+1;			% Location of Start Pulse 1 (points)
	TBlock(16) = TBlock(15)+round(PV(5)*1000/I);	% Location of Start Pulse 2 (points)	
	TBlock(17) = TBlock(16)+round(PV(6)*1000/I);	% Location of Start Pulse 3 (points)
	TBlock(18) = TBlock(17)+round(PV(7)*1000/I);	% Location of Start Pulse 4 (points)
	TBlock(19) = TBlock(18)+round(PV(8)*1000/I)-1;	% Last Point of Pulse 4

	TBlock(20) = I;
	TBlock(21) = G;

TP(1,1:length(TPName)) = TPName;
TP(2,1:length(TPVect)) = TPVect;
TP(3,1:length(TBlock)) = TBlock;

set(HIDline,'UserData',TP);


%%
%%	USING TRACEPRINT INFORMATION AND THE PLOTTED TRACE, DO ANY PROCESSING
%%
%%

% Put Information into the Two Text Boxes for current trace (HTW1 and HTW2)

HTW1 = HGUI(5);
HTW2 = HGUI(6);

set(	HTW1,... 
	'String', 	['Run: '   num2str(TPVect(1))   '  ' ...
		     	 'Swp: '   num2str(TPVect(3)) '  '...
		     	 '('      num2str(TBlock(12)) ')'],...
	'Visible', 'on');


if getFLAG('info')
	
	set(	HTW2,... 
		'String',	['V: ' num2str(TBlock(4)) ' ' num2str(TBlock(5))...
				 ' '   num2str(TBlock(6)) ' ' num2str(TBlock(7)) '|'...
				 'D: ' num2str(TBlock(8)) ' ' num2str(TBlock(9))...
				 ' '   num2str(TBlock(10)) ' ' num2str(TBlock(11))],...
		'Visible','on');
else
	set(	HTW2, 'String','','Visible','off');
end


% Isochronal Measurements on current trace

if getFLAG('isotool')

	HMiso = HGUI(8);
	HBisoCon = HGUI(17);
	conString = get(HBisoCon,'String');

	A = get(HMiso, 'UserData');	% Each Row is [pulse start stop incP incStart incStop]
	W = A(:,1:3);			% Pull out [pulse start stop]
	
	values = zeros(1,length(nonzeros(W(:,1))));
	count = 1;

	pAtrace = get(HIDline,'YData');
	T = get(HIDline,'XData');
	
	YLim = get(gca, 'YLim');

	while (W(count,1) ~= 0)
		
		pulse = W(count,1);	% 1-4 Normal, 5-8 Peaks
					% 9-12 Normal Auto Increment, 13-16 Peaks Auto Increment
		
		pulse = (pulse-floor((pulse-1)/4)*4); %modulo of sorts

		if (W(count,1) >= 9)
			t1 = W(count,2)+TBlock(12);
			t2 = W(count,3)+TBlock(12);

		else
			t1 = W(count,2);
			t2 = W(count,3);
		end
		
		
		startpoint = TBlock(14+pulse)+round(t1*1000/TBlock(20)); 
		endpoint = TBlock(14+pulse)+round(t2*1000/TBlock(20));
		
		if strcmp(conString,'Pk: Tail')
			consize = 4;			% Four Point Peak Definition (for tails)
		end

		if strcmp(conString,'Pk: Pulse')
			consize = round(2000/I);	% Find Peak (as 2 ms region)
		end

		if ((W(count,1)-floor((W(count,1)-1)/8)*8) >= 5)
			
			minI = min(conv(ones(1,consize)/consize,[zeros(1,consize) pAtrace(startpoint:endpoint) zeros(1,consize)]));
			maxI = max(conv(ones(1,consize)/consize,[zeros(1,consize) pAtrace(startpoint:endpoint) zeros(1,consize)]));
			
			if abs(minI) > abs(maxI)
				values(count)=minI;		
			else
				values(count)=maxI;
			end

		else 
			values(count) = mean(pAtrace(startpoint:endpoint));
		end

		Hline1 = line([T(startpoint) T(startpoint)], [YLim(1) YLim(2)],'Color',[0 0 1]);
		Hline2 = line([T(endpoint) T(endpoint)], [YLim(1) YLim(2)],'Color',[0 0 1]);

		Hdel(Hdel(1)+2)= Hline1;
		Hdel(Hdel(1)+3)= Hline2;
		Hdel(1) = Hdel(1) + 2;
		
		count = count + 1;
	end
	
	fprintf(1,'%6.1f\t',values(1:length(values)-1)),fprintf(1,'%6.1f\n',values(length(values)));

end


%%
%%	Update the Figure Information (UserData) (Key to FInfo in WCINIT)
%%

FInfo = get(HFmain,'UserData');				% Get UserData Matrix (handles for GUI and traces)
FInfo(1,:)=HGUI;					% GUI Handles
FInfo(2,:)=Hlines;					% Line Handles
FInfo(4,:)=Hdel;					% Objects to Delete for Refresh
set(HFmain,'UserData', FInfo);				% Write to UserData