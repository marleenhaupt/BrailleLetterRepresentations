function bootstrapping_onsets_rsa(within,across,diff)

% set parameters
bootstrap_samples = 1000;
chance = 0; 

% input data
data_W = within(:,11:110);
data_W_base=within(:,:);
data_X= across(:,11:110);   
data_X_base=across(:,:);
data_D = diff(:,11:110);
data_D_base=diff(:,:);

%% bootstrapping

rng('shuffle')

for bs = 1:bootstrap_samples
bootstrapped_data_W = datasample(data_W,length(data_W(:,1)),1);
bootstrapped_data_X = datasample(data_X,length(data_X(:,1)),1);
bootstrapped_data_D = datasample(data_D,length(data_D(:,1)),1);

    %run sign rank test on this particular bootstrap sample
    for itime = 1:size(bootstrapped_data_W,2)
        [p_W(itime), h(itime)] = signrank(bootstrapped_data_W(:,itime),0,'tail','right');
        [p_X(itime), h(itime)]  = signrank(bootstrapped_data_X(:,itime),0,'tail','right');
        [p_D(itime), h(itime)]  = signrank(bootstrapped_data_D(:,itime),0,'tail','right');
    end

    % within-hand
    [mask_W, crit_p_W, adj_ci_cvrg_W, adj_p_W] = fdr_bh(p_W,0.05,'pdep');
    significant_time_points_W = find(mask_W>0);
    %across-hand
    [mask_X, crit_p_X, adj_ci_cvrg_X, adj_p_X] = fdr_bh(p_X,0.05,'pdep');
    significant_time_points_X = find(mask_X>0);
    %difference
    [mask_D, crit_p_D, adj_ci_cvrg_D, adj_p_D] = fdr_bh(p_D,0.05,'pdep');
	significant_time_points_D = find(mask_D>0);
        
    %% find the onset of n adjacent significant time points 
    
    %within-hand
	count = 0;  % Initialize a counter for adjacent ones
	start_index = 0;  % Initialize the starting index of adjacent ones
	data = mask_W;
	onset_W = NaN;

	for i = 1:length(mask_W) 
        if data(i) == 1
            count = count + 1;
            if count == 1
                start_index = i;
            end
            if count == 5
                end_index = i;
                onset_W = start_index;  
            break;  
            end
        else
            count = 0; 
        end
    end

    %across-hand
	count = 0;  
	start_index = 0;  
	data = mask_X;
	onset_X = NaN;

	for i = 1:length(mask_X) 
        if data(i) == 1
            count = count + 1;
            if count == 1
                start_index = i;
            end
            if count == 5
                end_index = i;
                onset_X = start_index;  
            break;  
            end
        else
            count = 0; 
        end
    end

    %difference
	count = 0;  
	start_index = 0; 
	data = mask_D;
	onset_D = NaN;

	for i = 1:length(mask_D) 
        if data(i) == 1
            count = count + 1;
            if count == 1
                start_index = i;
            end
            if count == 5
                end_index = i;
                onset_D = start_index;  
            break;  
            end
        else
            count = 0; 
        end
    end

        
	onset_latency_samples_W(bs)=onset_W;
	onset_latency_samples_X(bs)=onset_X;
	onset_latency_samples_D(bs)=onset_D;
    onset_latency_samples_diff_WX(bs)=onset_W - onset_X;
	onset_latency_samples_diff_DX(bs)=onset_D - onset_X;
end

% compute p-values of differences

samplesize_WX = sum(~isnan(onset_latency_samples_diff_WX));
pvals_WX= sum((onset_latency_samples_diff_WX>=0)) / sum(~isnan(onset_latency_samples_diff_WX));
    
samplesize_DX = sum(~isnan(onset_latency_samples_diff_DX));
pvals_DX= sum((onset_latency_samples_diff_DX>=0)) / sum(~isnan(onset_latency_samples_diff_DX));

