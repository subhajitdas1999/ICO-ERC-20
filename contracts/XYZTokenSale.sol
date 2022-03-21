//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";

contract Owner{
    address payable internal _owner;
    
    constructor(){
        _owner = payable(msg.sender);
    }

    modifier onlyOwner(){
        require(msg.sender == _owner,"Owner required");
        _;
    }
}

contract XYZTokenSale is Owner{
    enum ICOState {started,preSale,seedSale,finalSale}

    ICOState public state = ICOState.started;
    uint private rate; //TKN bits per wei. representing with the help of rateDenominator
    uint private rateDenominator;
    IERC20 token;
    uint priceOfOneTKNBits;
    uint tokenAvailableForSale;
    // uint tokenLeftFromPreAndSeedSale; 

    //30 million for pre sale
    // 50 million for seed sale
    // 20 million for final sale 

    constructor(IERC20 _token){
        token = _token;
    }

    function startSale() public onlyOwner{
        changeICOState(uint(ICOState.preSale));
    }

    receive() payable external{
        buyTokens(msg.sender);
    }

    function buyTokens (address _buyer) payable public{
        require(state != ICOState.started,"ICO sale is not started yet");
        //For e.g :-rateForPreSale = 25 x 10^(14) TKN bits per ether
        // 400 wei = 1 TKN bits = 0.000000001 TKN , 400 wei is the minimum user should send        
        uint _tokenBitsAmount= _validatePurchase(msg.value,tokenAvailableForSale);
        tokenAvailableForSale -= _tokenBitsAmount;
        token.transfer(_buyer,_tokenBitsAmount);
        _forwardFundsToOwner();    
    }

    function changeICOState(uint _state) public onlyOwner{
        
        if(_state == uint(ICOState.preSale)){
            require(state == ICOState.started,"The ICO is in wrong state .Cannot proceed to pre sale state");
            // PRICE = 0.001 USD 
            // 1Ether = 3000 USD
            //rate is 25 x 10^(-4) TKN bits per wei
            state = ICOState.preSale;
            rate = 25;
            rateDenominator = 10**4;
            priceOfOneTKNBits = 400; //minimum user have to pay 400 wei
            tokenAvailableForSale = 30000000 * (10**(token.decimals()));
            
        }
        else if(_state == uint(ICOState.seedSale)){
            require( state == ICOState.preSale,"The ICO is in wrong state .Cannot proceed to seed sale state");
            // PRICE = 0.2 USD
            //rate is 15 X 10^(-6) TKN bits per wei
            state = ICOState.seedSale;           
            rate = 15;
            rateDenominator = 10**6;
            priceOfOneTKNBits = 67000; //minimum user have to pay 67000 wei
            tokenAvailableForSale = 50000000 * (10**(token.decimals()));

        }
        
    }

    function setFinalState(uint _rate ,uint _rateDenominator, uint _priceOfOneTKNBits) public onlyOwner{
        require( state == ICOState.seedSale,"complete the seed sale stage first");
    
        // changeICOState(uint(ICOState.finalSale)); //call to change to final state
        state = ICOState.finalSale;
        rate = _rate;
        rateDenominator = _rateDenominator;
        priceOfOneTKNBits = _priceOfOneTKNBits; //minimum user have to pay in wei
        tokenAvailableForSale = 20000000 * (10**(token.decimals()));
            
        
    }

    function _validatePurchase (uint _weiAmount, uint _tokenAvailableForSale) internal view returns(uint){
        require(_tokenAvailableForSale!=0,"No tokens left for this round. Wait for next round");
        require(_weiAmount >= priceOfOneTKNBits,"Please provide more ether.");
        uint _tokenBitsAmount = _getTokenAmount(_weiAmount);
        require(_tokenAvailableForSale>= _tokenBitsAmount,"Sorry Token is not available.Reduce token amount");
        return _tokenBitsAmount;
    }

    function _getTokenAmount(uint _weiAmount) internal view returns(uint){
        // rate is in TKN bits per wei .
        return (_weiAmount * rate) / rateDenominator ;
    }




    function _forwardFundsToOwner() internal {
        require(_owner != address(0),"Owner is not valid");
        _owner.transfer(msg.value);
    }

    function endCrowdSale() public onlyOwner{
        require(state == ICOState.finalSale,"Crowd sale is not in final stage");
        token.transfer(_owner,tokenAvailableForSale);
        tokenAvailableForSale = 0;

    }

   
    
}