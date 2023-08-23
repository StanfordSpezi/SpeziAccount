# Handling Account Value Storage

How to build and modify account value storage containers.

## Overview

``AccountValues`` implementations are used to store values for a given ``AccountKey`` definition.
There exist several different containers types. While they are identical in the underlying storage mechanism with only very
few differences in construction operations, they convey entierly different semantics and are used in their respective context only.

### Accessing Account Information 


### Creating a User Account

### Modifying User Information

### Custom Storage Provider

### The Builder interface.

### Visitors

## Topics

### Generalized Containers

- ``AccountValuesCollection``
- ``AccountValues``

### Account Values

- ``AccountDetails``
- ``SignupDetails``
- ``AccountModifications``
- ``ModifiedAccountDetails``
- ``RemovedAccountDetails``
- ``PartialAccountDetails``

### Account Keys

- ``AccountKeyCollection``
TODO array extension?

### Building

- ``AccountValuesBuilder``

### Visitors

- ``AccountKeyVisitor``
- ``AccountValueVisitor``
- ``AcceptingAccountKeyVisitor``
- ``AcceptingAccountValueVisitor``
