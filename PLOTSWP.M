function plotswp(datafile,runnumber,swpnum);

%%
%%	PLOTSWP.M 	This function plots a sweep on current axes given the
%%			datafile name, run number, and sweep number. Also performs
%%			isochronal measurement and displays result.
%%			
global curplot
curplot.curfile = datafile;
curplot.currun = runnumber;
curplot.curswp = swpnum;

global FInfo Hlines HFmain;
global rnum maxswp infoblock dtrace NB dirblock;
rnum = runnumber;


%%
%% 	GET FIGURE INFORMATION AND REFRESH SCREEN
%%


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
    %pause
	
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
   
    CW  =    infoblock(46+1)/1000; % Whole cell capacitance
    RS  =    infoblock(47+1)/100;  % Series resistance
   
   ClampPropertiesString = sprintf('C: %d pF    Rs: %d Mohm',CW,RS);
   HTW3 = findobj('Tag','ClampProperties');
   set(HTW3,'String',ClampPropertiesString);

   
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
	
	if ((infoblock(18+1) == 1) & getFLAG('leak'))		% if it is a ramp and we want leak subtr
		regstart = 100;
		regend = regstart + 2*256;
		reglength = regend - regstart + 1;		
		
		xreg = [regstart:regend];
		xreg = xreg';
		yreg = dtrace(regstart:regend);
		
		slope = ( (reglength)*sum(xreg.*yreg) - sum(xreg)*sum(yreg) ) / ... 
						( (reglength)*sum(xreg.^2) - sum(xreg)^2 );
		yintercept = ( sum(yreg)*sum(xreg.^2) - sum(xreg)*sum(xreg.*yreg) ) / ...
						( (reglength)*sum(xreg.^2) - sum(xreg)^2 );
		leak = slope*[1:NB*256]+yintercept;
		leak = leak';
		dtrace = dtrace - leak;		
	end
end

if getFLAG('zero')				% Check Flag and Zero Start of Pulse

	HBzero= HGUI(4);
	zeroL = get(HBzero,'UserData');		% zero range stored in userdata of zero button
	zeroL(1:2)=round(zeroL(1:2)*1000/I);

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
time = I/1000*([1:NB*256]-(PR+PF+1));		% PR+PF+1 is where first pulse starts
if (infoblock(18+1) == 1)				% if it is a ramp
	voltage = family(1) + ((family(2)-family(1))/(NB * 256))*([1:NB*256]-1);
	if getFLAG('leak')		% if it is a ramp and we want leak subtr
		zerostart = (NB*256)*.6;
		zeroend = (NB*256)*.95;
		pArange = .005;
      % Fixed
      x = find(-pArange < pAtrace(round(zerostart):round(zeroend)) & pAtrace(round(zerostart):round(zeroend)) < pArange);
      % Fixed
      if (~isempty(x))		
			x = mean(x) + zerostart;
			disp(voltage(x))
		else
			disp('No zero found')
		end
	end
end


if getFLAG('lock')
	set(gca,'XLimMode','manual','YLimMode','manual');
else
	set(gca,'XLimMode','auto','YLimMode','auto');
end

if (Hlines(2) == 0)							% Hlines(2) = current trace

	if (infoblock(18+1) == 1)					% if it is a ramp
	 	HIDline = line(voltage(1:NB*256-12),pAtrace(1:NB*256-12));
	else
		HIDline = line(time(1:NB*256-12),pAtrace(1:NB*256-12));
	end
	Hlines(2) = HIDline;
else
	current=Hlines(2);
	delete(current);
	if (infoblock(18+1) == 1)					% if it is a ramp
	 	HIDline = line(voltage(1:NB*256-12),pAtrace(1:NB*256-12));
	else
		HIDline = line(time(1:NB*256-12),pAtrace(1:NB*256-12));
	end
	Hlines(2) = HIDline;
end

if ~getFLAG('lock')
	if (infoblock(18+1) == 1)					% if it is a ramp
		xlimits = get(gca,'Xlim');
		xlimits(1) = family(1);
		xlimits(2) = family(2);
		set(gca,'Xlim',xlimits);
	else
		xlimits = get(gca,'Xlim');
		xlimits(1) = round(-(PR+PF)*I/1000);
		xlimits(2) = sum(PV(5:8));
		set(gca,'Xlim',xlimits);
	end
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
	% Fixed formatting
	set(	HTW2,... 
      'String',	sprintf('V: %4d %4d %4d %d\nD: %4d %4d %4d %4d', ...
                   TBlock(4), TBlock(5),...
				       TBlock(6), TBlock(7),...
				       TBlock(8), TBlock(9),...
				       TBlock(10), TBlock(11)),...
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
			
			%note:  "peak" really averages over consize window.  if this window
			%	is smaller than cursor window, you get bizarre results.
			
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
	
	fprintf(1,'%3.0f\t', PV(NI-3)), fprintf(1,'%6.1f\t',values(1:length(values)-1)),fprintf(1,'%6.1f\n',values(length(values)));

end


%%
%%	Update the Figure Information (UserData) (Key to FInfo in WCINIT)
%%

FInfo = get(HFmain,'UserData');				% Get UserData Matrix (handles for GUI and traces)
FInfo(1,:)=HGUI;					% GUI Handles
FInfo(2,:)=Hlines;					% Line Handles
FInfo(4,:)=Hdel;					% Objects to Delete for Refresh
set(HFmain,'UserData', FInfo);				% Write to UserData