function raw = process_data(csvfile)
    close all
    raw = csvread(csvfile,1,1);
    Vdc = raw(:,1);
    I = raw(:,2);
    Ws = raw(:,5);
    Pwr = raw(:,3);
    % remove the empty data
    [~,zidx] = max(I>0);
    zidx = zidx - 1;
    Vdc(1:zidx) = [];
    I(1:zidx) = [];
    Ws(1:zidx) = [];
    Pwr(1:zidx) = [];
    Vdcp = normalize_and_remove_mean(Vdc);
    Ip = normalize_and_remove_mean(I);
    Wsp = normalize_and_remove_mean(Ws);
    Pwrp = normalize_and_remove_mean(Pwr);

    %plot 1
    subplot(2,1,1)
    plot(I);
    xlabel('time [s]')
    ylabel('Idc [A]')
    grid on
    subplot(2,1,2)
    plot(Ws);
    xlabel('time [s]')
    ylabel('Wind Speed [m/s]')
    grid on

    %plot 2
    figure
    plot(I);
    hold on
    plot(Ws,'red');
    xlabel('time [s]')
    legend('Idc [A]','Wind Speed [m/s]')
    grid on

    %plot 3
    figure
    plot(Ip,'LineWidth',2);
    title('Normalized amplitude (mean = 0)')
    hold on
    plot(Wsp,'red','LineWidth',2);
    xlabel('time [s]')
    legend('Idc [A]','Wind Speed [m/s]')
    grid on
    save_to_file('i_norm.dat',Ip);
    save_to_file('ws_norm.dat',Wsp);

    
    %plot 4
    figure
    subplot(2,1,1)
    sgolayCoef = 11;
    sgolayOrder = 1;
    plot(Pwr)
    hold on
    plot(sgolayfilt(Pwr,sgolayOrder,sgolayCoef),'red','LineWidth',2);
    xlabel('time [s]');
    ylabel('Pwr [W]');
    grid on
    subplot(2,1,2)
    plot(Vdc);
    xlabel('time [s]')
    ylabel('Vdc [V]')
    grid on
    
    %plot 5
    figure
    subplot(3,1,1)
%    sgolayCoef = 11;
%    sgolayOrder = 1;
    plot(Vdc)
    xlabel('time [s]');
    ylabel('Vdc [V]');
    grid on
    subplot(3,1,2)
    plot(I);
    xlabel('time [s]')
    ylabel('Idc [A]')
    grid on
    subplot(3,1,3)
    plot(Ws);
    xlabel('time [s]')
    ylabel('Wind Speed [m/s]')
    grid on
    
    if 0
        %remove chopper breaks
        zidx = I > 0;
        while ~isempty(zidx)
            [val,idx] = min(zidx);
            if val < 1
                if idx+45 >= length(I)
                    I(idx:end) = [];
                    Ws(idx:end) = [];
                    Vdc(idx:end) = [];
                    zidx(idx:end) = [];
                else
                    I(idx:(idx+45)) = [];
                    Ws(idx:(idx+45)) = [];
                    Vdc(idx:(idx+45)) = [];
                    zidx(idx:(idx+45)) = [];
                end
            else
                break;
            end
        end
    end %if 0
    
    %plot 6
    figure
    sgolayCoef = 11;
    sgolayOrder = 1;
    subplot(2,1,1)
    plot(I);
    Ifilt = sgolayfilt(I,sgolayOrder,sgolayCoef);
    hold on
    plot(Ifilt,'red','LineWidth',2)
    xlabel('time [s]')
    ylabel('Idc [A]')
    grid on
    subplot(2,1,2)
    plot(Ws);
    Wsfilt = sgolayfilt(Ws,sgolayOrder,sgolayCoef);
    hold on
    plot(Wsfilt,'red','LineWidth',2)
    xlabel('time [s]')
    ylabel('Wind Speed [m/s]')
    grid on
    
    %plot 7
    figure
    plot(normalize_and_remove_mean(Ifilt),'blue','LineWidth',2)
    hold on
    plot(normalize_and_remove_mean(Wsfilt),'red','LineWidth',2)
    Vdcfilt = sgolayfilt(Vdc,sgolayOrder,sgolayCoef);
    plot(normalize_and_remove_mean(Vdcfilt),'black','LineWidth',3)
    grid on
    title('Normalized amplitude (mean = 0) SMOOTHED')
    legend('Idc','Wind Speed','Vdc')
    save_to_file('i_norm_filt.dat',normalize_and_remove_mean(Ifilt));
    save_to_file('ws_norm_filt.dat',normalize_and_remove_mean(Wsfilt));
    
    %plot 8
    figure
    sgolayCoef = 101;
    sgolayOrder = 1;
    Ifilt = sgolayfilt(I,sgolayOrder,sgolayCoef);
    Wsfilt = sgolayfilt(Ws,sgolayOrder,sgolayCoef);
    stem(Wsfilt,Ifilt,'LineStyle','none')
    tit = sprintf('Correlation( I , Ws ) = %f',corr(I,Ws));
    title(tit)
    xlabel('Wind Speed [m/s]')
    ylabel('Idc [A]')
    grid on

    %plot 9
    figure
    stem(Vdcfilt,Ifilt,'LineStyle','none')
    tit = sprintf('Correlation( I , Vd ) = %f',corr(I,Vdc));
    title(tit)
    ylabel('Idc')
    xlabel('Vdc')
    grid on

    %plot 10
    figure
    stem(Vdcfilt,Wsfilt,'LineStyle','none')
    tit = sprintf('Correlation( Vd , Ws ) = %f',corr(Vdc,Ws));
    title(tit)
    ylabel('Wind Speed [m/s]')
    xlabel('Vdc [V]')
    grid on

    %plot 11
    figure
    subplot(2,1,1)
%    sgolayCoef = 11;
%    sgolayOrder = 1;
    plot(Vdc)
    xlabel('time [s]');
    ylabel('Vdc [V]');
    grid on
    subplot(2,1,2)
    plot(Pwr);
    xlabel('time [s]')
    ylabel('Pwr [W]')
    grid on

    %plot 12
    figure
    subplot(2,1,1)
%    sgolayCoef = 11;
%    sgolayOrder = 1;
    plot(Ws)
    xlabel('time [s]');
    ylabel('Wind Speed [m/s]');
    grid on
    subplot(2,1,2)
    plot(Pwr);
    xlabel('time [s]')
    ylabel('Pwr [W]')
    grid on
end

function x_norm_zmean = normalize_and_remove_mean(x)
    x = x - mean(x);
    x = x/max(x);
    x_norm_zmean = x;
%    x = x/max(x);
%    avg = mean(x);
%    x_norm_zmean = x - avg;
end

function save_to_file(path,x)
    f = fopen(path,'w');
    fwrite(f,x,'double');
    fclose(f);
end

