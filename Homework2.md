# Homework 2
- Deadline for submission: 15 March 2026, 23:59.
- Submission type: Group
- Description: Advanced applications for smart contracts simulating a blockchain network.
- Remarks: 

The deadline of this homework project is set quite far into the future. This is due to the requirements of this homework being covered in multiple lectures throughout the course. It is recommended not to leave the full project until the end and progressively complete sections according to the lecture progression. Always test each section in Remix before moving onto the next section. By the time you start writing tests in Solidity, the whole system should have passed the manual IDE testing.

Create a private repository and add the professor as a collaborator so the code can be easily accessed when help is requested. Each group should submit only one repository. Submission of multiple repositories or work scattered across multiple branches will be penalized.

The grade will be assigned as a group. In addition to fulfilling the technical criteria listed, Github activity will be checked to evaluate collaboration. Unbalanced participation within the group will be penalized. Therefore, make sure to use PRs and issue tracking to demonstrate what work each of the group members did. Teams may optionally include a short written description of how the work was divided.   


### Exercise 1 - Function scoping (3 points)
From the code provided in lecture 4, you will notice that all functions and global variables are declared as public. Update the code to the appropriate scoping (ie. private, external, internal). For each update you make, please justify why your choice is appropriate/efficient. Each correct adjustment will earn you 0,5 points. Please ensure that the final code still works as presented in class.

### Exercise 2 - Pseudo-DHT networking and smart consensus (3 + 7 points)
This part of the homework project will focus on upgrading the network topology and consensus mechanisms to something more complex. Additionally, we will choose the proposer node randomly by requesting truly random numbers from the Chainlink VRF service.

##### Part A - Network Topology (3 points)
The provided code implements a mesh topology where every node knows about the existence of all others in the network. The goal of this part of the project is to change it to a ring topology. From Lecture 3, this change is essentially:

[img]

The following steps may help you to think through the implementation:
1. Create a separate ``assigner.sol``. Since this contract represents a separate node from the network of validator nodes, it is not inherited.
2. Since we are implementing a ring network, the easiest would be a unidirectional ring network, like the first round of the game in Lecture 3 and therefore, individual nodes hold only one peer, while the assigner contracts holds a the full list.
3. When a node is added to the network (ie. new node contract deployed) it should register itself with the assigner.
4. After registration and coming online, the node should request the assigner to assign it a peer. Since it is a ring network, make sure the previous node knows about the new node and the new node closes the circle so it does not form a line topology.

You may find it helpful to comment out the block building and transmission logic at the point of testing this. Simply ensure that each node is pointing to the correct next peer. 


##### Part B - Proof-of-Stake Consensus (7 points)
The current code has an extremely simple consensus mechanism where any node can propose to build a block and other nodes simply validate the structure of the block. We will now update the consensus mechanism to incorporate randomness in the proposer selection. Please enact the following functionality:

##### Random proposer selection through Chainlink VRF
1. Follow the [tutorial](https://docs.chain.link/vrf/v2-5/subscription/test-locally) to set up a VRF infrastructure. As mentioned in Lecture 5, Oracles consists of a client smart contract which creates and manages requests while the oracle smart contract acts as the interface to the outside world. Between these two contracts exists different payment models. You may adjust the number of random words you get back per request to suit your needs.
  **Note:** You can use 1000000000000000000 for the WEIPERUNITLINK parameter (1 LINK = 1 ETH).
2. After successfully getting some random numbers from the tutorial, add some logic to your ``assigner.sol`` file which:
  a. Gets a random number from the VRF client contract.
  b. Uses this random number to randomly select a proposer.
  c. Save this selected proposer as a variable in a contract.
  **Note on modifiers:** The ``requestRandomWords`` has an onlyOwner modifier! What changes need to be made to accommodate this?
  **Note on testing:** Due to the fact that this is still local, the fulfillment has to be called manually. Therefore, your test flow looks something like: assigner calls client to create a request -> check if s_requestId incremented -> Manually press the ``fulfillRandomWords`` in the coordinator contract with correct parameters -> check if the client's s_randomWords array gets filled out correctly -> call the assigner to fetch the random number.

##### Recursive propagation
We will now write an overloaded ``propagate`` function to distribute the message, get attestations from other nodes and update the blockchains of each node in the ring.
1. Amend the ``user_input`` function to save the user input in the ``current_message`` global variable and then propagate it to the rest of the ring.
2. Write a propagate function that takes in an address originator and string message which:
  a. Saves the message in the ``current_message`` variable of each respective node.
  b. Check if the next peer is the originator, this would mean the message has traveled a full circle and it should terminate.
  c. If the next peer is not the endpoint, then call the propagate function again to pass it onto the next node. This is a recursive function.
  d. Check that this is working correctly, because the block propagation works very similarly.
3. Now modify the ``propose_block`` function to check if it is the proposer selected by the assigner. Then build the block and finally propagate the block.
3. To propagate the block, write an overload ``propagate`` function which takes in the address of the proposer and a ``Block`` struct. The logic there is quite similar, check if the next peer is the proposer, send an attestation by calling ``check_block`` back to the proposer, save the transmitted block as ``current_block`` and call the propagate function again to pass along the block if it is not the end of the ring network.
4. Now we will update the quorum logic. The current logic requires all participating nodes to give approval. This is rarely the case in production environments. Instead, add logic to your ``check_block_finality_and_build``function so that the proposed block passes if it receives 2/3 approvals from all nodes in the network.
5. If the proposer did receive more than 2/3 of the attestations, modify the ``finalize_block`` function to push the ``current_block`` to the blockchain, increment the ``next_block_num`` counter and then clear all global variables for the next round.
6. The ``finalize_block`` function would then need to be in yet another overloaded ``propagate`` function so each node can update their blockchains accordingly.
5. Finally, don't forget to let the assigner know that it should select a new random proposer by creating a new request.

##### Add the Stake
The consensus mechanism currently checks only for hash and blocknumber continuity. Now we will add a stake to this mechanism.

  a. Create a new contract file called ``Staking.sol``. The owner of this contract is the deployer. Require a minimum funding amount upon the deployment of the contract.
  b. Modify the ``propose_block`` function to require the payment of a stake before the proposer is allowed to broadcast the block for checking. You may decide on an arbitrary amount.
  c. If the proposer received the required number of approvals from other nodes, the staking contract should release the locked amount back to the proposer, along with a small reward for building the block.
  d. If the proposer did not receive the required number of approvals, the paid stake is forfeit to the staking contract.


### Exercise 3 - Solidity Testing (5 + 2 points)
##### Part A - Solidity Testing (5 points)
Produce a ``test.sol`` file which contains:
 - Unit tests for at least 1 function in EACH contract (excluding VRF contracts).
 - An end to end integration test which setups a simple network, goes through consensus and builds a block successfully.

 Next, use any static analysis tool (ex. Slither or SolidityScan) and present the results in a ``vulnerability`` file in your project.

 ##### Part B - Business analytics of vulnerabilities (2 points)
 Produce a report, no word count requirements, which describes the following points:
 1. Overview of the results of the vulnerability testing tools.
 2. A recommendation of which issues developers should address first. Your recommendations should be based on budget, developer hours required, user impact, and your own assessment of if the issue is really as critical as the tool present it to be. A good number of fixes to recommend is three, but more is welcome as well.

 ### Bonus Exercise - (5 additional points)
 Deploy the whole system on the sepolia testnet and produce a transaction history which demonstrates a proposer selection, a message distribution, a block being proposed by the proposer, voted upon by the network and ultimately incorporated into the network.

 Note: The VRF functions must be changed to the deployed version.