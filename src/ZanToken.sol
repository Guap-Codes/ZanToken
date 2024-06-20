// contracts/OurToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ZanToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("ZanToken", "ZT") {
        _mint(msg.sender, initialSupply);
    }
}
