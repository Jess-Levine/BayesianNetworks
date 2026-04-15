#
# BayesianNetworks: Bayesian network objects and belief propagation
#
#! @Chapter Introduction
#!
#! BayesianNetworks is a package which does some
#! interesting and cool things
#!
#! @Chapter Functionality
#!
#!
#! @Section Example Methods
#!
#! This section will describe the example
#! methods of BayesianNetworks

#! @Description
#!   Insert documentation for your function here
DeclareCategory("IsBayesianNetwork", IsDigraph);

#! @Description
#!   Insert documentation for your function here
DeclareOperation("BayesianNetwork", [IsDigraph, IsList]);

#! @Description
#!   Insert documentation for your function here
DeclareOperation("BeliefPropagation", [IsDigraph, IsInt, IsList]);

#! @Description
#!   Insert documentation for your function here
DeclareOperation("GetCPT", [IsDigraph, IsInt]);
