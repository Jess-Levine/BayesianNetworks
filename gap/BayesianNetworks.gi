#
# BayesianNetworks: Bayesian Network objects and belief propagation
#
# Implementations
#

InstallMethod(BayesianNetwork, "for a digraph and a list of CPT matrices", [IsDigraph, IsList],
function(D, CPT)
  local IsPolytree, n, r;

  IsPolytree := function(D)
    return IsAcyclicDigraph(D)
      and IsConnectedDigraph(D)
      and (DigraphNrEdges(D) = DigraphNrVertices(D) - 1);
  end;

  if not DigraphNrVertices(D) = Length(CPT) then
    ErrorNoReturn("length of CPT list must be equal to number of vertices\n");
  # Need to change this to check BN is polytree (the underlying undirected graph is acylic)
  elif not IsPolytree(D) then
    ErrorNoReturn("Digraph must be a poytree\n");
  fi;

  # check the attributes of every CPT matrix
  for n in [1..Length(CPT)] do

    for r in [1..Length(CPT[n])] do
      if not (IsFloat(CPT[n][r][1]) and IsFloat(CPT[n][r][2])) then
        ErrorNoReturn("CPT for vertex ", n, ", row ", r, " has non float value\n");
      elif (Sum(CPT[n][r]) <> 1.) then
        ErrorNoReturn("CPT for vertex ", n, ", row ", r," does not sum to 1\n");
      fi;
    od;
    
    if not IsMatrix(CPT[n]) then
      ErrorNoReturn("CPT for vertex ", n, "must be a matrix\n");
    elif not IsRectangularTable(CPT[n]) then
      ErrorNoReturn("CPT for vertex ", n, "is not rectagular\n");
    elif DimensionsMat(CPT[n])[2] <> 2 then
      ErrorNoReturn("CPT for vertex ", n, "does not have 2 columns\n");
    elif DimensionsMat(CPT[n])[1] <> 2 ^ Length(InNeighbours(D)[n]) then
      ErrorNoReturn("CPT for vertex ", n, "does not have (2 ^ number of parents of ", n,") rows\n");
    fi;
    
  od;

  # Set the label of every node as the CPT matrix
  SetDigraphVertexLabels(D, CPT);
  SetFilterObj(D, IsBayesianNetwork);
  return D;
end);

