% Postprocessing script for the estimation over network 2 example

solz = HybridArc(tz, jz, z);
solhatz = HybridArc(thatz, jhatz, hatz);

% plot solution
figure(1) 
clf
hpb = HybridPlotBuilder();
hpb.subplots('on').color('matlab');
hpb.legend('System state $x_1$','System state $x_2$',...
           'System state $x_3$','System state $x_4$')...
    .plotFlows(solz) 
hold on
hpb.legend('Estimation $\hat{x}_1$',...
    'Estimation $\hat{x}_2$','Estimation $\hat{x}_3$',...
    'Estimation $\hat{x}_4$').plotFlows(solhatz.slice(1:4)) 