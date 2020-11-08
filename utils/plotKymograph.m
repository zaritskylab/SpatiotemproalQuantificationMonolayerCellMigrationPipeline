%% plotKymograph
% Assaf Zaritsky *updated* on Jan. 2018 based on the GEF project repository

function [] = plotKymograph(kymograph,params)

ntime = size(kymograph,2);
nspace = size(kymograph,1);
maxTime = ntime * params.timePerFrame;
xTick = 1: floor((ntime-1)/5) : ntime-1;
xTickLabel = params.kymoMinTimeMinutes :  floor(((ntime+params.kymoMinTimeFrameNum-1)*params.timePerFrame - params.kymoMinTimeMinutes)/5) : (ntime+params.kymoMinTimeFrameNum-1)*params.timePerFrame;
yTick = 1: 1 : nspace;
yTickLabel = params.kymoMinDistMu : params.patchSizeUm : (nspace+params.kymoMinDistMu/params.patchSizeUm - 1)*params.patchSizeUm;

h = figure;
colormap('jet');
imagescnan(kymograph);
hold on;
caxis(params.caxis); colorbar;
haxes = get(h,'CurrentAxes');
set(haxes,'XLim',[1,maxTime/params.timePerFrame]);
set(haxes,'XTick',xTick);
set(haxes,'XTickLabel',xTickLabel);
set(haxes,'YTick',yTick);
set(haxes,'YTickLabel',yTickLabel);
set(haxes,'FontSize',10);
xlabel('Time (minutes)','FontSize',params.fontsize); ylabel('Distance from edge (\mum)','FontSize',params.fontsize);
set(h,'Color','w');
savefig(gcf,strrep(params.fname ,'.jpg',''));
saveas(h,params.fname);
saveas(h,strrep(params.fname, 'jpg', 'eps'),'epsc');
hold off;
end