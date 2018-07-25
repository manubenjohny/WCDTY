function dispswp(datafile,runnumber,swpnum);

%%
%%	DISPSWP.M 	This function plots a sweep on current axes given the
%%			datafile name, run number, and sweep number. It does
%%			not perform a lot of excess analysis 
%%			

global rnum maxswp infoblock;
global HIDline pAtrace values startpoint endpoint TBlock t1 t2 count W pulse;
rnum = runnumber;


%%
%% 	GET FIGURE INFORMATION AND REFRESH SCREEN
%%

FInfo = get(gcf,'UserData');

HGUI = 	 FInfo(1,:);			% GUI Handles
Hlines = FInfo(2,:);			% Line Handles
Hdel= 	 FInfo(4,:);			% Objects to Delete for Refresh

if (Hdel(1) ~= 0)
	delete(nonzeros(Hdel(2:length(Hdel))));
end

FInfo(4,:) = zeros(size(FInfo(4,:)));	
set(gcf,'UserData',FInfo);

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
	I = 		infoblock(6+1)*1e-6;		% sample interval (sec)
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

	PF = 	1000*(3.48*exp(-HZ/150)+ ...
		0.73*exp(-HZ/650)+ ...
		0.2*exp(-HZ/2700)+ ...
		0.032*exp(-HZ/43500));

	PF = round(PF/infoblock(6+1));




%%
%%
%%	GET TRACE AND PERFORM LEAK SUBTRACTION (Determined by Flags)
%%
%%

if (LF ~= 0) 						% Leak Pulses were acquired
	
	traceADRS = infoADRS+2+NB+2*NB*(swpnum-1);
	leakADRS =  traceADRS+NB;
	
	datafileID = fopen(datafile,'rb');
	
	fseek(datafileID,512*traceADRS,-1);
	[dtrace,count]=fread(datafileID,256*NB,'short');
	
	fseek(datafileID,512*leakADRS,-1);
	[leak,count]=fread(datafileID,256*NB,'short');

	fclose(datafileID);
	
	if getFLAG('leak') 				% Flag for leak subtraction
		dtrace=	[dtrace(1:NB*256-12) - ...
			(leak(1:NB*256-12) - mean(leak(1:PR)))*infoblock(37)/16;...
			dtrace(NB*256-11:NB*256)];
	end
else								% No Interpulse leaks

	traceADRS = infoADRS+2+NB+NB*(swpnum-1);
		
	datafileID = fopen(datafile,'rb');
	
	fseek(datafileID,512*traceADRS,-1);
	[dtrace,count]=fread(datafileID,256*NB,'short');
	fclose(datafileID);
end

if getFLAG('zero')				% Check Flag and Zero Start of Pulse

	HBzero= HGUI(4);
	zeroL = get(HBzero,'UserData');	
	zeroL(1:2)=round(zeroL(1:2)*1e-3/I);

	if zeroL(2)==0
		dtrace(1:NB*256-11)=dtrace(1:NB*256-11)-mean(dtrace(1:PR));
	else
		dtrace(1:NB*256-11)=dtrace(1:NB*256-11)-mean(dtrace(zeroL(1):zeroL(2)));
	end
end


%%
%%	PLOT THE (LEAK SUBTRACTED AND ZEROED) TRACE 
%%


pAtrace = dtrace*(10000/2048)/G;
time = 1000*I*[0:NB*256-1];

if getFLAG('lock')
	set(gca,'XLimMode','manual','YLimMode','manual');
else
	set(gca,'XLimMode','auto','YLimMode','auto');
end

if (Hlines(1) == 0)							% So far just one sweep on screen

	HIDline = line(time(1:NB*256-12),pAtrace(1:NB*256-12));
	Hlines(1) = 1;
	Hlines(2) = HIDline;
	Hlines(3) = HIDline;
else
	oldline = Hlines(2);
	delete(oldline);
	HIDline = line(time(1:NB*256-12),pAtrace(1:NB*256-12));
	Hlines(1) = 1;
	Hlines(2) = HIDline;
	Hlines(Hlines==oldline) = HIDline;
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

	TBlock(12) = dtrace(NB*256-1);			% Value of Familied Variable

	TBlock(13) = 0;  				% Offset (in points) of initial region
	TBlock(14) = PR+PF;  				% Length (in points) of initial region
	TBlock(15) = TBlock(14)+1;			% Location of Start Pulse 1
	TBlock(16) = TBlock(15)+round(PV(5)/1000/I);	% Location of Start Pulse 2
	TBlock(17) = TBlock(16)+round(PV(6)/1000/I);	% Location of Start Pulse 3
	TBlock(18) = TBlock(17)+round(PV(7)/1000/I);	% Location of Start Pulse 4
	TBlock(19) = TBlock(18)+round(PV(8)/1000/I)-1;	% Last Point of Pulse 4

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

	FInfo = get(gcf,'UserData');
	Hdel= FInfo(4,:);

	HMiso = HGUI(8);
	A = get(HMiso, 'UserData');
	W = A(:,1:3);			% Isochronal Windows
	
	values = zeros(1,length(nonzeros(W(:,1))));
	count = 1;

	pAtrace = get(HIDline,'YData');
	T = get(HIDline,'XData');
	
	YLim = get(gca, 'YLim');

	while (W(count,1) ~= 0)
		
		pulse = W(count,1);
		t1 = W(count,2);
		t2 = W(count,3);

		startpoint = TBlock(14+pulse)+round(t1/1000/TBlock(20)); 
		endpoint = TBlock(14+pulse)+round(t2/1000/TBlock(20));
		
		values(count) = mean(pAtrace(startpoint:endpoint));

		Hline1 = line([T(startpoint) T(startpoint)], [YLim(1) YLim(2)],'Color',[0 0 1]);
		Hline2 = line([T(endpoint) T(endpoint)], [YLim(1) YLim(2)],'Color',[0 0 1]);

		Hdel(Hdel(1)+2)= Hline1;
		Hdel(Hdel(1)+3)= Hline2;
		Hdel(1) = Hdel(1) + 2;
		
		count = count + 1;
	end

	FInfo(4,:) = Hdel;
	set(gcf,'UserData',FInfo);

	disp(values);
end



%%
%%	Update the Figure Information (UserData)
%%
%%	FInfo:	Row 1: Handles for GUI
%%		Row 2: Handles for Line Objects [(Total #) (Current) H1 H2 H3 ...]
%%		Row 3: Handles for Temporary Objects
%%

FInfo = get(gcf,'UserData');				% Get UserData Matrix (handles for GUI and traces)
FInfo(2,1) = 1;						% Increment # of traces
FInfo(2,2) = HIDline;					% Most Recently Plotted Is Active
FInfo(2,FInfo(2,1)+2)=HIDline;				% Add Sweep Object Handle
set(gcf,'UserData', FInfo);				% Write to UserData