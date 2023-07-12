
% Puma rotor parameters
rotData.R = 7.49;                   %Rotor radius m
rotData.c = 0.537;                  %Blade chord m
rotData.omega = 28.27433388;        %Rotor angular speed rad/s
rotData.cutout = 2;                 %Blade cutout m
rotData.EW = 37600;                 %EW N      
rotData.GW =52000;                  %GW N
rotData.MTWO = 74000;               %MTOW N
rotData.Ad = pi^2 * rotData.R;      %Disk area m^2

if inp.bladeType == 0

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

elseif inp.bladeType == 1

    rotData.flap_hinge_axis = 0.289;	        % [m]
    rotData.pitch_link = 0.289;		        % [m]
    rotData.pitch_bearing = 0.432;            % [m]
    rotData.n_elem_f = 5;                     % Number of grid points between flap hinge and pitch bearing
    rotData.n_elem_b = 75;                    % Number of point after pitch bearing
    rotData.n_modb = 6;                       % Number of bending modes           
    rotData.n_modt = 6;                       % Number of torsional modes
    rotData.No_c = 8;                         % Number of total coupled modes


    Data.blade_cg_offset = [
                % Radial location	C.G. offset (wrt. quarter chord, positive forward)
                % r			(x/c)_u(nmodified)
                % m			adim.
                0.280			 0.000
                1.887			 0.000
                1.887			-0.010
                7.070			-0.010
                7.070			 0.030
                7.390			 0.030
                7.390			 0.147
                7.402			 0.147
                7.402			 0.000
                7.490			 0.000
                ];

    Data.blade_twist = [
        % Radial location	Twist
        % r			Theta_u(nmodified)
        % m			deg
        0.280			 0.000
        0.760			 0.000
        0.760			 0.000
        1.757			 0.000
        1.757			 0.000
        2.007			-0.100
        2.007			-0.100
        2.257			-0.300
        2.257			-0.300
        2.507			-0.617
        2.507			-0.617
        2.757			-0.983
        2.757			-0.983
        3.007			-1.283
        3.007			-1.283
        3.257			-1.600
        3.257			-1.600
        3.507			-1.867
        3.507			-1.867
        6.257			-4.800
        6.257			-4.800
        7.490			-6.117
        ];
        
    Data.blade_mass = [
        % Radial location	Running mass
        % r			m_u(nmodified)
        % m			kg/m
        0.280			58.400
        0.610			58.400
        0.610			50.000
        0.730			50.000
        0.730			16.175
        0.754			16.175
        0.754			53.333
        0.760			53.333
        0.760			24.949
        0.800			24.949
        0.800			33.100
        0.840			33.100
        0.840			22.400
        1.040			22.400
        1.040			17.110
        1.110			17.110
        1.110			11.225
        1.260			11.225
        1.260			 7.150
        1.770			 7.150
        1.770			 7.150
        1.887			 8.929
        1.887			 8.929
        7.070			 8.929
        7.070			12.754
        7.390			12.754
        7.390			34.600
        7.402			34.600
        7.402			 6.930
        7.490			 6.930
        ];
        
    Data.blade_torsional_inertia = [
        % Radial location	Torsional inertia
        % r			(I_Theta)_u(nmodified)
        % m			kg m
        0.280			0.000
        0.604			0.000
        0.604			0.192
        0.610			0.192
        0.610			0.164
        0.730			0.178
        0.730			0.116
        0.754			0.130
        0.754			0.427
        0.760			0.438
        0.760			0.205
        0.800			0.240
        0.800			0.318
        0.836			0.359
        0.836			0.359
        0.837			0.120
        0.837			0.120
        0.840			0.121
        0.840			0.082
        1.017			0.121
        1.017			0.121
        1.040			0.098
        1.040			0.075
        1.085			0.040
        1.085			0.040
        1.110			0.040
        1.110			0.026
        1.260			0.026
        1.260			0.017
        1.770			0.037
        1.770			0.087
        1.887			0.109
        1.887			0.109
        7.070			0.109
        7.070			0.156
        7.390			0.156
        7.390			0.337
        7.402			0.067
        7.402			0.067
        7.434			0.067
        7.434			0.118
        7.490			0.118
        ];
        
        
    Data.blade_extensional_stiffness = [
        % Radial location	Extensional stiffness
        % r			(EA)_u(nmodified)
        % m			N
        0.280			5.69e8
        0.760			5.69e8
        0.760			5.63e8
        0.820			5.63e8
        0.820			3.77e8
        0.873			3.77e8
        0.873			5.69e8
        0.965			5.69e8
        0.965			5.50e8
        1.040			5.50e8
        1.040			4.74e8
        1.111			4.74e8
        1.111			3.74e8
        1.260			3.74e8
        1.260			1.70e8
        1.697			1.69e8
        1.697			1.69e8
        1.757			1.65e8
        1.757			1.65e8
        1.880			1.71e8
        1.880			1.71e8
        2.128			1.70e8
        2.128			1.70e8
        2.278			1.51e8
        2.278			1.51e8
        5.250			1.45e8
        5.250			1.45e8
        5.800			1.44e8
        5.800			1.44e8
        6.110			1.43e8
        6.110			1.43e8
        7.350			1.43e8
        7.350			1.61e8
        7.382			1.61e8
        7.382			1.16e8
        7.490			1.16e8
        ];
        
    Data.blade_flap_chord_stiffness = [
        % Radial location	Flap stiffness		Chord stiffness
        % r			(EI_f)_u(nmodified)	(EI_c)_u(nmodified)
        % m			Nm^2			Nm^2
        0.280			178.00e4		178.00e4
        0.600			178.00e4		178.00e4
        0.600			178.00e4		178.00e4
        0.610			137.00e4		137.00e4
        0.610			137.00e4		137.00e4
        0.800			137.00e4		137.00e4
        0.800			137.00e4		137.00e4
        0.810			 41.20e4		178.00e4
        0.810			 41.20e4		178.00e4
        1.240			 41.00e4		178.00e4
        1.240			 41.00e4		178.00e4
        1.250			  8.10e4		153.00e4
        1.250			  8.10e4		153.00e4
        7.300			  8.10e4		144.00e4
        7.300			  8.10e4		144.00e4
        7.310			  8.20e4		 71.50e4
        7.310			  8.20e4		 71.50e4
        7.490			  8.20e4		 71.50e4
        ];
        
    Data.blade_torsional_stiffness = [
        % Radial location	Torsional stiffness
        % r			(GJ)_u(nmodified)
        % m			Nm^2
        0.280			 84.00e4
        0.725			 84.00e4
        0.725			226.00e4
        0.828			226.00e4
        0.828			 50.50e4
        1.017			 50.50e4
        1.017			  8.50e4
        7.241			  8.50e4
        7.241			  8.70e4
        7.490			  8.70e4
        ];

end
