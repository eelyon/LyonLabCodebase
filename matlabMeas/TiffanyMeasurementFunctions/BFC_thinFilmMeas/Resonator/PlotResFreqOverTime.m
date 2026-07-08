% plot He level resonator over temperature
% takes about 1 hour and 15 min for BFC to go from 9K to 4K
% take a measurement every 3 minutes

for i = 1:25 
    PlotHeLevelRes
    pause(180)
end
