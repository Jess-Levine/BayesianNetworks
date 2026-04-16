# BayesianNetworks (GAP Package)

BayesianNetworks is a GAP package for constructing and performing inference on Bayesian networks. It provides functionality to represent probabilistic graphical models as directed graphs and to compute posterior probabilities using belief propagation.

---

## Features

- Construction of Bayesian network objects from directed graphs
- Validation of network structure (restricted to polytrees)
- Support for binary-valued random variables
- Representation of conditional probability tables (CPTs)
- Exact inference using Pearl’s belief propagation algorithm
- Access to CPTs for inspection and analysis

---

## Requirements

- GAP (version 4.x)
- The `Digraphs` package

---

## Installation

1. Download or clone this repository.
2. Place the `BayesianNetworks` directory into the `pkg/` directory of your GAP installation.
3. Start GAP and load the package:

```gap
LoadPackage("BayesianNetworks");