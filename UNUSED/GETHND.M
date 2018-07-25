function handlevalue = getHND(HFigure,itemname)

%%
%%	getHND	Function that returns the value of the handle as stored
%%		in the UserData of the figure.
%%

handlevalue = eval (itemname);		% for now handles are global variables