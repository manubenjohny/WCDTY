function modplot(x)

%%
%%	modplot.M	Plots Bi-exponential Model Fit given Parameters
%%			
%%

global datafilepath datafilename;
global startpoint endpoint trace TBlock;

%	FInfo:	Row 1: Handles for GUI


FInfo = get(gcf,'UserData');			% Get UserData Matrix (handles for GUI and traces)

Hmenu = FInfo(1,12);				% Get Menu Handle
HMexp1 = FInfo(1,13);				% Exp Button Handle
HBexp2 = FInfo(1,14);				% Exp Button Handle

% Get Information for the current sweep

HIDline = FInfo(2,2);
TP = get(HIDline,'UserData');
TBlock = TP(3,:);
	
duration = TBlock(8:11);
duration(2)=TBlock(12);

I = TBlock(20);
	
trace = get(HIDline,'YData');
time = get(HIDline,'XData');

	
% Determine Regions for fitting

window = [1 5 250;2 duration(2)+5 duration(2)+250];

for k = 1:2
		
	pulse(k)=window(k,1);
	starttime(k) = window(k,2);
	endtime(k) = window(k,3);

	startpoint(k) = TBlock(14+pulse(k))+round(starttime(k)/1000/TBlock(20)); 
	endpoint(k) = TBlock(14+pulse(k))+round(endtime(k)/1000/TBlock(20));

end

			
% x = [mag11 mag12 tauI1 tauI2 tauR1 tauR2]
		
fit = expfitM(x,trace,startpoint,endpoint,duration,I,1);
		
Hfit = line([time(startpoint(1):endpoint(2))],...
	    [fit(startpoint(1):endpoint(2))],...
             'Color', [1 0 0]);
	
Hfits = FInfo(3,:);
Hfits(Hfits(1)+2)= Hfit;
Hfits(1) = Hfits(1) + 1;
FInfo(3,:)=Hfits;
set(gcf,'UserData', FInfo);
