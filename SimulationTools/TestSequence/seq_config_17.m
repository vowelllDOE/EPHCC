%% Copyright 2018 Alliance for Sustainable Energy, LLC
%
% Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
% and associated documentation files (the "Software"), to deal in the Software without restriction, 
% including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
% and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
% subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
% BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS, THE COPYRIGHT HOLDERS, THE UNITED STATES, 
% THE UNITED STATES DEPARTMENT OF ENERGY, OR ANY OF THEIR EMPLOYEES BE LIABLE FOR ANY CLAIM, 
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
%
% Author: Przemyslaw Koralewicz / NREL
% Date: 2017

%% This function configures test sequence by configuring time instances and 
% parameters of events
function [out] = init_seq()

%% Generic config
Ts = 0.2;
End = 100*60;
N = End/Ts+1;


%% Initial conditions
% motors command: 0- stop, 1-run
Init('Motor1', 0, 0);
Init('Motor2', 0, 0);
% DER failure command: 0- ok, 1-failed
Init('Fault.Gen1', 0, 0);
Init('Fault.Gen2', 0, 0);
Init('Fault.Gen3', 0, 0);
Init('Fault.Ess1', 0, 0);
Init('Fault.Ess2', 0, 0);
Init('Fault.Pv1', 0, 0);
Init('Fault.Pv2', 0, 0);

% Fault injection
% bitfield, bit no: 0 - fault loc #1, 1- fault loc #2, etc...
Init('Fault.Loc1', 0, 0);
Init('Fault.Loc2', 0, 0);
Init('Fault.Loc3', 0, 0);
Init('Fault.Loc4', 0, 0);
Init('Fault.Loc5', 0, 0);
Init('Fault.Loc6', 0, 0);
% DMS
Init('DMS.DisReq', 0, 0);
Init('DMS.kWena', 0, 0);
Init('DMS.PFena', 0, 0);
Init('DMS.kWref', 0, 0);
Init('DMS.PFref', 0, 1.0);
Init('DMS.Dp', 0, 3);
Init('DMS.Dq', 0, 6);
%
% Grid cut
Init('Grid.CutGrid', 0, 0);
Init('Grid.OpenSSF1', 0, 0);
Init('Grid.OpenSSF2', 0, 0);
Init('Grid.OpenSSF3', 0, 0);
%Grid.Freq(n) - events
%Grid.Voltage(n) - events
Init('MGC_Enable', 0, 0);            % start of test sequence

Nc = 0; % Irradiance - Nc= cloud number
Nf = 0; % Frequency events counter
Nv = 0; % Voltage event counter

%% Solar
CloudDelay = 20;

Irradiance.Rise = 20*60;            % FIX, Sunrise beginning time t=20min
Irradiance.RiseDuration = 40*60;    % FIX, Duration of ramp until full irradiance

Nc=Nc+1; Cloud(Nc) = struct('Start', 33*60, 'Depth', 0.9, 'Ramp', 20, 'Duration', 120);
Nc=Nc+1; Cloud(Nc) = struct('Start', 40*60, 'Depth', 0.9, 'Ramp', 10, 'Duration', 90);
Nc=Nc+1; Cloud(Nc) = struct('Start', 60*60, 'Depth', 0.9, 'Ramp', 10, 'Duration', 60);
Nc=Nc+1; Cloud(Nc) = struct('Start', 70*60, 'Depth', 0.9, 'Ramp', 10, 'Duration', 30);
Nc=Nc+1; Cloud(Nc) = struct('Start', 76*60, 'Depth', 0.6, 'Ramp', 15, 'Duration', 30);
Nc=Nc+1; Cloud(Nc) = struct('Start', 80*60, 'Depth', 0.7, 'Ramp', 15, 'Duration', 30);
Nc=Nc+1; Cloud(Nc) = struct('Start', 92*60, 'Depth', 0.5, 'Ramp', 5 , 'Duration', 30);

%% Motors
Next('Motor1'   , 3 , 1);
Next('Motor1'   , 14, 0);
Next('Motor1'   , 32, 1);
Next('Motor1'   , 38, 0);
Next('Motor1'   , 47, 1);
Next('Motor1'   , 58, 0);
Next('Motor1'   , 59, 1);
Next('Motor1'   , 72, 0);
Next('Motor1'   , 80, 1);
Next('Motor1'   , 99, 0);


Next('Motor2'   , 15, 1);
Next('Motor2'   , 26, 0);
Next('Motor2'   , 35, 1);
Next('Motor2'   , 56, 0);
Next('Motor2'   , 58, 1);
Next('Motor2'   , 75, 0);
Next('Motor2'   , 85, 1);

