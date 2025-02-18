figPath = append('C:\Users\Lyon-Lab-B417\Downloads\','untitled','.fig');

fig = openfig(figPath,"invisible");
ax = get(fig,'Children');
% realAxis = findobj(ax(3),'Type','ErrorBar');