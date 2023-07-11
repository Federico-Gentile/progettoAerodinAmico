
% Puma rotor parameters
rotData.R = 7.49;                   %Rotor radius m
rotData.c = 0.537;                  %Blade chord m
rotData.omega = 28.27433388;        %Rotor angular speed rad/s
rotData.cutout = 2;                 %Blade cutout m
rotData.EW = 37600;                 %EW N      
rotData.GW =52000;                  %GW N
rotData.MTWO = 74000;               % MTOW N
rotData.Ad = pi^2 * rotData.R;      %Disk area m^2

%Blade twist deg
rotData.rTw = [ 0
                0.28
                0.76
                1.757
                2.007
                2.257
                2.507
                2.757
                3.007
                3.257
                3.507
                6.257
                7.49 ];

rotData.Twi = [ 0
                0
                0
                0
                -0.1
                -0.3
                -0.617
                -0.983
                -1.283
                -1.6
                -1.867
                -4.8
                -6.111 ];
