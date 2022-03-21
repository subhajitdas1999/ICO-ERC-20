//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


/**
 ERC20 INTERFACE
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);

  function transferFrom(address from, address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value) external ;

  function decimals() external returns(uint);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
  event Transfer(address indexed from, address indexed to, uint256 value);
}