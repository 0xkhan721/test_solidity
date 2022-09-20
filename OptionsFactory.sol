// SPDX-License-Identifier: GPL-3.0
pragma abicoder v2;
pragma solidity >=0.7.0 <0.9.0;
contract OptionFactory{

    uint payOff;
    address public owner;
    struct Position{
        bool postionFlag;
        uint strikePrice;
        uint premium;
    }
    struct Strategy{
        uint256 strategyId;
        StrategyDesc strategyDesc;
        address creator;
        bool started;
        bool ended;
        address[] buyers;
        uint premium;
        uint finalPayoff;
        uint maxPayoff;
        uint minPayoff;   
    }
    struct StrategyDesc{
        Position longCall;
        Position shortCall;
        Position longPut;
        Position shortPut;
        address creator;
        address token;
        uint256 startAt;
        uint256 endAt;
    }
    struct BuyerPosition{
        uint strategyId;
        uint numOfStrat;
        uint collLocked;
    }
    struct SellerPosition{
        uint strategyId;
        uint numOfStrat;
        uint collLocked;
    }
    mapping(uint256 => Strategy) public strategy;
    mapping(address => uint256) public creatorMapping;
    mapping(address => uint256) public strategyCreator2;
    mapping(address => SellerPosition) public SellerToStrategy;
    mapping(address => BuyerPosition) public BuyerToStrategy;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

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
    function longPut(uint strikePrice,uint premium) internal returns(uint) {    
        uint currentPrice = getCurrentPrice();
        if( strikePrice - currentPrice > 0){
            payOff = strikePrice - currentPrice - premium;
        }
        else{
            payOff =  0 - premium ;
        }
        return payOff;
    }
    function shortPut(uint strikePrice,uint premium) internal returns(uint) {    
        uint currentPrice = getCurrentPrice();
        if( strikePrice - currentPrice > 0){
            payOff = premium + strikePrice - currentPrice;
        }
        else{
            payOff = premium ;
        }
        return payOff;
    }
    
    function openStrategy(StrategyDesc memory _strategyDesc) internal returns (uint,uint,uint){
        uint finalPayoff;
        uint maxPayoff;
        uint minPayoff;
        if(_strategyDesc.longCall.postionFlag == true){
            finalPayoff += longCall(_strategyDesc.longCall.strikePrice, _strategyDesc.longCall.premium);
        }
        if(_strategyDesc.shortCall.postionFlag == true){
            finalPayoff += shortCall(_strategyDesc.shortCall.strikePrice, _strategyDesc.shortCall.premium);
        }
        if(_strategyDesc.longPut.postionFlag == true){
            finalPayoff += longPut(_strategyDesc.longPut.strikePrice, _strategyDesc.longPut.premium);
        }
        if(_strategyDesc.shortPut.postionFlag == true){
            finalPayoff += shortPut(_strategyDesc.shortPut.strikePrice, _strategyDesc.shortPut.premium);
        }
        return (finalPayoff,maxPayoff,minPayoff);
    }
    function createStrategyMarket(StrategyDesc memory _strategyDesc)external  {
        strategy[block.timestamp];
        strategy[block.timestamp].strategyId = block.timestamp;
        strategy[block.timestamp].strategyDesc = _strategyDesc;
        strategy[block.timestamp].creator = msg.sender;
        strategy[block.timestamp].started = true;
        strategy[block.timestamp].ended = false;
        (strategy[block.timestamp].finalPayoff,strategy[block.timestamp].maxPayoff,strategy[block.timestamp].minPayoff) = openStrategy(strategy[block.timestamp].strategyDesc);
        creatorMapping[msg.sender] = strategy[block.timestamp].strategyId;
    }
    function  buyStrategy(uint256 _strategyId,uint buyNumberofStrat) payable public {
        require(msg.value > strategy[_strategyId].premium * buyNumberofStrat);
        payable(address(this)).transfer(strategy[_strategyId].maxPayoff * buyNumberofStrat);

        BuyerToStrategy[msg.sender];
        BuyerToStrategy[msg.sender].strategyId = _strategyId;
        BuyerToStrategy[msg.sender].numOfStrat = buyNumberofStrat;
        BuyerToStrategy[msg.sender].collLocked = strategy[_strategyId].maxPayoff * buyNumberofStrat;

        // to implement


    }
    function  provideLPStrategy(uint256 _strategyId,uint sellerNumberofStrat) payable public {
        require(msg.value > strategy[_strategyId].maxPayoff * sellerNumberofStrat);
        payable(address(this)).transfer(strategy[_strategyId].maxPayoff * sellerNumberofStrat);

        SellerToStrategy[msg.sender];
        SellerToStrategy[msg.sender].strategyId = _strategyId;
        SellerToStrategy[msg.sender].numOfStrat = sellerNumberofStrat;
        SellerToStrategy[msg.sender].collLocked = strategy[_strategyId].maxPayoff * sellerNumberofStrat;

        // to implement

    }
    function settle(uint256 _strategyId) public onlyOwner{
        // to implement
        require( strategy[_strategyId].started == false);
        require( strategy[_strategyId].ended == true);
        (strategy[_strategyId].finalPayoff,strategy[_strategyId].maxPayoff,strategy[_strategyId].minPayoff) = openStrategy(strategy[_strategyId].strategyDesc);

        if(strategy[_strategyId].finalPayoff > 0){
            // payable(address(this)).transfer(strategy[_strategyId].finalPayoff * buyNumberofStrat);
        } else{
            // payable(address(this)).transfer(strategy[_strategyId].maxPayoff * buyNumberofStrat);
        }
        
    }

}