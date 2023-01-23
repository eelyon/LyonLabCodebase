Results = matfile('VXVVector_TransisionAgain.mat');
VXVector = Results.VXVector;
xs = Results.xs;
ys = Results.ys;
numVoltages = Results.numVoltages;
gateNames = Results.gateNames;


ys2 = ys;
xs2 = [xs xs(1:end-1)+xs(end)-xs(1)+(xs(2)-xs(1))];
voltDim = (numVoltages+1);
ks = 1:voltDim;

Potential = zeros([length(xs2) length(ys2)]);
                                                % entire device (ys2 length now 1000)
VXVectorTotal = zeros([length(xs2) length(ys2) voltDim]);  % new VXVectorTotal dimensions 
%VXVector = vector.VXVector;
% add mirrored device to VXVectorTotal
VXVectorTotal = zeros([length(xs2) length(ys2) voltDim]);  % new VXVectorTotal dimensions 
%VXVector = vector.VXVector;
% add mirrored device to VXVectorTotal
for i = 1:length(xs)
    for j = 1:length(ys)
        for k = ks
            
            VXVectorTotal(i,j,k) = VXVector(i,j,k);
            if i~=length(xs)
                VXVectorTotal(end-i+1,j,k) = VXVector(i,j,k); % add other half to VXVector total
            end
            
        end
    end
end
% for i =1:length(VXVectorTotal(1,1,:))
%     %subplot(4,2,i)
%     figure(i)
%     surf(ys2,xs2,VXVectorTotal(:,:,i))
%     title(gateNames{i})
% end
% plot cross section along one x 
figure
VoltVector = [0 0 0 0.1 -5 0 -1 1];
gateNames;
for i = 1:length(xs2)
    for j = 1:length(ys2)
        XYVectorTotal = reshape(VXVectorTotal(i,j,:),[voltDim 1]);
        Potential(i,j) = VoltVector*XYVectorTotal;
    end
end
plot(-Potential(ceil(length(xs2)/2),:))  % x from 0-11, 6-> plot center
% to plot potentials from entire device
figure
surf(-Potential)  % negative for electron 
xlabel('y')
ylabel('x')
zlabel('potential')
