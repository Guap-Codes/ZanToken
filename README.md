# ZanToken ERC20 Project

## Overview
ZanToken is an ERC20 token implemented in Solidity. This project includes the implementation of the token, deployment scripts, and comprehensive tests to ensure the functionality and security of the token.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [License](#license)

## Installation

### Prerequisites

- Node.js and npm
- [Foundry](https://getfoundry.sh/) (a fast, portable, and modular toolkit for Ethereum application development written in Rust)

### Clone the Repository
```
git clone https://github.com/yourusername/zantoken.git
cd zantoken
```

## Install Dependencies
```forge install```

## Usage
- Compile the contracts
```forge build```

- Deploy the contracts
The deployment script is located in the script directory. You can deploy the contract using Foundry's forge tool:
```forge script script/DeployZanToken.s.sol --broadcast```

- Testing the contracts
The tests are written using Foundry's forge-std library. The tests include various scenarios to ensure the correct functionality of the ZanToken.
Run tests using ```forge test```

- Test Descriptions
* testInitialSupply: Verifies the initial supply of tokens.
* testUsersCantMint: Ensures that only authorized users can mint tokens.
* testAllowances: Tests the allowance mechanism of the ERC20 token.
* testTransfers: Validates the transfer functionality.
* testInsufficientBalanceTransfers: Ensures transfers with insufficient balance are reverted.
* testApproveAndTransferFrom: Tests the approve and transferFrom functionality.
* testApproveZeroAllowance: Checks the behavior when allowance is set to zero.
* testIncreaseAllowance: Tests the increaseAllowance function.
* testDecreaseAllowance: Tests the decreaseAllowance function.
* testTransferToZeroAddress: Ensures transfers to the zero address are reverted.
* testTransferFromToZeroAddress: Ensures transferFrom to the zero address is reverted.

## Project Structure
- src: Contains the main Solidity smart contracts.
     * ZanToken.sol: The main ERC20 token contract.
  
- script: Contains deployment scripts.
     * DeployZanToken.s.sol: Script to deploy the ZanToken contract.

- test: Contains test files.
     * ZanTokenTest2.t.sol: Test cases for the ZanToken contract.

- lib: Contains external libraries (e.g., forge-std).

## License
This project is licensed under the MIT License. 

## Contributing
Contributions are welcome! Please fork the repository and open a pull request with your changes.

## Acknowledgements
OpenZeppelin for their ERC20 standard implementation.
Foundry for the testing and development toolkit.
