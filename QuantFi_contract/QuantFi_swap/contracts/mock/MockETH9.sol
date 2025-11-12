// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockETH9 is ERC20, Ownable {

    uint8 private immutable deci;

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint8 _decimals
    ) ERC20(name, symbol) Ownable(msg.sender) {
        deci = _decimals;
        _mint(msg.sender, initialSupply);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return deci;
    }

    function deposit() external payable {
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint wad) external {
        require(balanceOf(msg.sender) >= wad, "Insufficient balance");
        _burn(msg.sender, wad);
        payable(msg.sender).transfer(wad);
    }
}