%CIs
CI_95_W(1) = prctile(onset_latency_samples_W,2.5);
CI_95_W(2) = prctile(onset_latency_samples_W,97.5);

CI_95_X(1) = prctile(onset_latency_samples_X,2.5);
CI_95_X(2) = prctile(onset_latency_samples_X,97.5);

CI_95_D(1) = prctile(onset_latency_samples_D,2.5);
CI_95_D(2) = prctile(onset_latency_samples_D,97.5);

CI_95_diff_WX(1) = prctile(onset_latency_samples_diff_WX,2.5);
CI_95_diff_WX(2) = prctile(onset_latency_samples_diff_WX,97.5);

CI_95_diff_DX(1) = prctile(onset_latency_samples_diff_DX,2.5);
CI_95_diff_DX(2) = prctile(onset_latency_samples_diff_DX,97.5);

%% Plot

% plotting settings
x = 1:110;
x2 = [x, fliplr(x)];
y_CI_W = -0.1;
y_CI_X = -0.15;
y_CI_D = -0.1;
c3 = [0/255 0/255 0/255];
c1 = [62/255 73/255 137/255];
c4 = [181/255 222/255 43/255];
SEM_D   = std(data_D_base)./sqrt(size(data_D_base,1));
SEM_X   = std(data_X_base)./sqrt(size(data_X_base,1));
SEM_W   = std(data_W_base)./sqrt(size(data_W_base,1));

%this figure only shows across-hand and diff, within-hand is commented out
figure
% within = plot(mean(data_W_base),'Color',c1, 'LineWidth', 2)
% hold on
across = plot(mean(data_X_base),'Color',c4, 'LineWidth', 2)
hold on
diff = plot(mean(data_D_base),'Color',c1, 'LineWidth', 2)
hold on
plot([CI_95_X(1)+10;CI_95_X(2)+10],[y_CI_X;y_CI_X],'Color',c4, 'LineWidth', 2) 
hold on
plot(nanmean(onset_latency_samples_X)+10,y_CI_X,'.','MarkerSize',10,'Color',c4)
hold on
plot([CI_95_D(1)+10;CI_95_D(2)+10],[y_CI_D;y_CI_D],'Color',c1, 'LineWidth', 2) 
hold on
plot(nanmean(onset_latency_samples_D)+10,y_CI_D,'.','MarkerSize',10,'Color',c1)
hold on
% plot([CI_95_W(1)+10;CI_95_W(2)+10],[y_CI_W;y_CI_W],'Color',c1, 'LineWidth', 2) 
% hold on
% plot(nanmean(onset_latency_samples_W)+100,y_CI_W,'.','MarkerSize',10,'Color',c1)
% hold on
% upper = mean(data_W_base) + SEM_W;
% lower = mean(data_W_base) - SEM_W;
% inBetween = [upper, fliplr(lower)];
% fill(x2, inBetween, c1, 'FaceAlpha', 0.155, 'LineStyle', 'none');
% hold on;
upper = mean(data_X_base) + SEM_X;
lower = mean(data_X_base) - SEM_X;
inBetween = [upper, fliplr(lower)];
fill(x2, inBetween, c4, 'FaceAlpha', 0.155, 'LineStyle', 'none');
hold on;
upper = mean(data_D_base) + SEM_D;
lower = mean(data_D_base) - SEM_D;
inBetween = [upper, fliplr(lower)];
fill(x2, inBetween, c1, 'FaceAlpha', 0.155, 'LineStyle', 'none');
hold on;
title('RSA EEG-behavior')
xlabel('time (ms)')
ylabel('Correlation Coefficient')
xticks([10 30 50 70 90])
set(gca, 'XTickLabel', [0 200 400 600 800])
yline(0,'LineStyle','--', 'LineWidth', 1.5);
xline(10, 'LineStyle','--', 'LineWidth', 1.5);
ylim([-0.2,0.5])
set(gca,'box','off')
legend([diff across],'within-across', 'across')
%legend([within across],'within', 'across')
legend('boxoff')

end

