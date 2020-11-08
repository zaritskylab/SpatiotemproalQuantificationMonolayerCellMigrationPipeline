%% plotPCCoefficient Plot a single PC coefficient vector
% With the PC correspinding to the provided index, plots&saves the PC's coefficient.
% different visualization, see input parameters.
% 
% 
% Input:
%   pcaScores - array of the coefficient values.
% 
%   pcIndexToPlot - the pc index you wish to plot.
% 
%   dirs - dirs structure created by initParamsDirs funciton. 
% 
%   experiments_labels - [non mendatory] the experiments labels by order,
%       if not supplied, a defaultive view listing experiments by index alone will be presented.
% 
%   cmapToUse - [non mendatory] color map of the scatter plots, 
%       use if you wish to set a different color to each experiment.
%       if not supplied, a defaultive color, different for each experiment, representation is used.
%
% For examples see 'quantifyMonolayerMigrationBulkMain.m' @step #4
% 
% Yishaia Zabary, Jun. 2020 (Adapted for the Bioimage Data Analysis Workflows - Advanced Components
% and Methods Book from Zaritsky et. al. 2017 http://doi.org/10.1083/jcb.201609095)
function [] = plotPCCoefficient(pcaCoeff, pcIndexToPlot, params, dirs, measure, xLabels, cmapToUse)
pcIDXs = 1:length(pcaCoeff(:, pcIndexToPlot));

if nargin < 7 || isempty(cmapToUse)
	cmap = jet(length(pcaCoeff(:,pcIndexToPlot))); % create n random colors.
else
    cmap = cmapToUse;
end
hold on;
scatter(pcIDXs, pcaCoeff(:, pcIndexToPlot), [], cmap);
ylim([-1 1]);
xticks(pcIDXs);
xtickangle(45);
if nargin < 6  || isempty(xLabels)
    xticklabels(createLabels(pcIDXs, 'coeff to feature', ''));
else
    xticklabels(xLabels);
end

title(sprintf('PC #%d Coefficients', pcIndexToPlot));
xlabel('Experiment');
ylabel('Score');
saveas(gcf,[dirs.PCAResults.(measure) sprintf('PC#%dsCoefficient.esp', pcIndexToPlot)],'epsc');
saveas(gcf,[dirs.PCAResults.(measure) sprintf('PC#%dsCoefficient.jpg', pcIndexToPlot)]);
savefig(gcf,[dirs.PCAResults.(measure) sprintf('PC#%dsCoefficient',pcIndexToPlot)]);
hold off;
close all;
end

function [labelsArray] = createLabels(vector, prefix, postfix)
    labelsArray = string.empty;
    for idx=1 : length(vector)
        labelsArray(idx) = sprintf('%s #%d %s',prefix, vector(idx), postfix);
    end
end

