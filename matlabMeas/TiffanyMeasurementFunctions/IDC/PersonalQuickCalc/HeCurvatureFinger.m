function [] = HeCurvatureFinger( channelHeight, fingerLength )

%%Constants
fn = 4;
% Physical Conastants
i  = sqrt(-1);
epHe = 1.056;
ep0  = 8.854e-12;
rho  = 145;
sigma = 3.78e-4;
g = 9.81;
k = 0.6911e-6;
e = 1.602e-19;
um = 1e6;
nm = 1e9;
pcm = 1e-2;

% Experimental constants
widthStart = 12e-6;
widthEnd = 27e-6;
numWidths = 20;
listH = [5.5e-3 6.5e-3 9e-3];
% channelHeight = 0.640e-6;
% fingerLength = 59;

channelWidths = linspace(widthStart,widthEnd,numWidths);
centerHeights = zeros([1 numWidths]);
channelXs = linspace(0,60e-6,numWidths);

ci=0;
% collectx = [];  
% collecty = [];

for h = listH 
    for channelWidth = channelWidths
    
        ci = ci+1;
        p = channelWidth/2;
        ne = 1e9*1e4;
        n_mu = 0;
        n_sigma = p/7;
        V0 = 0;
        d0 = channelHeight;
        dend = d0;
        
    
        %Simulation Constants
        xStep = 100e-9;
        periods = 1;
        dStart = 1e-4;
        decimalPercision = 25;
        ErrorLim = 1e-12;
        
        %% Definitions
        
        x = -periods*p:xStep:p*periods;
        len = length(x);
        %n = normpdf(x,n_mu,n_sigma)./max(normpdf(x,n_mu,n_sigma)).*ne;
        n = ((x>-p/4).*(x<p/4)).*ne;
        
        sum1 = @(x,z) sqrt(pi).*exp(-i*pi./p.*(x-i.*z))./sqrt(exp(-4*pi./p.*(z+i.*x))+1);
        sum2 = @(x,z) sqrt(pi).*exp(i*pi./p.*(x+i.*z))./sqrt(exp(4*pi./p.*(-z+i.*x))+1);
        
        Ex = @(x,z,V0) i.*2.*V0./pi./p.*sqrt(2./pi).*(sum1(x,z)-sum2(x,z));
        Ez = @(x,z,V0) 2.*V0./pi./p.*sqrt(2./pi).*(sum1(x,z)+sum2(x,z));
        
        depth = @(x,y) [y(2); -B/A*y(1)^(-3)-1/A*y(1)-C/A-D/A*(epHe*(Ez(x,y(1)))^2+(Ex(x,y(1)))^2)];
        HBalance0 = @(d,x,n,V0) (h+d) - (epHe - 1).*ep0./2./rho./g.*(epHe.*Ez(x,d,V0).^2+Ex(x,d,V0).^2) - k.^4./d.^3 + n.*n.*e.*e./2./ep0./epHe./rho./g;
        dpp = @(d,x,n,V0) 1./sigma.*rho.*g.*((h+d) - (epHe - 1).*ep0./2./rho./g.*(epHe.*Ez(x,d,V0).^2+Ex(x,d,V0).^2) - k.^4./d.^3 + n.*n.*e.*e./2./ep0./epHe./rho./g);
        dppBulk = @(d,x,n,V0) 1./sigma.*rho.*g.*((h+d)); % - (epHe - 1).*ep0./2./rho./g.*(epHe.*Ez(x,d,V0).^2+Ex(x,d,V0).^2) - k.^4./d.^3 + n.*n.*e.*e./2./ep0./epHe./rho./g);
        
        params = sprintf(' [ h=%1.0e , p=%2.0e ] ',h,p);
        
        %% Iterative Solver
        
        %Loop Start
        
        %subplot(1,1,1)
        %hold off
        
        
        dWinner = dStart;
        dwins = [];
        for iterations = -ceil(log10(dWinner)):decimalPercision
            dGuesses = dWinner:-1*10^(-iterations):dWinner-1*10^(-iterations+1);
            
            for dGuess = dGuesses
                d = zeros([1 len]);
                d(1) = d0;
                d(2) = dGuess;
                for xi = 2:len-1
                    dPP = dpp(d(xi),x(xi),n(xi),V0);
                    d(xi+1) = 2*d(xi)+dPP*0.5*xStep^2-d(xi-1);
                end
                
                if(min(d) > 0 && isreal(d) && d(end) > dend)
                    figure(fn+1)
                    subplot(1,1,1)
                    plot(x.*um,d.*um,'LineWidth',2)
                    xlabel('Position [um]')
                    ylabel('Helium Depth [um]')
                    title(['Depth Vs x Position' params])
                    hold on
                    dWinner = dGuess;
                    dwins = d;
                end
                
            end
            hold off
             % fprintf('%3.0f  :  %1.30e \n',iterations,dWinner)
            %pause(0.1)
            if abs(d(end)-d(1)) < ErrorLim
                break
            end
        end
        d = dwins; 
        centerHeights(ci) = d(floor(len/2));
         
    end

    figure(fn)
    hold on
    legendName = append(num2str(h*1000), 'mm');
    plot(channelXs.*um,centerHeights.*um,'LineWidth',2,'DisplayName',legendName)
    xlabel('Channel Length [um]')
    ylabel('Helium Depth [um]')
    title('Depth Vs Finger Length')
    xline(fingerLength,'HandleVisibility','off')
    legend('show')
    ci = 0;
%     y_um = centerHeights.*um;
%     x_um = channelXs.*um;
%     
%     value = 0.01+1e-3*vdWThickness(1e2*h);
%     if y_um(end) < value
%         xfory = interp1(y_um,x_um,value);
%         collectx = [collectx xfory]
%         collecty = [collecty value];
%     else
%         xfory = 60;
%         collectx = [collectx xfory];
%         collecty = [collecty y_um(end)];
%     end

end
hold off
% figure(10)
% plot(collectx) 
% grid
% 
% figure(11)
% plot(collecty)
% grid
end