%% DER contingencies
Next('Fault.Gen1', 9, 1);
Next('Fault.Gen1', 11, 0);
Next('Fault.Ess1', 27, 1);
Next('Fault.Ess1', 28.5, 0);
Next('Fault.Gen2', 37, 1);
Next('Fault.Gen2', 38.5, 0);
Next('Fault.Ess1', 52, 1);
Next('Fault.Ess1', 53.5, 0);
Next('Fault.Gen1', 73, 1);
Next('Fault.Gen1', 74.5, 0);
Next('Fault.Pv1', 83, 1);
Next('Fault.Pv1', 85, 0);
Next('Fault.Pv1', 94, 1);
Next('Fault.Pv1', 96, 0);

%% Sequence start - grid connected
Next('MGC_Enable', 2/60, 1);            % start of test sequence

Next('DMS.kWena', 8, 1);
Next('DMS.kWref', 8, 8000);         % DMS xport request
Next('DMS.PFena', 1, 1);
Next('DMS.PFref', 1, 1.0);         % unity power factor request
Nf=Nf+1; Grid.Freq(Nf) = struct('Start', 9*60, 'Depth', -0.6, 'Duration', 20);
Next('DMS.kWena', 12, 0);
Next('DMS.kWref', 12, 0);           % DMS xport request
Next('DMS.PFena', 16, 0);           % unity power factor request




%% PLanned islanding - start island
Next('DMS.DisReq'     , 22, 1);
Next('Grid.OpenSSF1'  , 23.3, 1); 
Next('Grid.OpenSSF2'  , 23.4, 1); 
Next('Grid.OpenSSF3'  , 23.5, 1); 
Next('Grid.CutGrid'   , 23.6, 1); 

Next('Grid.CutGrid'    , 44,   0); 
Next('Grid.OpenSSF1'   , 44.1, 0); 
Next('Grid.OpenSSF2'   , 44.2, 0); 
Next('Grid.OpenSSF3'   , 44.3, 0); 
Next('DMS.DisReq'      , 45,   0);

%% End of planned islanding - start grid connected
Next('DMS.kWena', 48, 1);
Next('DMS.kWref', 48, 3000);         % DMS import request
Next('DMS.PFena', 48, 1);
Next('DMS.PFref', 48, 0.97);         
Nf=Nf+1; Grid.Freq(Nf) = struct('Start', 49*60, 'Depth', 0.4, 'Duration', 60);
Next('DMS.kWref', 51, 4000);         % DMS import request
Next('DMS.kWref', 52, 5000);         % DMS import request
Next('DMS.Dp'   , 51, 2);

Next('DMS.kWena', 53, 0);
Next('DMS.kWref', 58, 0);           % DMS import request
Nv=Nv+1; Grid.Volt(Nv) = struct('Start', 59*60, 'Depth', 115000*0.02, 'Duration', 120);
Next('DMS.PFena', 62, 0);


%% Unintentional islanding - start island
Next('Fault.Loc1'      , 65, 1);
Next('Fault.Loc1'      , 66, 0);
Next('DMS.DisReq'      , 65+(10/60),   1);
Next('Grid.OpenSSF1'   , 66, 1); 
Next('Grid.OpenSSF2'   , 66.2, 1); 
Next('Grid.OpenSSF3'   , 66.4, 1); 
Next('Grid.CutGrid'    , 66.6, 1);


Next('Grid.CutGrid'    , 87, 0);
Next('Grid.OpenSSF1'   , 87.2, 0); 
Next('Grid.OpenSSF2'   , 87.4, 0); 
Next('Grid.OpenSSF3'   , 87.6, 0); 
Next('DMS.DisReq'      , 87.7, 0);
%% End of unintentional islanding - start grid connected

Next('DMS.kWena', 90, 1);
Next('DMS.kWref', 90, 10000);         % DMS import request
Next('DMS.PFena', 89, 1);
Next('DMS.PFref', 89, 0.96);         
Nv=Nv+1; Grid.Volt(Nv) = struct('Start', 95*60, 'Depth', -115000*0.03, 'Duration', 150);
Nf=Nf+1; Grid.Freq(Nf) = struct('Start', 92*60, 'Depth', 0.3, 'Duration', 20);
Nf=Nf+1; Grid.Freq(Nf) = struct('Start', 98*60, 'Depth', -0.4, 'Duration', 40);

%% End of sequence
Next('MGC_Enable', 99+58/60, 0);
out=wsp2struct(who);
end

function Next(fieldname, timeMin, value)
    evalin('caller', [fieldname '.Time = [' fieldname '.Time ' num2str(timeMin*60)  '];']);
    evalin('caller', [fieldname '.Val  = [' fieldname '.Val  ' num2str(value) '];']);
end

function Init(fieldname, timeMin, value)
    evalin('caller', [fieldname '.Time = ' num2str(timeMin) ';']);
    evalin('caller', [fieldname '.Val  = ' num2str(value) ';']);
end