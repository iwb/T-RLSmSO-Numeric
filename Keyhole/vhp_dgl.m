function vhp = vhp_dgl(versatz, param, SensorTemp, iteration, config)
    %% Errechnet den Vorheizpunkt mit Hilfe der Original-DGL
    
    % Initialer Abstand zum Laser
    param.xOffset = 10 * param.w0; % [m]
    %vektorisiert, evtl. Variablenbenennung �ndern
    
    %todo �bergebe config, damit 5001 als Parameter eingesetzt wird
    vhppoints = linspace(0, 10 * param.w0, config.dis.resvhp);
    

    %% Diskretisierung der Zeit
    steps_t = config.dis.vhpstepst;
    %t = linspace(0, param.xOffset/param.v, steps_t);
    %dt = t(2) - t(1);

    %% Intensit�tsvektor berechnen
    
    %todo verschieben in SChleife
    
    

    % Berechnung der diskreten Intensit�ten zu jedem t
    %Alte Berechnung
%     distance = sqrt((xVec.*param.w0).^2 + (yVec.*param.w0).^2);
%     I2 = 0.39 * param.I0 * exp(-distance.^2 ./ (2 * param.w0^2)); % [W/m^2]
    %Neue Berechnung
    

%     figure;
%     plot(I, 'b')
%     hold on
%     plot(I2, 'r')
%     hold off
%     legend('verwendet in keyhole_z', 'urspr�nglich f�r vhp', 'Location', 'NorthWest')

    %% Vorbereitung

    % Die Array sind nur zum Speichern
    TempArray = ones(1, config.dis.resvhp) * 300;
    DeltaArray = zeros(1, config.dis.resvhp);
    IArray = zeros(1, config.dis.resvhp);

    delta = 1e-3;
    
    % Initialisieren mit Temps, Abfrage ob T>300K
    if (numel(SensorTemp) ~= numel(vhppoints))
        fprintf('Achtung, Anzahl �bergebener Sensortemp. �berpr�fen \n');
    end
    
    for i = 1 : length(SensorTemp)
        if (SensorTemp(i) > config.mat.AmbientTemperature)
            Ts(i) = SensorTemp(i);
        else
            Ts(i) = config.mat.AmbientTemperature + 0.01;
            %fprintf('Achtung, Sensortemp. nicht > Umgebungstemp. \n');
        end
    end

    index = 0;
    dTstemp = zeros(1, numel(Ts));

    b2 = 0.6;

    backshift = 4;      % Versetzten der Intensit�tsverteilung [w0]
    dt = 1 / steps_t * backshift * param.w0 / param.v;
    fprintf('Anzahl an time steps vhp: %i (Aufl�sung: %.1f ns)\n', config.dis.vhpstepst, dt*1e9);

    %% Rechnen
    for i = 1:steps_t
        
        % Intensit�t
        t = i / steps_t * backshift * param.w0 / param.v;
        xl = -backshift * param.w0 + t * param.v;
        xVec = (vhppoints - xl) ./ param.w0; % Normierung mit w0
        %yVec = repmat(versatz, 1, steps_t) ./ param.w0; % Normierung mit w0
        yVec = repmat(versatz, 1, config.dis.resvhp) ./ param.w0; % Normierung mit w0
        %zVec = zeros(1, steps_t);
        zVec = zeros(1, config.dis.resvhp);
        points = [xVec; yVec; zVec];
        [pVec, intensity] = calcPoynting(points, param);
        Az = calcFresnel(pVec(:, 1), [0;0;1], param);
        I = param.I0 .* intensity .* Az;
        
        % Vorw�rts-Euler
        % Temperatur
        dTs = param.kappa./((1-b2).*delta) .* (I'./param.lambda - b2.*(Ts'-param.T0)./delta); 
                
        % W�rmeeindringtiefe
        ddelta = 1/(Ts'-param.T0) * (param.kappa*I'/param.lambda - dTstemp'*delta);
        

        dTstemp = dTs';
        Ts = (Ts' + dTs .* dt)';
        delta = delta + ddelta .* dt;

        TempArray(i, :) = Ts;
        DeltaArray(i, :) = delta';
        IArray(i, :) = I;


%         if(mod(i, 100) == 0)
%             figure(2)
%             subplot(2,1,1)
%             plot(t,TempArray)
%             subplot(2,1,2)
%             plot(t,DeltaArray)
%             drawnow;
%         end

        % VHP ausrechnen
        %if ~index && Ts > param.Tv
        %    % VHP gefunden :-)
        %    T1 = TempArray(i-1);
        %    zeitpunkt = t(i-1) + (param.Tv - T1)/(Ts - T1) * dt;
        %    
        %    vhp = (param.xOffset - zeitpunkt*param.v);
        %    
        %    %fprintf('Original DGL - Vorheizpunkt: %0.2f �m\n\n', 5);
        %    return;
        %end
    end
    
    % speichere TempArray, DeltaArray zu Analysezwecken
    output_path = '../Ergebnisse/';
    if (versatz == 0)
        pathaug = [];
    else
        pathaug = 'v';
    end
    vhpPath = [output_path '9 Vorheizen_' num2str(iteration, '%03.0f') pathaug '.mat'];
    %vhpPath = [output_path '9.3 Vorheizen.mat'];
    %vhpArray.(genvarname(['i' num2str(iteration) pathaug])).Temp = TempArray;
    %vhpArray.(genvarname(['i' num2str(iteration) pathaug])).Delta = DeltaArray;
    %vhpArray.(genvarname(['i' num2str(iteration) pathaug])).I = IArray;
    vhpArray.Temp = TempArray;
    vhpArray.Delta = DeltaArray;
    vhpArray.I = IArray;
    save(vhpPath, 'vhpArray');
    
    % Auswertung, ob Tv erreicht wurde
    i = 1;
    while (Ts(i) > param.Tv)
        i = i + 1;
    end        
    
    % lineare Interpolation
    T1 = Ts(i-1);    % T1 > Tv
    T2 = Ts(i);      % T2 < Tv
    x1 = (i-1) / config.dis.resvhp * 10 * param.w0;
    x2 = (i) / config.dis.resvhp * 10 * param.w0;
    try
        xv = x1 + (x2-x1)*(T1-param.Tv)/(T1-T2);
    catch
        xv = 0.5 * (x1 + x2);
    end
        
    vhp = xv;
    return;
    
    vhp = NaN;
end