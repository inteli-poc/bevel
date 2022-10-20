
# DSCP - Digital Supply Chain Platform

### A sample supply chain application deployed on Substrate based DLT network using Hyperledger Bevel <br>
<br>
This demo application has been developed to demonstrate the benefits of distributed systems to the additive-manufacturing industry within aerospace. The application defines a consortium of multiple organizations. It allows nodes to track products or goods along with their chain of custody. It provides the members of the consortium all the relevant data about their product throughout it's journey, from raw material to the finished product. It provides simple web clients that let you perform the actions of different personas in a supplychain industry.<br>
<br>

### Pre-requisites

***

- Substrate network of one or more organizations. A complete supplychain network will have the following organizations:
  - OEM - Original Equipment Manufacturer (admin organization)
  - Tier 1 and/or Tier 2 Suppliers
  - Carrier
  - Store
  - Warehouse
  - Manufacturer
- IPFS node

### Setup Guide

***

DSCP-API

This application uses a node.js API to support communication to the Substrate based dscp-node and an IPFS node via polkadot.js API.
Follow the steps in this [guide](https://github.com/inteli-poc/bevel/tree/develop/examples/dscp-app) for dscp-api configuration.

*DSCP-Frontend Configuration Guide WIP*

The deployment setup has been automated using Ansible scripts, GitOps, and Helm charts.

The files have all been provided to use and require the user to populate the network.yaml file accordingly, following these steps:

1. Create a copy of the `network.yaml` you have used to set up your network.
2. For each organization, navigate to the `gitops` section and change the `chart_source` to `examples/dscp-app/charts`.

### Deploying the DSCP-App

***

After completing all the pre-requisites and setup guide, deploy the dscp-app by executing the following command:

`ansible-playbook examples/dscp-app/configuration/deploy-dscp-app.yaml -e "@/path/to/application/network.yaml"`
