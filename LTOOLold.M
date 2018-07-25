function LTool

%%
%% 	LTOOL.M		Puts a Line on the screen to measure currents 
%%			(Left Mouse Zeros, Right Mouse Exits
%%
%%

global HANDLE;
global ncount bubba;

HANDLE(1) = uicontrol(	gcf,...
			'Style','edit',...
			'BackGroundColor',[0 0 .5],...
			'ForeGroundColor',[1 1 0],...
			'HorizontalAlignment','center',...
			'Units','normalized',...
			'Position',[.01 .85 .1 .05],...
			'Max',2,...
			'String','Line Tool');

HANDLE(4) = uicontrol(	gcf,...
			'Style','edit',...
			'BackGroundColor',[0 0 .5],...
			'ForeGroundColor',[1 1 0],...
			'HorizontalAlignment','center',...
			'Units','normalized',...
			'Position',[.01 .70 .10 .10],...
			'Max',2,...
			'String','<RT> Zero|<LT> Line|<Tab> Exit');
xlim = get(gca,'XLim');

HANDLE(2) = line(xlim,[0 0],'Color',[0 0 1]);
HANDLE(3) = line(xlim,[0 0],'Color',[1 0 0]);

button = 0;
zerolevel = 0;

while (button ~= 3) & (button ~= 9)
	
	[x y button] = ginput(1);
    	
	if (button == 1)
	  set(HANDLE(2),'YData',[y y]);
      %set(HANDLE(1),'String',[num2str(x);num2str(y-zerolevel)]);
      set(HANDLE(1),'String',[num2str(x)]);
      %set(HANDLE(1),'String','test');
      % bubba keeps track of H-line selections for pasting into Excel
      fprintf(1,'%8.2f\t', x);
	  fprintf(1,'%8.2f\t', y);
      bubba(ncount) = y-zerolevel;
      ncount = ncount+1;
    end

	if (button == 2)
		set(HANDLE(2),'YData',[y y]);
		set(HANDLE(3),'YData',[y y]);
		zerolevel = y;
		set(HANDLE(1),'String',[num2str(x) '|' num2str(0)]);
        %set(HANDLE(1),'String','test button 2');
 	end
end

delete(HANDLE(1));
delete(HANDLE(2));
delete(HANDLE(3));
delete(HANDLE(4));