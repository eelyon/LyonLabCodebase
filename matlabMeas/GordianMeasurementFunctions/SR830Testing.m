numPointsToRead = 10;

tc = SR830queryTimeConstant(SR830ST);
sratInd = floor(log2(1 / (0.0625 * tc)));
fprintf(SR830ST.client,"SRAT" + num2str(sratInd) + ";SEND0"); % Starts data storage
sratRate = (2^sratInd) * 0.0625;

%     fprintf(SR830ST.client,"REST"); % Stops data storage and resets buffer
%     fprintf(SR830ST.client,"FAST2;STRD") % Don't I need to use FAST1 or FAST2 to turn on data transfer?
%     fprintf(SR830ST.client,'STRD '); % starts scanning after 0.5sec
%     delay(1 + (numPointsToRead/sratRate));
%     fprintf(SR830ST.client,'PAUS '); % Pauses data storage

fprintf(SR830ST.client,"REST");
fprintf(SR830ST.client,"FAST2;STRD");
delay(0.5 + (numPointsToRead/sratRate));
fprintf(SR830ST.client,"PAUS");

query(SR830ST.client,"SPTS?")

x = SR830ST.SR830queryXFast(numPointsToRead);
y = SR830ST.SR830queryYFast(numPointsToRead);
% t = [t,(now() - startTime)*86400 - linspace(0,numPointsToRead/sratRate,numPointsToRead)];
mag = sqrt(x.^2 + y.^2);
toc