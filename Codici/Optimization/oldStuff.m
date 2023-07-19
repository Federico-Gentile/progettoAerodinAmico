%     % Check if the XFOIL reached convergence for every tested AOA
%     % AT THE MOMENT THIS PIECE OF CODE DOES NOT WORK IF THERE ARE 2
%     % CONSECUTIVE NOT CONVERGED ANGLES.
%     if size(polar,1) ~= length(alphaVecRoot)
%         % Creating the corrected polar, which filles the non converged rows
%         % of the polar with a in interpolation of the neighbours values
%         polar_corrected = zeros(length(alphaVecRoot),size(polar,2));
%         % For loop to find the non converged cases
%         for kk = 1:length(alphaVecRoot)
%             % Particular case: update of the number of corrections when the
%             % last angle did not converged
%             if kk == length(alphaVecRoot) && ncorr(ii) ~= (length(alphaVecRoot) - size(polar, 1))
%                 ncorr(ii) = ncorr(ii) + 1;
%             end
%             % If the non converged angle is found
%             if polar(kk-ncorr(ii),1) ~= alphaVecRoot(kk)
%                 % The angle of polar corrected is set to the right one.
%                 polar_corrected(kk, 1) = alphaVecRoot(kk);
%                 % Particular case: the first angle did not converge
%                 if kk == 1
%                      % We put the value of the successive angle
%                      polar_corrected(kk, 2:end) = polar(kk,2:end);  
%                 % Particular case: the last angle di not converge
%                 elseif kk == length(alphaVecRoot)
%                      % We put the value of the second to last angle
%                      polar_corrected(kk, 2:end) = polar(kk-ncorr(ii),2:end); 
%                 else
%                      % Every other case
%                      polar_corrected(kk, 2:end) = (polar(kk-ncorr(ii),2:end) + polar(kk-1-ncorr(ii),2:end))/2;
%                 end
%                 % If you are not at the last angle update the number of
%                 % correction
%                 if kk ~= length(alphaVecRoot)
%                      ncorr(ii) = ncorr(ii) + 1;
%                 end
%             else
%                 % If the current angle is converged, simply copy the polar
%                 % value
%                 polar_corrected(kk, :) = polar(kk-ncorr(ii),:);
%             end
%             
%         end
%         ClRoot(ii,:) = polar_corrected(:,2)';
%         CdRoot(ii,:) = polar_corrected(:,3)';
%         CmRoot(ii,:) = polar_corrected(:,5)';
%     else
%         ClRoot(ii,:) = polar(:,2)';
%         CdRoot(ii,:) = polar(:,3)';
%         CmRoot(ii,:) = polar(:,5)';
%     end

%%%%%%%%%%%%
% figure()
% surf(XX, YY, F_cl(XX, YY), 'FaceColor', 'r', 'FaceAlpha', 0.5)
% hold on
% surf(XX,  YY, ClRoot,  'FaceColor', 'g', 'FaceAlpha', 0.5)
% figure()
% surf(XX, YY, F_cl(XX, YY)-ClRoot, 'FaceColor', 'r', 'FaceAlpha', 0.5)
% figure()

% surf(XX, YY, F_cd(XX, YY), 'FaceColor', 'r', 'FaceAlpha', 0.5)
% hold on
% surf(XX,  YY, CdRoot,  'FaceColor', 'g', 'FaceAlpha', 0.5)
% figure()
% surf(XX, YY, F_cd(XX, YY)-CdRoot, 'FaceColor', 'r', 'FaceAlpha', 0.5)
% figure()

% surf(XX, YY, F_cm(XX, YY), 'FaceColor', 'r', 'FaceAlpha', 0.5)
% hold on
% surf(XX,  YY, CmRoot,  'FaceColor', 'g', 'FaceAlpha', 0.5)
% figure()
% surf(XX, YY, F_cm(XX, YY)-CmRoot, 'FaceColor', 'r', 'FaceAlpha', 0.5)