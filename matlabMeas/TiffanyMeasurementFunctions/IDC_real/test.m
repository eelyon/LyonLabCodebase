myFig = figure;
x = [1,2,3];
y = [3,5,6];
plot(x,y);
myFig.UserData = struct("Datepicker",x,"Today",y);
savefig('test.fig');

myFig1 = figure;
x1 = [-1,2,3];
y1 = [3,5,-6];
plot(x1,y1);
myFig1.UserData = struct("Datepicker",x1,"Today",y1);
savefig('test1.fig');