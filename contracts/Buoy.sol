pragma solidity 0.6.12;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol";
// SPDX-License-Identifier: GPL-2.0-or-later


/* 
    ____                   
   / __ )__  ______  __  __
  / __  / / / / __ \/ / / /
 / /_/ / /_/ / /_/ / /_/ / 
/_____/\__,_/\____/\__, /  
                  /____/   
                  
Alan Stacks
Thanks to Statera, Stonks, and Unipower for inspiration
*/

contract Buoy is ERC20, ReentrancyGuard {
    using SafeMath for uint256;
    
//================================Mappings and Variables=============================//
    
    //owner
    address payable owner;
    //mappings
    mapping (address => uint) reserves;
    mapping (address => uint) ethPaid;
    //booleans
    bool withdrawable;
    bool withdrawPeriodOver;
    bool addressLocked;
    bool ethInjected;
    bool saleHalted;
    //token info
    string private _name = "Buoy";
    string private _symbol = "BUOY";
    uint _totalSupply;
    uint _totalReserved;
    //public sale dates
    uint startDate;
    uint stage1;
    uint stage2;
    uint endDate;
    uint safetySwitch;
    uint withdrawalLimit;
    //used as a redundancy to keep track of stages of public sale
    uint nonce = 0;
    //address for liquidity injection
    address payable public davysAddress;
    address payable public buoyPresale = 0xD10Fd220efC658E72fcB09a1422394eE48A39d54;
    

//================================Constructor================================//

    constructor() public payable ERC20(_name, _symbol) {
        owner = msg.sender;
        _mintOriginPool();
    }
    
//===========================ownership functionality================================//

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
//=============================Public Sale Functionality==============================//

    /*
    mints the tokens which are used to generate the Origin Pool
    */
    function _mintOriginPool() private {
        require(nonce == 0, 'NONCE_ERROR');
        uint poolTokens = (40 * (10 ** 18));
        _mint(msg.sender, poolTokens);
        emit Transfer(address(0), msg.sender, poolTokens);
        nonce ++;
    }
    
    /*
    sets startDate to now and defines the sale stages off of that. 
    */
    function startSale() onlyOwner public {
        require(addressLocked == true, 'ADDRESS_NOT_APPROVED');
        require(nonce == 1, 'NONCE_ERROR');
        startDate = now;
        saleHalted = false;
        stage1 = startDate + 2 days;
        stage2 = startDate + 6 days;
        endDate = startDate + 14 days;
        safetySwitch = endDate + 2 days;
        nonce ++;
        }

    /*
    the function the user will use to buy tokens. adds tokens to reserves to be withdrawn after 
    the sale ends. contains sale logic and limits tokens sold to 1000000
    */
    function buySale() public payable {
        require(now >= startDate, 'SALE_NOT_STARTED'); 
        require(now < endDate, 'END_DATE_PASSED');
        require(nonce == 2);
        uint tokens;
        if (now <= stage1) {
            tokens = msg.value.mul(225);
        } else if (now <= stage2) {
                tokens = msg.value.mul(200);
        } else if (now <- endDate) {
            tokens = msg.value.mul(175);
        }
        require((_totalReserved + tokens) <= 1000000 * (10 ** 18), 'TOTAL_SUPPLY_OVERFLOW');
        uint currentReserve = reserves[msg.sender];
        uint newReserve = currentReserve.add(tokens);
        reserves[msg.sender] = newReserve;
        ethPaid[msg.sender] = ethPaid[msg.sender].add(msg.value);
        _totalReserved = _totalReserved.add(tokens);
    }
    
    /*
    any ETH sent directly to the contract falls back to the buySale function
    */
    receive() payable external {
        buySale();
    }
    
    /*
    This function requires the user to have funds reserved, as well as requiring the withdrawal
    dates to be active. Because unwithrawn tokens are eventually forfeit, tokens are added to
    the total supply only when withdrawn.
    */
    function withdrawBuoy() public {
        require(reserves[msg.sender] > 0, 'INPUT_TOO_LOW');
        require(withdrawable == true, 'WITHDRAWABLE_FALSE');
        require(now >= endDate, 'END_DATE_NOT_REACHED');
        require(now <= withdrawalLimit, 'WITHDRAW_LIMIT_PASSED');
        uint withdrawal = reserves[msg.sender];
        reserves[msg.sender] = 0;
        _mint(msg.sender, withdrawal);
        emit Transfer(address(0), msg.sender, withdrawal);
        _totalReserved = _totalReserved.sub(withdrawal);
    }
    
    /*
    The withdraw period is actually ended automatically. This function just clears the reserved count
    */
    function endWithdrawPeriod() onlyOwner public {
        require(withdrawPeriodOver == false, 'WITHDRAW_PERIOD_TRUE');
        require(now >= withdrawalLimit, 'WITHDRAWL_LIMIT_NOT_PASSED');
        _totalReserved = 0;
        withdrawPeriodOver = true;
        
    }

    /*
    12,000 Buoy tokens are eligible to be received via presale tokens. Each token redeemed = 400 Buoy.
    avoids supply limitations to guarentee private sales can be redeemed during sale period
    */
    function redeemPresale() nonReentrant public {
        require(now >= startDate, 'SALE_NOT_STARTED');
        require(nonce == 2, 'NONCE_ERROR');
        require(now < endDate, 'END_DATE_PASSED');
        IERC20 transferContract = IERC20(buoyPresale);
        uint presaleTokens = transferContract.balanceOf(msg.sender);
        require(presaleTokens > 0, 'NO_PRESALE_TOKENS');
        transferContract.transferFrom(msg.sender, address(this), presaleTokens);
        uint tokens = 400*(presaleTokens)*(10 ** 18);
        uint currentReserve = reserves[msg.sender];
        uint newReserve = currentReserve.add(tokens);
        reserves[msg.sender] = newReserve;
        _totalReserved = _totalReserved.add(tokens);
    }
    

//===================================view fucntions============================//
    
    /*
    all the see functions return uint values in wei, and so need to be divided by (10 ** 18) to give an accurate decimal count
    */
    
    function viewStage() public view returns(string memory) {
        if(now <= startDate) {
            return("Public sale has not yet started");
        } else if(now <= stage1) {
            return("Stage 1 of the sale, 225 BUOY per ETH");
        } else if(now <= stage2) { 
            return("Stage 2 of the sale, 200 BUOY per ETH");
        } else if(now <= endDate) { 
            return("Stage 3 of the sale, 175 BUOY per ETH");
        } else return("Sale over, please withdraw your Buoy");
    }

    function viewPossibleReserved(uint256 a) public view returns(uint) {
        uint bonus;
        if(now <= stage1) {
            bonus = (a * (10 ** 18)) * 225;
        } else if(now <= stage2) { 
            bonus = (a * (10 ** 18)) * 200;
        } else if(now <= endDate) {
            bonus =  (a * (10 ** 18)) * 175;
        } else bonus = 0;
        return bonus;
    }
    
    function viewReserved() external view returns(uint) {
        return _totalReserved;
    }
    
    function viewMyReserved() external view returns(uint) {
        if (withdrawPeriodOver == false) { 
            return reserves[msg.sender];
        } else return 0;
    }
    
    function viewMyEthPaid() external view returns(uint) {
        return ethPaid[msg.sender];
    }
    
    function viewEthRaised() external view returns(uint) {
        return address(this).balance;
    }
    
    
//==============================Injection Functionality=================================//
    
    /*
    sets the address for the asset locking contract called Davy Jones, should be done before sale starts
    */
    function setAddress(address payable davy) onlyOwner public {
        require(addressLocked == false, 'ADDRESS_ALREADY_LOCKED');
        davysAddress = davy;
    }
    
    /*
    the addresses must be locked in order to start the sale, ensuring the destination of the sale funds
    cannot be changed
    */
    function lockAddress() onlyOwner public {
        addressLocked = true;
    }
    
    /*
    trasfers eth to locking contract, mints and transters liquidity tokens to the locking contract, 
    gives dev funds, then ends the sale, locking out sale functions
    */
    function injectLiquidity() onlyOwner public {
        require(now >= endDate, 'END_DATE_NOT_REACHED');
        require(nonce == 2, 'NONCE_ERROR');
        require(ethInjected == false, 'ETH_INJECTED_TRUE');
        _injectEth();
        _injectLiquidityTokens();
        ethInjected = true;
        _giveDevFunds();
        _finalize();
    }
    
    
    /*
    Sends 90% of the ETH to the locking contract.
    */
    function _injectEth() nonReentrant private {
        require(now >= endDate, 'END_DATE_NOT_REACHED');
        require(nonce == 2, 'NONCE_ERROR');
        uint256 funds = address(this).balance;
        uint ethToInject = (funds / 10).mul(9);
        davysAddress.transfer(ethToInject);
        ethInjected = true;
    }
    
    /*
    Mints liquidity token and sends them to the locking contract. 
    */
    function _injectLiquidityTokens() private {
        require(now >= endDate, 'END_DATE_NOT_REACHED');
        require(nonce == 2, 'NONCE_ERROR');
        require(withdrawable == false, 'WITHDRAWABLE_TRUE');
        uint tokens = _totalReserved.div(2);
        _mint(davysAddress, tokens);
        emit Transfer(address(0), davysAddress, tokens);
    }
    
    /*
    Deposits 10% of the raised funds into the owners wallet. Can only be called via 
    the functions to inject liquidity
    */
    function _giveDevFunds() private {
        require(now >= endDate, 'END_DATE_NOT_REACHED');
        require(nonce == 2, 'NONCE_ERROR');
        require(ethInjected == true, 'ETH_INJECTED_FALSE');
        uint256 funds = (address(this).balance);
        owner.transfer(funds);
    }
    
    /*
    Locks out the last of the sale functionalities, opens withdrawls of tokens, and 
    sets the withdral limit for 2 months
    */
    function _finalize() private {
        require(now >= endDate, 'END_DATE_NOT_REACHED');
        require(nonce == 2, 'NONCE_ERROR');
        withdrawable = true;
        withdrawalLimit = now + 60 days;  
        nonce ++;
    }
    
//==================================safety releases======================================//
    
    /*
    emergency halt to protect user funds in case of error. rolls the nonce back to stop sales
    while allowing still startSale to be used again if needed. opens refund function for users
    */
    function haltSale() onlyOwner public {
        require(now < endDate, 'END_DATE_PASSED'); 
        require(nonce == 2, 'NONCE_ERROR');
        require(saleHalted == false, 'SALE_HALTED');
        nonce --;   
        saleHalted = true;
    }
    
    /*
    allows users to refund their ETH in case of the sale being
    halted
    */
    function emergencyRefund() nonReentrant public {
        require(now < endDate, 'END_DATE_PASSED'); 
        require(saleHalted == true); 
        require(ethPaid[msg.sender] > 0);
        uint256 refund = ethPaid[msg.sender];
        ethPaid[msg.sender] = 0;
        reserves[msg.sender] = 0;
        msg.sender.transfer(refund);
    }
    
    /*
    If the sale sells all the supply, the sale can be ended early
    */
    function endSaleEarly() public {
        require(now < endDate, 'END_DATE_PASSED');
        require(_totalReserved >= 999999 * (10 ** 18), 'TOTAL_SUPPLY_NOT_REACHED');
        require(nonce == 2, 'NONCE_ERROR');
        endDate = now + 1 seconds;
    }

    /*
    if the liquidity isn't injected 48 hours after the sale ends, functionality is 
    opened to the public. uint gasPrice is used twice
    */
    function publicInjectLiquidity() public {
        require(now >= endDate, 'END_DATE_NOT_REACHED');
        require(nonce == 2, 'NONCE_ERROR');
        require(ethInjected == false, 'ETH_INJECTED_TRUE');
        require(now >= safetySwitch, 'SAFETY_SWITCH_NOT_PASSED');
        _injectEth();
        _injectLiquidityTokens();
        ethInjected = true;
        _giveDevFunds();
        _finalize();
    }

}