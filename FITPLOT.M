function fitplot(x)

%%
%%	fitplot.M	Plots Fits given Parameter String
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

	
% Determine which fit was selected

select = get(HMexp1,'Value');
	

if (select==1)			% Single Exponential with Offset

		% x = [mag1 tau1 offset]

		fit = expfit1(x,trace,startpoint,endpoint,I,1);
			
		Hfit = line(time(startpoint:endpoint),fit(1:(endpoint-startpoint+1)),'Color', [1 0 0]);
	
		Hfits = FInfo(3,:);
		Hfits(Hfits(1)+2)= Hfit;
		Hfits(1) = Hfits(1) + 1;
		FInfo(3,:)=Hfits;
		set(gcf,'UserData', FInfo);

end

if (select==2)			% Double Exponential No Offset


		% x = [mag1 tau1 mag2 tau2]

		fit = expfit2(x,trace,startpoint,endpoint,I,1);
		Hfit = line(time(startpoint:endpoint),fit(1:(endpoint-startpoint+1)),'Color', [1 0 0]);
	
		Hfits = FInfo(3,:);
		Hfits(Hfits(1)+2)= Hfit;
		Hfits(1) = Hfits(1) + 1;
		FInfo(3,:)=Hfits;
		set(gcf,'UserData', FInfo);
end

if (select==3)			% Two-Pulse Simultaneous Fit
			
		% x = [mag11 mag12 mag21 mag22 tau1 tau2]

		fit = expfit2D(x,trace,startpoint,endpoint,I,1);
		
		Hfit = line([time(startpoint(1):endpoint(2))],...
			    [fit(startpoint(1):endpoint(2))],...
                            'Color', [1 0 0]);
	
		Hfits = FInfo(3,:);
		Hfits(Hfits(1)+2)= Hfit;
		Hfits(1) = Hfits(1) + 1;
		FInfo(3,:)=Hfits;
		set(gcf,'UserData', FInfo);
end	

if (select==4)			% Fit With Model
			
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
end	
	
