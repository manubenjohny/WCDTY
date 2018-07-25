function LTool
% 	LTOOL.M		Puts a Line on the screen to measure currents 
%			(Left Mouse Measures, Right Mouse Zeroes, TAB exits and clears)
%
%%

global HANDLE HFmain;
global ncount bubba;

HANDLE(1) = uicontrol(	HFmain,...
			'Style','edit',...
			'BackGroundColor',[0 0 .5],...
			'ForeGroundColor',[1 1 0],...
			'HorizontalAlignment','center',...
			'Units','normalized',...
			'Position',[.01 .70 .1 .05],...
			'Max',2,...
			'String','Line Tool: LC->read, RC->rezero, TAB->exit');

HANDLE(4) = uicontrol(	HFmain,...
			'Style','edit',...
			'BackGroundColor',[0 0 .5],...
			'ForeGroundColor',[1 1 0],...
			'HorizontalAlignment','center',...
			'Units','normalized',...
			'Position',[.01 .65 .10 .05],...
			'Max',2,...
			'String','   ');
xlim = get(gca,'XLim');

HANDLE(2) = line(xlim,[0 0],'Color',[0 0 1]);       %measured level horizontal line
HANDLE(3) = line(xlim,[0 0],'Color',[1 0 0]);       %zero level horizontal line

button = 0;
zerolevel = 0;

while button ~= 9                   % escape with 9, which is the tab key
	
	[x y button] = ginput(1);
    	
	if (button == 1)                % left mouse click
	  set(HANDLE(2),'YData',[y y]);
      set(HANDLE(4),'String',sprintf('x: %5.2f\t y: %5.2f', x, y-zerolevel));
            
      fprintf(1,'%8.2f\t', x);
	  fprintf(1,'%8.2f\n', y - zerolevel);
      
      % bubba keeps track of H-line selections for pasting into Excel
      bubba(ncount) = y-zerolevel;
      ncount = ncount+1;
    end

	if (button == 3)                %right mouse click
		set(HANDLE(2),'YData',[y y]);
		set(HANDLE(3),'YData',[y y]);
		zerolevel = y;
		set(HANDLE(4),'String',sprintf('x: %5.2f\t y: %5.2f', x, y-zerolevel));
    end
    clipboard('copy',y-zerolevel)
end

delete(HANDLE(1));
delete(HANDLE(2));
delete(HANDLE(3));
delete(HANDLE(4));