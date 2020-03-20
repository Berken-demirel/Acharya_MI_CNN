function [Sensitivity,PPV] = get_my_score(labels, result)

TP = 0; % True positive
FP = 0; % False positive
FN = 0; % False negative
TN = 0; %True negative

for i = 1:length(labels)
    if( (labels(i,1) == 1 && result(i) == 1))
        TP = TP + 1;
    elseif( (labels(i,1) == 0 && result(i,1) == 0) )
        TN = TN + 1;
    elseif( labels(i) == 0 && result(i) == 1)
        FP = FP + 1;
    else
        FN = FN + 1;
    end
    
end
            
Specifity = TN/(TN +FP);
Sens = TP/(TP+FN);
PPV = TP/(TP+FP);
Acc = (TP + TN) / (TP+TN+FP+FN);

    fprintf('\t True Positive  = %d \n\t True Negative = %d \n\t False Negative = %d \n\t False Positive = %d \n',TP, TN, FN, FP);
    fprintf('--------------------------------------------------\n');
    fprintf('\t Sens = %.3f\n\t PPV  = %.3f\n',Sens, PPV);
    fprintf('\t Accuracy = %.3f\n\t Specifity = %.3f\n',Acc, Specifity);
   
% Sensitivity = Sens;
% PPV = PPV;
end