InstallMethod(BeliefPropagation, "for a BN, target vertexInt and list of evidence",[IsBayesianNetwork, IsInt, IsList],
function(BN, X, e)
  local priors, likelihoods,
  initialise_likelihood_and_prior, 
  get_belief, get_likelihood, get_prior,
  message_to_parent, message_to_child;

  initialise_likelihood_and_prior := function(e)
    local i, n, pair, evidence_lookup;

    n := DigraphNrVertices(BN);

    # instatiate empty lists of priors and likelihoods with length equal to number of vertexes
    priors := List([1..n], i -> fail);
    likelihoods := List([1..n], i -> fail);

	# For every node; if it is a root or leaf node, it gets an inital value of prior or likelihood
    for i in [1..n] do
      # check if root node (no parents) or leaf node (no children)
      if Length(InNeighbours(BN)[i]) = 0 then
        priors[i] := DigraphVertexLabel(BN,i)[1];
	  fi;
	
      if Length(OutNeighbours(BN)[i]) = 0 then
        likelihoods[i] := [1, 1];
      fi;
    od;

	if Length(e) = 0 then
		return;
	fi;

	# for every node, determine if it is observed, and if it is store it's value
    evidence_lookup := List([1..n], i -> fail);
    for pair in e do
      evidence_lookup[pair[1]] := pair[2];
    od;

    # For every node; if it is an evidence, root or leaf node, it gets an inital value of priors and likelihoods
    for i in [1..n] do
      if evidence_lookup[i] <> fail then
        if evidence_lookup[i] = true then
          priors[i] := [1,0];
          likelihoods[i] := [1,0];
        else
          priors[i] := [0,1];
          likelihoods[i] := [0,1];
        fi;
      fi;
    od;
  end;

  get_belief := function(X, e)
    local prior, likelihood, unnormalized, sum;
    initialise_likelihood_and_prior(e);

    likelihood := get_likelihood(X);
    prior := get_prior(X);

    # vector multiplication π * λ
    unnormalized := List([1..2], i -> prior[i] * likelihood[i]);  

    sum := Sum(unnormalized);

    # normalize probability to return
    return List(unnormalized, x -> x/sum);
  end;

  get_likelihood := function(X)
    local messages, c;

    # check if likelihood is known
    if likelihoods[X] <> fail then
      return likelihoods[X];
    fi;

    # if not, collect all incoming messages from children
    messages := [];
    for c in OutNeighbours(BN)[X] do
      Add(messages, message_to_parent(c, X));
    od;

    # take the product of all incoming messages element-wise
    likelihoods[X] := [Product(TransposedMat(messages)[1]), Product(TransposedMat(messages)[2])];
    return likelihoods[X];
  end;

  get_prior := function(X)
    local messages, p, CPT, k, combination_index, product_messages, value;

    # check if prior is known
    if priors[X] <> fail then
      return priors[X];
    fi;

    # if it's not, collect all incoming messages from parents
    messages := [];
    for p in InNeighbours(BN)[X] do
      Add(messages, message_to_child(p, X));
    od;

    CPT := DigraphVertexLabel(BN,X);
    # k is number of parents
    k := Length(InNeighbours(BN)[X]);
    priors[X] := [0,0];

    for combination_index in [0..2^k-1] do
      product_messages := 1;
      for p in [1..k] do
        # gets 1 for true parent values and 2 for false parent values
        value := ((QuoInt(combination_index, 2^(k-p))) mod 2) + 1;
        product_messages := product_messages * messages[p][value];
      od;
      priors[X] := [priors[X][1] + (CPT[combination_index + 1][1] * product_messages),  priors[X][2] + (CPT[combination_index + 1][2] * product_messages)];
    od;
    return priors[X];
  end;

  message_to_parent := function(child, parent)
    local likelihood, CPT, messages, parent_list, k, p, out_message, parent_val, combination_index, product_messages, skip, msg_index, value, total, x;

    likelihood := get_likelihood(child);
    CPT := DigraphVertexLabel(BN, child);

    parent_list := InNeighbours(BN)[child];
    k := Length(parent_list);

    # get messages from all other parents of the child
    messages := [];
    for p in parent_list do
      if p <> parent then
        Add(messages, message_to_child(p, child));
      fi;
    od;

    out_message := [0,0];

    # compute the cases for parent = true and parent = false separately
    for parent_val in [1,2] do
      total := 0;
      # iterate over combinations of all parent values
      for combination_index in [0..(2^k)-1] do
        product_messages := 1;
        skip := false;
        msg_index := 1;

        # iterate over all parents of child
        for p in [1..k] do 
          value := ((QuoInt(combination_index, 2^(k-p))) mod 2) + 1;
          if parent_list[p] = parent then
            if value <> parent_val then
              skip := true;
              break;
            fi;
          else 
            product_messages := product_messages * messages[msg_index][value];
            msg_index := msg_index + 1;
          fi;
        od;

        if skip = false then
          # iterate over values of the child
          for x in [1,2] do
            total := total + (likelihood[x] * CPT[combination_index+1][x] * product_messages);
          od;
        fi;
      od;
      out_message[parent_val] := total;
    od;

    return out_message;
  end;

  message_to_child := function(parent, child)
    local prior, messages, c, msg;
    prior := get_prior(parent);

    messages := [];
    for c in OutNeighbours(BN)[parent] do
      if c <> child then
        Add(messages, message_to_parent(c, parent));
      fi;
    od;

    for msg in messages do
      prior := [prior[1] * msg[1], prior[2] * msg[2]];
    od;
    return prior;
  end;

  return get_belief(X, e);
end);

InstallMethod(GetCPT, "for a BN and vertexInt", [IsBayesianNetwork, IsInt],
function(BN, n)
  return DigraphVertexLabel(BN,n);
end);