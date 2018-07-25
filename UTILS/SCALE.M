function scale(z)

%%
%% 	SCALE.M     Scales the current trace
%%
%%

x=get(gcf,'UserData');
y=get(x(2,2),'YData');

set(x(2,2),'YData',y*z);
