clear
%% rv
N = 12;
FFMC = 1;
DMC = 2;
DC = 3;
ISI = 4;
temp = 5;
RH = 6;
wind = 7;
rain = 8;
BUI = 9;
Fuel = 10;
Weather = 11;
Area = 12;
%% dag
dag = zeros(N,N);
dag(DMC,BUI) = 1;
dag(DC,BUI) = 1;
dag(BUI,Fuel) = 1;
dag(ISI,Fuel) = 1;
dag(FFMC,[ISI,Fuel]) = 1;
dag(Fuel,Area) = 1;
dag(temp,[FFMC,Weather]) = 1;
dag(rain,[FFMC,Weather]) = 1;
dag(RH,Weather) = 1;
dag(Weather,Area) = 1;
dag(wind,Area) = 1;
%% data
load fire.csv;
firenum = length(fire);
fire(9,:) = log(fire(9,:)+1);
train = fire(:,1:int32(firenum*0.7));
validate = fire(:,1:int32(firenum*0.3));
modelnum = length(train);
validnum = length(validate);
%% param
mFFMC = mean(train(1,:));
mDMC = mean(train(2,:));
mDC = mean(train(3,:));
mISI = mean(train(4,:));
mtemp = mean(train(5,:));
mRH = mean(train(6,:));
mwind = mean(train(7,:));
mrain = mean(train(8,:));
mArea = mean(train(9,:));
%% prob
pFFMC11 = sum(train(1,:)<mFFMC&train(5,:)<mtemp&train(8,:)<mrain)/modelnum;
pFFMC12 = sum(train(1,:)<mFFMC&train(5,:)>=mtemp&train(8,:)<mrain)/modelnum;
pFFMC21 = sum(train(1,:)<mFFMC&train(5,:)<mtemp&train(8,:)>=mrain)/modelnum;
pFFMC22 = sum(train(1,:)<mFFMC&train(5,:)>=mtemp&train(8,:)>=mrain)/modelnum;
pDMC = sum(train(2,:)<mDMC)/modelnum;
pDC = sum(train(3,:)<mDC)/modelnum;
pISI1 = sum(train(4,:)<mISI&train(1,:)<mFFMC)/modelnum;
pISI2 = sum(train(4,:)<mISI&train(1,:)>=mFFMC)/modelnum;
ptemp = sum(train(5,:)<mtemp)/modelnum;
pRH = sum(train(6,:)<mRH)/modelnum;
pwind = sum(train(7,:)<mwind)/modelnum;
prain = sum(train(8,:)<mrain)/modelnum;
%% bnet
discrete_nodes = 1:N;
node_sizes = 2*ones(1,N);
onodes = [];
bnet = mk_bnet(dag, node_sizes,...
    'discrete', discrete_nodes,...
    'observed', onodes...
);
%% param
bnet.CPD{FFMC} = tabular_CPD(bnet, FFMC,...
    [pFFMC11 1-pFFMC11 pFFMC12 1-pFFMC12 pFFMC11 1-pFFMC21 pFFMC11 1-pFFMC22]);
bnet.CPD{DMC} = tabular_CPD(bnet, DMC, [pDMC 1-pDMC]);
bnet.CPD{DC} = tabular_CPD(bnet, DC, [pDC 1-DC]);
bnet.CPD{ISI} = tabular_CPD(bnet, ISI, [pISI1, 1-pISI1 pISI2 1-pISI2]);
bnet.CPD{temp} = tabular_CPD(bnet, temp, [ptemp 1-temp]);
bnet.CPD{RH} = tabular_CPD(bnet, RH, [pRH 1-pRH]);
bnet.CPD{wind} = tabular_CPD(bnet, wind, [pwind 1-pwind]);
bnet.CPD{rain} = tabular_CPD(bnet, rain, [prain 1-prain]);
bnet.CPD{BUI} = tabular_CPD(bnet, BUI, 0.5*ones(1,8));
bnet.CPD{Fuel} = tabular_CPD(bnet, Fuel, 0.5*ones(1,16));
bnet.CPD{Weather} = tabular_CPD(bnet, Weather, 0.5*ones(1,16));
bnet.CPD{Area} = tabular_CPD(bnet, Area, 0.5*ones(1,16));
%% validate
engine = gibbs_sampling_inf_engine(bnet);
evidence = cell(1,N);
for i=1:10
    evidence{FFMC} = fire(1,i);
    evidence{DMC} = fire(2,i);
    evidence{DC} = fire(3,i);
    evidence{ISI} = fire(4,i);
    evidence{temp} = fire(5,i);
    evidence{RH} = fire(6,i);
    evidence{wind} = fire(7,i);
    evidence{rain} = fire(8,i);
    [engine, loglik] = enter_evidence(engine, evidence);
    marg = marginal_nodes(engine, Area);
    %(train(9,i)-marg.T)^2;
end
