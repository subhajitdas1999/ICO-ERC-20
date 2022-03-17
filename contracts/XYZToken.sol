//SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

contract XYZToken{
    string private name;
    string private symbol;

    uint public totalSupply;
    
    mapping (address => uint) public balanceOf;
    mapping (address => mapping(address => uint)) public allowance;

    event Transfer(address indexed from,address indexed to,uint amount);
    event Approval(address indexed from, address indexed to,uint value);


    constructor(string memory _name,string memory _symbol,uint _initialSupply){
        name=_name;
        symbol=_symbol;
        _mint(msg.sender,_initialSupply);
        
    }
    

    function _mint(address _sender,uint _initialSupply) internal {
        uint _initialSupplyWithDecimal = (_initialSupply * (10**(decimals())));
        totalSupply += _initialSupplyWithDecimal;
        balanceOf[_sender] += _initialSupplyWithDecimal;
        emit Transfer(address(0),_sender,_initialSupplyWithDecimal);
    }

    function decimals() public pure returns(uint8){
        return 9;
    }

    function _transfer(address _from,address _to,uint _value) internal {
        require( _from != address(0) || _to != address(0), "Send to 0 address");
        require(balanceOf[_from] >= _value , "Account does not have enough Token");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from,_to,_value);
    }

    function approve(address _to,uint _value) public{
        require(msg.sender != _to,"Owner and benificiary should be different");        
        allowance[msg.sender][_to] += _value;
        emit Approval(msg.sender,_to,allowance[msg.sender][_to]);
    }

    function transfer(address _to, uint256 _value) public returns (bool success){
        _transfer(msg.sender,_to,_value);       
        return true;
    }

    function transferFrom(address _from, address _to,uint _value) public returns(bool success){
        require(allowance[_from][msg.sender] >= _value ,"You Allowence is less");

        allowance[_from][msg.sender] -= _value ;
        _transfer(msg.sender,_to,_value);   
        emit Approval(_from,msg.sender,allowance[_from][msg.sender]);
        return true;
       
        
    }

    

}