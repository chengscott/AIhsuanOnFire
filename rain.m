%% rv
N = 4;
C = 1; S = 2; R = 3; W = 4;
%% dag
dag = zeros(N,N);
dag(C,[R S]) = 1;
dag(R,W) = 1;
dag(S,W) = 1;
%% bnet
discrete_nodes = 1:N;
node_sizes = 2*ones(1,N); 
onodes = [];
bnet = mk_bnet(dag, node_sizes,...
    'discrete', discrete_nodes,...
    'observed', onodes...
);
%% param
bnet.CPD{C} = tabular_CPD(bnet, C, [0.5 0.5]);
bnet.CPD{R} = tabular_CPD(bnet, R, [0.8 0.2 0.2 0.8]);
bnet.CPD{S} = tabular_CPD(bnet, S, [0.5 0.9 0.5 0.1]);
bnet.CPD{W} = tabular_CPD(bnet, W, [1 0.1 0.1 0.01 0 0.9 0.9 0.99]);
%% inference
engine = gibbs_sampling_inf_engine(bnet);
evidence = cell(1,N);
evidence{W} = 2;
[engine, loglik] = enter_evidence(engine, evidence);
marg = marginal_nodes(engine, S);
marg.T