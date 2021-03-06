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

function [ kpp1 ] = calc_kpp1( res, seqi, comm, prices )
%CALC_KPP1 Summary of this function goes here
%   Detailed explanation goes here

iF1 = [1 2       9           17 18];
iF2 = [3 4 5     10 11 12    19 20];
iF3 = [6         13 14       21 22];
iF4 = [7 8       15 16       23 24 25];

iI = [1:8];
iP = [9:16];
iC = [17:25];
iM = [26:27];

P(:,[iF1 iF2 iF3])  = res.misc_1(:,[iF1 iF2 iF3]);
P(:,iF4)            = res.misc_1(:,[iF4])* 20;
P(:,iM)             = res.motor(:,[1 5]);

N = 50;
M = length(P(:,1));

%% Demands
Demand = [300   250     300     600     400     600     20*15   20*20 ...       % Interruptable
          1000  1000    1000    600     700     1000    20*10   20*10 ...       % Priority
          1200  1500    1000    1000    1000    800     20*25   20*20   20*3 ...% Critical
          200   200];                                                            % Motors
D = repmat(Demand, M, 1);
D(:,iM(1)) = D(:,iM(1)).*seqi.motor1;
D(:,iM(2)) = D(:,iM(2)).*seqi.motor2;

TotalDemand = sum(Demand);

%% Calculate power

P_good = zeros(M,N);
P_good(P>(D./2)) = P(P>(D./2));

P_outage = zeros(M,N);
P_outage(P<(D./2)) = D(P<(D./2));

P_good_per_class = zeros(M,4);
P_outage_per_class = zeros(M,4);
P_good_per_class(:,1) = sum(P_good(:,iM),2);
P_good_per_class(:,2) = sum(P_good(:,iI),2);
P_good_per_class(:,3) = sum(P_good(:,iP),2);
P_good_per_class(:,4) = sum(P_good(:,iC),2);
P_outage_per_class(:,1) = sum(P_outage(:,iM),2);
P_outage_per_class(:,2) = sum(P_outage(:,iI),2);
P_outage_per_class(:,3) = sum(P_outage(:,iP),2);
P_outage_per_class(:,4) = sum(P_outage(:,iC),2);

E = res.Speed * cumsum(P*seqi.opt.Ts/3600);
E_good_per_class = res.Speed * cumsum(P_good_per_class*seqi.opt.Ts/3600);
EO_per_class = res.Speed * cumsum(P_outage_per_class*seqi.opt.Ts/3600);

EP_per_class = E_good_per_class .* repmat([prices.P12 prices.P13 prices.P12 prices.P11],M,1);
EOP_per_class = EO_per_class .* repmat([prices.P16 0 prices.P16 prices.P15],M,1);

%% Energy stored in the battery
if (isfield(res, 'PHIL') && (res.PHIL==1))
    ESS2_Capacity = 12000;
else
    ESS2_Capacity = 1200;
end;
ESS1_Capacity = 600;
e_batt = res.battery_SoC/10000 .* repmat([ESS1_Capacity ESS2_Capacity],M,1);
e_batt_diff = e_batt - repmat(e_batt(1,:), M, 1);

d_batt_diff_indiv = e_batt_diff .* prices.P17;
d_batt_diff = sum(e_batt_diff,2) .* prices.P17;


%%
d_cum_per_class = [EP_per_class -EOP_per_class d_batt_diff];
d_cum_per_class_legend = {'M' 'I' 'P' 'C' 'ESS'};
d_cum_total = sum(d_cum_per_class,2);

clear( 'res', 'seqi', 'comm', 'prices' );
kpp1=wsp2struct(who);


