function tempField = calcTField(winkel, abstand, alpha, Pe)
	% Aufteilen der Zylinderquellenlösung in drei Formeln
	factor1 = @(abstand, winkel) exp((-Pe/2) .* abstand .* cos(winkel));
	factor2 = @(abstand) (besseli(0, Pe.*alpha/2) ./ besselk(0, Pe.*alpha/2)) .* besselk(0, Pe.*abstand/2);
	factor3 = @(abstand, winkel, n) (besseli(n, Pe.*alpha/2) ./ besselk(n, Pe.*alpha/2)) .* besselk(n, Pe.*abstand/2) .* cos(n.*winkel);
	
	% Berechnung der ersten beiden Formeln
	theta1 = factor1(abstand, winkel);
	theta2 = factor2(abstand);
	
	% Die dritte Formel ist eine Reihe --> Abbruch der Summation wenn
	% zusätzlicher Term < 1e-9 ist
	theta3 = zeros(1, length(abstand));
	i = 1;
	while true
		temptheta3 = factor3(abstand, winkel, i);
		theta3 = sum([temptheta3; theta3]);
		i = i + 1;
		
		if median(abs(temptheta3))/median(abs(theta3)) < 1e-6
			break;
		end
	end
	
	% Zusammensetzen der drei Formeln zur gesamt Berechnung des
	% Temperaturfeldes
	tempField = theta1 .* (theta2 + 2.*theta3);
end