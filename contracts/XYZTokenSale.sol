//SPDX-License-Identifier: MIT

pragma solidity >=0.7.1 <0.9.0;

import "./XYZToken.sol";

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
    uint public rate; //TKN bits per Ether (considering per ether for simple calculation)
    XYZToken token;
    uint priceOfOneTKNBits;
    uint tokenAvailableForSale;
    uint tokenLeftFromPreAndSeedSale; 

    //30 million for pre sale
    // 50 million for seed sale
    // 20 million for final sale + token left for pre sale and seed sale 

    constructor(XYZToken _token){
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
            // which is = 25 x 10^(14) TKN bits per ether
            state = ICOState.preSale;
            uint _rateForPreSale = 25 * (10**14) ; 
            _setRate(_rateForPreSale);
            tokenAvailableForSale = 30000000 * (10**(token.decimals()));
            
        }
        else if(_state == uint(ICOState.seedSale)){
            require( state == ICOState.preSale,"The ICO is in wrong state .Cannot proceed to seed sale state");
            // PRICE = 0.2 USD
            //rate is 15 X 10^12 TKN bits per Ether
            state = ICOState.seedSale;           
            uint _rateForSeedSale = 15 * (10**12);
            _setRate(_rateForSeedSale);
            tokenLeftFromPreAndSeedSale += tokenAvailableForSale;
            tokenAvailableForSale = 50000000 * (10**(token.decimals()));

        }
        
    }

    function setFinalState(uint _rateForFinalSale) public onlyOwner{
        require( state == ICOState.seedSale,"complete the seed sale stage first");
        _setRate(_rateForFinalSale);
        // changeICOState(uint(ICOState.finalSale)); //call to change to final state
        state = ICOState.finalSale;
        tokenLeftFromPreAndSeedSale += tokenAvailableForSale;
        tokenAvailableForSale = (20000000 * (10**(token.decimals())) + tokenLeftFromPreAndSeedSale);
        tokenLeftFromPreAndSeedSale = 0;
            
        
    }

    function _validatePurchase (uint _weiAmount, uint _tokenAvailableForSale) internal view returns(uint){
        require(_weiAmount >= priceOfOneTKNBits,"Please provide more ether.");
        uint _tokenBitsAmount = _getTokenAmount(_weiAmount);
        require(_tokenAvailableForSale>= _tokenBitsAmount,"Sorry Token is not available");
        return _tokenBitsAmount;
    }

    function _getTokenAmount(uint _weiAmount) internal view returns(uint){
        // rate is in TKN bits per ether to convert it in per wei , we dividing it by 1 ether = 10^18 wei
        return (_weiAmount * rate) / 1 ether ;
    }


    function _setRate(uint _rate) internal{
        rate = _rate ;
        priceOfOneTKNBits = 1 ether / rate; 
    }


    function _forwardFundsToOwner() internal {
        require(_owner != address(0),"Owner is not valid");
        _owner.transfer(msg.value);
    }

    function endCrowdSale() public onlyOwner{
        require(state == ICOState.finalSale,"Crowd sale is not in final stage");
        token.transfer(_owner,tokenAvailableForSale);
        // tokenAvailableForSale=0;
        selfdestruct(_owner);
    }

   
    
}