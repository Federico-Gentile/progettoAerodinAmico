clear; close all; clc;

% Input history files list (automatically sorted by date)
fileList = dir('histories/*.txt');
swarmSize = 120;
baselinePwr = 2348;

globHistory = [];
for ii = 1:length(fileList)
    if ii == 1
        globHistory = readmatrix("histories/"+fileList(ii).name);  
    else
        currHistory = readmatrix("histories/"+fileList(ii).name);
        if size(globHistory,2) ~= size(currHistory,2)
            globHistory = [ globHistory , -ones(size(globHistory,1),size(currHistory,2)-size(globHistory,2))]; %#ok<*AGROW> 
        end
        globHistory = [ globHistory ; currHistory ];
    end
end

% Computing number of time steps
timeSteps = floor(size(globHistory,1)/swarmSize);
[maxVec, minVec] = deal(zeros(timeSteps,1));

% Expluding spikes
toPlot = globHistory((globHistory(:,10)<4000)&(globHistory(:,10)>2200),10);

figure; 


subplot(2,1,1); hold on;
plot(toPlot);
for jj = 1:timeSteps
    maxVec(jj) = max(toPlot(((swarmSize*(jj-1)):(swarmSize*jj))+1));
    minVec(jj) = min(toPlot(((swarmSize*(jj-1)):(swarmSize*jj))+1));
    xline(swarmSize*jj,'k--', "Linewidth", 1.5, "Label",['t = ',num2str(jj)],LabelOrientation="aligned",LabelHorizontalAlignment="left",FontSize=12);
    plot(swarmSize*[jj-1, jj], [maxVec(jj), maxVec(jj)],'r-', 'LineWidth', 2);
    plot(swarmSize*[jj-1, jj], [minVec(jj), minVec(jj)],'g-', 'LineWidth', 2);
    
end
plot([0 , swarmSize*jj], [baselinePwr, baselinePwr], 'Color', [169,169,169]/255, 'LineWidth', 1.5);
ylabel('Power')
xlabel('Fitness Evaluations')

subplot(2,1,2); hold on;
plot(1:timeSteps, (minVec-baselinePwr)/baselinePwr*100, 'LineWidth', 2);
ylabel('Power Gain %')
xlabel('Time Step')
grid minor;





