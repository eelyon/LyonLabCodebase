%% Options
function [] = singleSTMplots(folder,figureNum,type,plotfig)

    Folder     = folder; 
    SweepIndex = figureNum; 
    plotFig    = plotfig;
    area       = 0.0591;
    
    %% Read From Files
    File     = sprintf('*Pinchoff_%i*.fig',SweepIndex);
    S        = dir(fullfile(Folder,File));
    StmSweep = S.name;
     
    STMScan   = open([Folder '/' StmSweep]);     %load data to workspace
    dataObjsX = findobj(STMScan,'-property','XData');
    dataObjsY = findobj(STMScan,'-property','YData');
    
    if strcmp(type,'Emitter')
        VSTM    = dataObjsX(4).XData; % this'll change for E(=1) or C (=2) or if there was a back scan 
        I       = dataObjsY(4).YData;
        fit     = STFit(VSTM,-I*1e9);
        Vpinch  = fit.mu-2*fit.sig;
        density = electronDensityST(Vpinch,257e-9);
    else
        minI       = 0.6239e-9;
        conversion = 56.328;
        Vstm    = dataObjsX(4).XData;
        VSTM    = dataObjsX(4).XData-Vstm(1);
        I       = dataObjsY(4).YData;
        Vpinch  = (max(-I)-minI)*(1e9)*(1/conversion);
        density = electronDensityST(-Vpinch,257e-9);
    end

    close(STMScan)
    numberOfElectrons = density*area*1e-6;
    fprintf(['Vpinch=',num2str(Vpinch),'V.']);
    fprintf([' Density =', num2str(density*1e-9),'e9 and number of electrons = ', num2str(numberOfElectrons),'e6 \n']);

    if plotFig == 1
        if strcmp(type,'Emitter')
            figure 
            xlabel('V_{barrierE} [V]');
            ylabel('I_{outE} [nA]');
            set(gcf,'color','w');
            set(gca,'FontWeight','bold');
            set(gca,'FontSize',13);
            
            hold on
            plot(VSTM,-I,'-o','Linewidth',2,'Markersize',4) %,'MarkerFaceColor',v,'MarkerEdgeColor',[0 0.4470 0.7410]); %,'LineWidth',2)
            xline(Vpinch,'--','Pinch-off','LineWidth',2);
            % xticks(-0.3:0.1:0)
            grid on
            disp(fit)
        else
            figure 
            xlabel('V_{barrierC} [V]');
            ylabel('I_{outC} [nA]');
            set(gcf,'color','w');
            set(gca,'FontWeight','bold');
            set(gca,'FontSize',13);
            
            hold on
            plot(VSTM,-I,'-o','Linewidth',2,'Markersize',4) %,'MarkerFaceColor',v,'MarkerEdgeColor',[0 0.4470 0.7410]); %,'LineWidth',2)
            % xticks(-0.3:0.1:0)
            grid on
        end
    end      

    %     pinchoffE  = Ie(end)+Ie(end)*(1/exp(1));
    %     
    %     [v, w] = unique( Ie, 'stable' );  % get rid of duplicates to be able to do interpolation
    %     dupind = setdiff( 1:numel(Ie), w );
    %     Ie(dupind) = [];
    %     VSTMe(dupind) = [];
    %     densityE   = -interp1(Ie,VSTMe,pinchoffE);
    %     densitiesE = [densitiesE, densityE];

end
