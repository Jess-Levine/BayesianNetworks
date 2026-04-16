#
# BayesianNetworks: Bayesian network objects and belief propagation
#

#! @Chapter Introduction
#!
#! The \texttt{BayesianNetworks} package provides functionality for the
#! construction and manipulation of Bayesian networks within the GAP system.
#! A Bayesian network is a probabilistic graphical model represented as a
#! directed acyclic graph (DAG), in which vertices correspond to random
#! variables and edges represent conditional dependencies.
#!
#! This package extends the \texttt{Digraphs} package by associating each
#! vertex with a conditional probability table (CPT), allowing probabilistic
#! models to be defined directly on graph structures. The resulting objects
#! combine graph-theoretic and probabilistic representations within a single
#! framework.
#!
#! The implementation focuses on binary-valued variables and supports exact
#! probabilistic inference using a belief propagation (message-passing)
#! algorithm on polytree-structured networks. The design prioritises
#! transparency, exposing the underlying computations rather than relying on
#! encapsulated inference engines.
#!

#! @Chapter Functionality
#!
#! The package provides the following core functionality:
#!
#! \begin{itemize}
#! \item Construction and validation of Bayesian network objects from a
#!       directed graph and a list of CPTs
#! \item Representation of conditional probability tables as vertex labels
#! \item Exact inference using belief propagation
#! \item Retrieval of CPTs associated with individual vertices
#! \end{itemize}
#!
#! Bayesian networks created using this package are required to be polytrees,
#! ensuring that exact inference via message passing is well-defined and
#! computationally efficient.
#!

#! @Section Example Usage
#!
#! The following example demonstrates the construction of a simple Bayesian
#! network and the evaluation of a posterior probability.
#!
#! First, construct a directed graph using the \texttt{Digraphs} package:
#!
#! \begin{verbatim}
#! D := Digraph([[2,3], [], []]);
#! \end{verbatim}
#!
#! Define conditional probability tables (CPTs) for each vertex:
#!
#! \begin{verbatim}
#! CPT := [
#!   [ [0.9, 0.1] ],
#!   [ [0.7, 0.3], [0.2, 0.8] ],
#!   [ [0.6, 0.4], [0.1, 0.9] ]
#! ];
#! \end{verbatim}
#!
#! Construct the Bayesian network:
#!
#! \begin{verbatim}
#! BN := BayesianNetwork(D, CPT);
#! \end{verbatim}
#!
#! Perform belief propagation to compute the posterior probability of a node:
#!
#! \begin{verbatim}
#! BeliefPropagation(BN, 1, [ [2, true] ]);
#! \end{verbatim}
#!
#! This returns a probability vector representing the belief of the target
#! node given the specified evidence.
#!
#! Conditional probability tables can be accessed using:
#!
#! \begin{verbatim}
#! GetCPT(BN, 1);
#! \end{verbatim}
#!
#! which returns the CPT associated with vertex 1.
#!

DeclareCategory("IsBayesianNetwork", IsDigraph);

#! @Description
#############################################################################
##
#O  BayesianNetwork( <D>, <CPT> )
##
##  Creates a Bayesian Network object from a directed graph and a list of
##  conditional probability tables (CPTs).
##
##  <D> must be a directed acyclic graph representing the structure of the
##  Bayesian network. In addition, the underlying undirected graph must be
##  connected and contain exactly (n - 1) edges, ensuring that the graph
##  forms a polytree.
##
##  <CPT> must be a list of matrices, where each matrix corresponds to a
##  vertex in <D>. Each CPT defines the conditional probability distribution
##  of a node given its parent configuration.
##
##  The following conditions are enforced:
##    - The number of CPTs must equal the number of vertices in <D>.
##    - Each CPT must be a rectangular matrix with exactly two columns.
##    - Each entry must be a float in the range [0,1].
##    - Each row must sum to 1.
##    - The number of rows must equal 2^k, where k is the number of parents
##      of the corresponding node.
##
##  On successful construction, the CPT list is stored as vertex labels of
##  the graph and the resulting object is filtered as an IsBayesianNetwork.
##
#############################################################################
DeclareOperation("BayesianNetwork", [IsDigraph, IsList]);

#! @Description
#############################################################################
##
#O  BeliefPropagation( <BN>, <X>, <e> )
##
##  Performs exact belief propagation on a Bayesian network using Pearl's
##  message-passing algorithm for polytree-structured graphs.
##
##  <BN> must be a valid Bayesian network object.
##  <X> is an integer specifying the target vertex.
##  <e> is a list of evidence of the form [ [vertex, value], ... ], where
##      value is a Boolean (true/false).
##
##  The method computes the posterior belief:
##
##      P(X | e)
##
##  by propagating messages between parents and children in the network.
##
##  The algorithm maintains:
##    - prior messages (π messages) from parent nodes
##    - likelihood messages (λ messages) from child nodes
##
##  Message passing is performed recursively over the directed structure of
##  the graph, exploiting conditional independence encoded by the network.
##
##  The result is returned as a normalised probability vector of length 2,
##  corresponding to the probabilities of X being true or false.
##
##  Note: This implementation assumes the network is a polytree and does not
##  support general loopy graphs.
##
#############################################################################
DeclareOperation("BeliefPropagation", [IsBayesianNetwork, IsInt, IsList]);

#! @Description
#############################################################################
##
#O  GetCPT( <BN>, <n> )
##
##  Returns the conditional probability table associated with vertex <n>
##  in the Bayesian network <BN>.
##
##  The CPT is stored internally as the vertex label of the underlying
##  directed graph.
##
#############################################################################
DeclareOperation("GetCPT", [IsBayesianNetwork, IsInt]);
