//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";


/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate
 * behavior.
 */
contract CrowdSale {
    enum ICOState {started,preSale,seedSale,finalSale}

    ICOState public state = ICOState.started;
    uint internal rate; //TKN bits per wei. representing with the help of rateDenominator
    uint internal rateDenominator;
    
    uint priceOfOneTKNBits;
    uint tokenAvailableForSale;
    // The token being sold
    IERC20 public token;

    // Address where funds are collected
    address payable public wallet;

  

  // Amount of wei raised
  uint256 public weiRaised;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   *  Number of token units a buyer gets per wei
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of the token being sold
   */
  constructor( address _wallet, IERC20 _token)  {    
    require(_wallet != address(0));
    require(address(_token) != address(0));

    wallet = payable(_wallet);
    token = _token;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  receive () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  
  function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;
    // _preValidatePurchase(_beneficiary, weiAmount);
    // calculate token amount and validate
    uint _tokenBitsAmount= _validatePurchase(weiAmount,tokenAvailableForSale);



    // update state
    weiRaised += weiAmount;

    _processPurchase(_beneficiary, _tokenBitsAmount);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      _tokenBitsAmount
    );

    _updatePurchasingState(_beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }

  function _validatePurchase (uint _weiAmount, uint _tokenAvailableForSale) internal view returns(uint){
        require(_tokenAvailableForSale!=0,"No tokens left for this round. Wait for next round");
        require(_weiAmount >= priceOfOneTKNBits,"Please provide more ether.");
        uint _tokenBitsAmount = _getTokenAmount(_weiAmount);
        require(_tokenAvailableForSale>= _tokenBitsAmount,"Sorry Token is not available.Reduce token amount");
        return _tokenBitsAmount;
    }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  // function _preValidatePurchase(
  //   address _beneficiary,
  //   uint256 _weiAmount
  // )
  //   internal pure
  // {
  //   require(_beneficiary != address(0));
  //   require(_weiAmount != 0);
  // }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenBitsAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenBitsAmount
  )
    internal
  {
    token.transfer(_beneficiary, _tokenBitsAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenBitsAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenBitsAmount
  )
    internal
  {
    tokenAvailableForSale -= _tokenBitsAmount;
    _deliverTokens(_beneficiary, _tokenBitsAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint _weiAmount) internal view returns(uint){
        // rate is in TKN bits per wei .
        return (_weiAmount * rate) / rateDenominator ;
    }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  
}