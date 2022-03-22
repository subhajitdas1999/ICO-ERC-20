//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./CrowdSale.sol";

contract Owner{
    address  internal _owner;
    
    constructor(){
        _owner = payable(msg.sender);
    }

    modifier onlyOwner(){
        require(msg.sender == _owner,"Owner required");
        _;
    }
}

contract XYZTokenSale is Owner,CrowdSale{
    

    //30 million for pre sale
    // 50 million for seed sale
    // 20 million for final sale 

    constructor(IERC20 _token) CrowdSale(msg.sender,_token){
        
    }

    function startSale() public onlyOwner{
        changeICOState(uint(ICOState.preSale));
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

    function endCrowdSale() public onlyOwner{
        require(state == ICOState.finalSale,"Crowd sale is not in final stage");
        _deliverTokens(wallet,tokenAvailableForSale);
        tokenAvailableForSale = 0;

    }

   
    
}