// SPDX-License-Identifier: GPL-3.0
pragma abicoder v2;
pragma solidity >=0.7.0 <0.9.0;
contract OptionsFactory{

    uint payOff;
    struct Position{
        bool postionFlag;
        uint strikePrice;
        uint premium;
    }
    struct Strategy{
        Position longCall;
        Position shortCall;
        Position longPut;
        Position shortPut;
        uint256 marketId;   
    }
    struct StrategyMarket{
        address token;
        bool created;
        uint256 startAt;
        uint256 endAt;
    }

    // modifier onlyCreator{
    //     require(msg.sender == )
    // }
    mapping(address => Strategy) public strategies;
    mapping(uint256 => StrategyMarket) public StrategyMarkets;

    function getCurrentPrice() public pure returns(uint){
        // call API3 here
        uint x;
        return x;
    }
    
    function longCall(uint strikePrice,uint premium) internal returns(uint) {    
        uint currentPrice = getCurrentPrice();
        if(currentPrice - strikePrice > 0){
            payOff= (currentPrice - strikePrice) - premium;
        }
        else{
            payOff =  0 - premium;
        }
        return payOff;
    }
    function shortCall(uint strikePrice,uint premium) internal returns(uint) {    
        uint currentPrice = getCurrentPrice();
        if(currentPrice - strikePrice > 0){
            payOff= premium - (currentPrice - strikePrice);
        }
        else{
            payOff =  premium - 0 ;
        }
        return payOff;
    }
    function longPut(uint strikePrice,uint premium) external returns(uint) {    
        uint currentPrice = getCurrentPrice();
        if( strikePrice - currentPrice > 0){
            payOff = strikePrice - currentPrice - premium;
        }
        else{
            payOff =  0 - premium ;
        }
        return payOff;
    }
    function shortPut(uint strikePrice,uint premium) external returns(uint) {    
        uint currentPrice = getCurrentPrice();
        if( strikePrice - currentPrice > 0){
            payOff = premium + strikePrice - currentPrice;
        }
        else{
            payOff = premium ;
        }
        return payOff;
    }
    
    function openPostion(Strategy memory _strategy)external{
        uint finalPayoff;
        strategies[msg.sender] = _strategy;

        if(_strategy.longCall.postionFlag == true){
            finalPayoff += longCall(_strategy.longCall.strikePrice, _strategy.longCall.premium);
        }
        if(_strategy.shortCall.postionFlag == true){
            finalPayoff += shortCall(_strategy.shortCall.strikePrice, _strategy.shortCall.premium);
        }

    }
    function createStrategyMarket(StrategyMarket memory _strategyMarket, uint256 _id)external  {
        require(!StrategyMarkets[_id].created);
        StrategyMarkets[_id] = _strategyMarket;
    }
}