X = 1;
Q = 2;
Y = 3;
dag = zeros(3,3);
dag(X,[Q Y]) = 1;
dag(Q,Y) = 1;
ns = [1 2 1]; % make X and Y scalars, and have 2 experts
onodes = [1 3];
bnet = mk_bnet(dag, ns, 'discrete', 2, 'observed', onodes);

rand('state', 0);
randn('state', 0);
bnet.CPD{1} = root_CPD(bnet, 1);
bnet.CPD{2} = softmax_CPD(bnet, 2);
bnet.CPD{3} = gaussian_CPD(bnet, 3);
