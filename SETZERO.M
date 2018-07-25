function SetZero(item)

%%
%%	SETZERO.M	Function Toggles Set Zero Flag and Sets Up Zero Button
%%
%%

global datafilepath datafilename HFmain;
global x1 x2 ymin ymax;

% Check that a file has been opened

datafile=[datafilepath datafilename];

if strcmp(datafilename,'0')
	errcall('OPEN A FILE FIRST');
	return;
end

%	FInfo:	Row 1: Handles for GUI


FInfo = get(HFmain,'UserData');			% Get UserData Matrix (handles for GUI and traces)

Hmenu = FInfo(1,1);				% Get Menu Handle
Hbutton = FInfo(1,4);				% Get Button Handle


if strcmp(item,'menu')				% Menu Toggled (affects button)

	if strcmp(get(Hmenu,'Checked'),'on')
		set(Hmenu,'Checked','off');
		set(Hbutton,'Visible','off');
		set(Hbutton,'Callback','');
	else
		set(Hmenu,'Checked','on');
		set(Hbutton,'Visible','on');
		set(Hbutton,'Callback','SetZero(''button'')');
		set(Hbutton,'UserData',[0 0]);
	end
end

if strcmp(item,'button')
	
	Htext = uicontrol(	HFmain,...
			'Style','text',...
			'BackGroundColor',[.5 .5 .5],...
			'ForeGroundColor',[0 0 0],...
			'Units','normalized',...
			'Position',[.6 .85 .2 .1],...
			'String','Select Region With Mouse');

	[x1 y button] = ginput(1);	
	ylim = get(gca,'YLim');
	Hline1 = line([x1 x1],ylim,'Color',[0 0 1]);

	[x2 y button] = ginput(1);	
	ylim = get(gca,'YLim');
	Hline2 = line([x2 x2],ylim,'Color',[0 0 1]);

	set(Hbutton,'UserData',[sort([x1 x2]) Hline1 Hline2]); % Note This is Stored In Time
	
	delete(Htext);
	delete(Hline1);
	delete(Hline2);
end


%	Refresh the current trace and replot it

HIDline = FInfo(2,2);

TP = get(HIDline,'UserData');

datafile = setstr(nonzeros(TP(1,:))');
rnum = TP(2,1);
swpnum = TP(2,3);

plotswp(datafile,rnum,swpnum);