function process_data_v2(csvfile)
    close all
    csvfile = 'eolocal_chopper_test1.csv';
    raw = csvread(csvfile,1,1);
    %remove zeros from begining
    raw(1:877,:) = [];
    
    [Idc,Vdc,Ws,Pwr] = remove_breaks(raw);
    Idcnm = remove_mean(Idc);
    Wsnm = remove_mean(Ws);
    
    %plot 1
    figure
    subplot(2,1,1)
    plot(Idc)
    title('Idc')
    grid on
    subplot(2,1,2)
    plot(Ws)
    title('Ws')
    grid on

    
    %plot 3
    figure
    rend = 0.7;
    R = 1.2;
    Voo = raw(:,5);
    Cp = 0.4;
    IdealPower = rend * 0.5 * Cp * 1.225 * pi*R^2 * Voo.^3;
%    subplot(2,1,1)
    hold on
%    plot(IdealPower)
    plot(filter(IdealPower),'red','LineWidth',2)
%    plot(zero_pwr_breaks(raw),'green','LineWidth',2)
    plot(filter(zero_pwr_breaks(raw)),'black','LineWidth',2)
    grid on
    kwh_in  = trapz(IdealPower)/3600;
    kwh_out = trapz(Pwr)/3600;
    title(sprintf('Ideal Energy: %.2f Wh - Harvested Energy: %.2f Wh - Effic: %.2f%%',kwh_in,kwh_out,kwh_out/kwh_in*100))
%    legend('Ideal Power','Ideal Power Filtered','Produced Power','Produced Power Filtered')
    legend('Ideal Power: rend[0.7] * 0.5 * Cp[0.4] * 1.225 * pi*R[1.2]^2 * Voo.^3','Measured Power')
    ylabel('Power [W]')
    xlabel('time [s]')
%     subplot(2,1,2)
%     plot(raw(:,5))
%     legend('Wind Speed [m/s]')
%     grid on
    
    %plot 3
    figure
    plot(filter(0.025*Ws.^2))
    hold on
    plot(filter(Idc),'red')
    title(sprintf('Correlation( Idc , 0.025*Voo^2 ) = %f',corr(0.025*Ws.^2,Idc)))
    legend('Idc*(Voo) = 0.025*Voo^2','Idc')
    grid on
end

function x = remove_mean(x)
    x = x - mean(x);
end

function [Idc,Vdc,Ws,Pwr] = remove_breaks(raw)
    raw((3747+824-877):(3803+824-877),:) = [];
    raw((3448+824-877):(3500+824-877),:) = [];
    raw((3053+824-877):(3107+824-877),:) = [];
    raw((2777+824-877):(2827+824-877),:) = [];
    raw((2253+824-877):(2309+824-877),:) = [];
    raw((1060+824-877):(1111+824-877),:) = [];
    Vdc = raw(:,1);
    Idc = raw(:,2);
    Pwr = raw(:,3);
    Ws  = raw(:,5);
end

function pwr_no_breaks = zero_pwr_breaks(raw)
    raw((3747+824-877):(3803+824-877),:) = 0;
    raw((3448+824-877):(3500+824-877),:) = 0;
    raw((3053+824-877):(3107+824-877),:) = 0;
    raw((2777+824-877):(2827+824-877),:) = 0;
    raw((2253+824-877):(2309+824-877),:) = 0;
    raw((1060+824-877):(1111+824-877),:) = 0;
    pwr_no_breaks = raw(:,3);
end


function x = filter(x)
    sgolayCoef = 11;
    sgolayOrder = 1;
    x = sgolayfilt(x,sgolayOrder,sgolayCoef);
end