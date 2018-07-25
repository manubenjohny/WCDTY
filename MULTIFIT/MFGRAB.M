%%
%%	SWPGRB	Grabs a sweep from WC and Plots Normalized to Peak
%%
%%
%%

% Get The Sweep

Ndata = Ndata + 1;

FInfo = get(wcHandle,'UserData');
Hlines = FInfo(2,:);
Hcurrent=Hlines(2);

time = 	get(Hcurrent,'XData');
trace = get(Hcurrent,'YData');
TP = 	get(Hcurrent,'UserData');
TBlock = TP(3,:);

% Extract Information from TP

swpnum = TP(2,3);

D2 = TBlock(12);
I(Ndata)  = TBlock(20);

fitlimits(Ndata,1)= TBlock(14+1)+round(starttime/1000/TBlock(20));
fitlimits(Ndata,2)= TBlock(14+1)+round(endtime/1000/TBlock(20));
fitlimits(Ndata,3)= TBlock(14+2)+round((D2+starttime)/1000/TBlock(20));
fitlimits(Ndata,4)= TBlock(14+2)+round((D2+endtime)/1000/TBlock(20));

if (swpnum==1)					% First Sweep is Long Bi-exponential

	fitlimits(Ndata,2)=fitlimits(Ndata,4);
	fitlimits(Ndata,3)=fitlimits(Ndata,1);
end

% Normalize Data to Peak Current in Pulse 1

peak = max(conv(ones(1,10)/10,...
		abs(trace(TBlock(14+1):TBlock(14+1)+round(endtime/1000/TBlock(20))))));

trace = trace/peak;


% Plot Sweep on Axes

axes(Haxes(Ndata));
Hdata(Ndata) = plot(time,trace);
set(Hdata(Ndata),'UserData',TP);
set(get(Haxes(Ndata),'Title'),'String',[num2str(swpnum) ': ' num2str(peak) ' pA']);


% Plot Lines At Fit Limits

axes(Haxes(Ndata));
YLim = get(gca, 'YLim');


for k = 1:4

	line([time(fitlimits(Ndata,k)) time(fitlimits(Ndata,k))], [YLim(1) YLim(2)],'Color',[0 0 1]);
end

% Determine Initial Estimates for Magnitude Parameters

mag11(Ndata)= trace(fitlimits(Ndata,1))-trace(fitlimits(Ndata,2));
mag12(Ndata)= trace(fitlimits(Ndata,2));
mag21(Ndata)= trace(fitlimits(Ndata,3))-trace(fitlimits(Ndata,4));
mag22(Ndata)= trace(fitlimits(Ndata,4));
