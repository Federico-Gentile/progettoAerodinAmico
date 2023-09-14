figure(1);

for ii = 1:length(inp.collList)
    currColl = inp.collList(ii);
    if inp.uniformInflow(ii) == 0
        lineType = '--';
    elseif inp.uniformInflow(ii) == 1
        lineType = '-';
    end

    subplot(2,4,1); grid minor; hold on; 
    x = results.(rowNames(ii)).mach;
    y = results.(rowNames(ii)).alpha;
    plot(x, y, lineType, 'DisplayName', rowNames(ii)); 
    xlabel('Ma');
    ylabel('$\alpha$ [$\circ$]', 'Interpreter', 'latex');
    legend('Location','best', 'Interpreter', 'none'); 

    subplot(2,4,5); hold on;
    x = inp.x;
    y = results.(rowNames(ii)).alpha;
    plot(x, y, lineType, 'DisplayName', rowNames(ii));
    xlabel('r [m]');
    ylabel('$\alpha$ [$\circ$]', 'Interpreter', 'latex');
    legend('Location','best', 'Interpreter', 'none'); grid minor;

    subplot(2,4,2); hold on;
    x = inp.x;
    y = results.(rowNames(ii)).cl;
    plot(x, y, lineType, 'DisplayName', rowNames(ii));
    xlabel('r [m]');
    ylabel('$C_l$ [-]', 'Interpreter', 'latex');
    legend('Location','best', 'Interpreter', 'none'); grid minor;

    subplot(2,4,6); hold on;
    x = inp.x;
    y = results.(rowNames(ii)).cd;
    plot(x, y, lineType, 'DisplayName', rowNames(ii));
    xlabel('r [m]');
    ylabel('$C_d$ [-]', 'Interpreter', 'latex');
    legend('Location','best', 'Interpreter', 'none'); grid minor;

    subplot(2,4,3); hold on;
    x = inp.x;
    y = results.(rowNames(ii)).L;
    plot(x, y, lineType, 'DisplayName', rowNames(ii));
    xlabel('r [m]');
    ylabel('$l$ [-]', 'Interpreter', 'latex');
    legend('Location','best', 'Interpreter', 'none'); grid minor;

    subplot(2,4,7); hold on;
    x = inp.x;
    y = results.(rowNames(ii)).D;
    plot(x, y, lineType, 'DisplayName', rowNames(ii));
    xlabel('r [m]');
    ylabel('$d$ [-]', 'Interpreter', 'latex');
    legend('Location','best', 'Interpreter', 'none'); grid minor;

    subplot(2,4,4); hold on;
    x = inp.x;
    y = results.(rowNames(ii)).Fz;
    plot(x, y, lineType, 'DisplayName', rowNames(ii));
    xlabel('r [m]');
    ylabel('$F_z$ [-]', 'Interpreter', 'latex');
    legend('Location','best', 'Interpreter', 'none'); grid minor;

    subplot(2,4,8); hold on;
    x = inp.x;
    y = results.(rowNames(ii)).Fx;
    plot(x, y, lineType, 'DisplayName', rowNames(ii));
    xlabel('r [m]');
    ylabel('$F_x$ [-]', 'Interpreter', 'latex');
    legend('Location','best', 'Interpreter', 'none'); grid minor;

end

figure(2);

for ii = 1:length(inp.collList)
    currColl = inp.collList(ii);
    if inp.uniformInflow(ii) == 0
        lineType = '--';
    elseif inp.uniformInflow(ii) == 1
        lineType = '-';
    end

    subplot(1,2,1); hold on;
    x = inp.x;
    y = results.(rowNames(ii)).cm;
    plot(x, y, lineType, 'DisplayName', rowNames(ii));
    xlabel('r [m]');
    ylabel('$C_m$ [-]', 'Interpreter', 'latex');
    legend('Location','best', 'Interpreter', 'none'); grid minor;

    subplot(1,2,2); hold on;
    x = inp.x;
    y = results.(rowNames(ii)).M;
    plot(x, y, lineType, 'DisplayName', rowNames(ii));
    xlabel('r [m]');
    ylabel('$M$ [Nm]', 'Interpreter', 'latex');
    legend('Location','best', 'Interpreter', 'none'); grid minor;

end

figure(3);

for ii = 1:length(inp.collList)
    currColl = inp.collList(ii);
    if inp.uniformInflow(ii) == 1
        lineType = '--';
        y = repmat(results.(rowNames(ii)).vi, length(inp.x), 1);
    elseif inp.uniformInflow(ii) == 0
        lineType = '-';
        y = results.(rowNames(ii)).viDistr;
    end

    hold on;
    x = inp.x;
    plot(x, y, lineType, 'DisplayName', rowNames(ii));
    xlabel('r [m]');
    ylabel('$v_i$ [-]', 'Interpreter', 'latex');
    legend('Location','best', 'Interpreter', 'none'); grid minor;
end

clearvars x y out currColl currFieldName Tvec Qvec Pvec rowNames ftozero f ii