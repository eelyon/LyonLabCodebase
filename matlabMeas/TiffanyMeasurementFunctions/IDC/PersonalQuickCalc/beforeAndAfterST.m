function [] = beforeAndAfterST(folder,figure1,figure2,plotFigure)
%% compares the pinchoffs/densities between two figures
%  INPUTS: folder     = name of the folder with the data (ex: '')
%          figure1    = number of first figure to compare
%          figure2    = number of second figure to compare
%          plotFigure = 0 (1) means no (yes) plot
%          example = beforeAndAfterST('',22,22,0)

    %% Options
    Folder     = append('Data\',folder); 
    plotFig    = plotFigure;
    SweepIndex = [figure1 figure2];
    area = 0.0591;
    pinchoffs         = [];
    densities         = [];  % /cm^2
    numberOfElectrons = []; 
    
    %% Read From Files
    i        = SweepIndex(1);
    File     = sprintf('*Pinchoff_%i*.fig',i);
    S        = dir(fullfile(Folder,File));
    StmSweep = S.name;
     
    STMScan   = open([Folder '/' StmSweep]);     %load data to workspace
    dataObjsX = findobj(STMScan,'-property','XData');
    dataObjsY = findobj(STMScan,'-property','YData');
    
    %% other file
    i         = SweepIndex(2);
    File1     = sprintf('*Pinchoff_%i*.fig',i);
    S1        = dir(fullfile(Folder,File1));
    StmSweep1 = S1.name;
     
    STMScan1   = open([Folder '/' StmSweep1]);     %load data to workspace
    dataObjsX1 = findobj(STMScan1,'-property','XData');
    dataObjsY1 = findobj(STMScan1,'-property','YData');
    
    VSTMbefore = dataObjsX(4).XData;
    Ibefore    = dataObjsX(4).YData;
    VSTMafter  = dataObjsX1(4).XData;
    Iafter     = dataObjsX1(4).YData;
    
    close(STMScan)
    close(STMScan1)
    
    [pinch1,density1,numElec1] = findPinchOff(VSTMbefore,Ibefore,area);
    [pinch2,density2,numElec2] = findPinchOff(VSTMafter,Iafter,area);
    
    pinchoffs = [pinchoffs pinch1 pinch2];
    densities = [densities density1 density2]*1e-9;
    numberOfElectrons = [numberOfElectrons numElec1 numElec2];
    
    difference = abs(electronDensityST(diff(pinchoffs),257e-9)*area)*1e-6;
    
    fprintf(['The pinchoffs are ', num2str(pinchoffs),' and the densities are ', num2str(densities), 'e9']);
    fprintf([' \n and the difference in electrons is ', num2str(difference), 'e6 \n']);
    
    if plotFig == 1
        figure 
        xlabel('V_{barrierE} [V]');
        ylabel('I_{outE} [nA]');
        set(gcf,'color','w');
        set(gca,'FontWeight','bold');
        hold on
        plot(VSTMbefore,-Ibefore,'-o','Linewidth',2,'Markersize',4,'color',[0.3010 0.7450 0.9330],'MarkerFaceColor',[0.3010 0.7450 0.9330])
        plot(VSTMafter,-Iafter,'-o','Linewidth',2,'Markersize',4,'color',[0 0.4470 0.7410],'MarkerFaceColor',[0 0.4470 0.7410])
        legend({'Before Transfer','After Transfer'},'Location','southeast','FontSize',11)
        
        xline(pinchoffs(1),'--','Pinch-off','LineWidth',2,'HandleVisibility','off','color',[0.3010 0.7450 0.9330]);
        xline(pinchoffs(2),'--','Pinch-off','LineWidth',2,'HandleVisibility','off','color',[0 0.4470 0.7410]);
        
        ax=gca; 
        ax.YAxis.Exponent = -9;
        grid on
        hold off
    end 
    
    function [Vpinch,density,numElectrons] = findPinchOff(VSTM,I,area)
        fit = STFit(VSTM,-I*1e9);
        Vpinch = fit.mu-2*fit.sig;
        density = electronDensityST(Vpinch,257e-9);
        numElectrons = density*area;
    end

end

