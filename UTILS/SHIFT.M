function shift(z)

%%
%% 	SHIFT.M     Scales the current trace
%%
%%

x=get(gcf,'UserData');
y=get(x(2,2),'XData');

set(x(2,2),'XData',y+z);
