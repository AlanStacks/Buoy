pragma solidity 0.5.17;

//=============================ERC-20 interface================================//

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


//================================safemath==================================//

// SPDX-License-Identifier: MIT

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

//====================================ERC-20 detailed=====================================//

contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns(string memory) {
        return _name;
    }

    function symbol() public view returns(string memory) {
        return _symbol;
    }

    function decimals() public view returns(uint8) {
        return _decimals;
    }
}


//=================================ownership Functionality==============================//

contract Owned is ERC20Detailed {
    address payable owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

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

contract Buoy is Owned {
    using SafeMath for uint256;
    
    
//================================Mappings and Variables=============================//

    //mappings
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint) reserves;
    mapping (address => uint) ethPaid;
    //booleans
    bool withdrawable;
    bool withdrawPeriodOver;
    bool poolMinted;
    bool addressLocked;
    bool ethInjected;
    bool saleHalted;
    //token info
    string private _name = "Buoy";
    string private _symbol = "BUOY";
    uint8  private _decimals = 18;
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
    

//================================Token Functionality================================//

    constructor() public payable ERC20Detailed(_name, _symbol, _decimals) {
        owner = msg.sender;
        _mintOriginPool();
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address user) public view returns (uint256) {
        return _balances[user];
    }
    
    function balanceOfMe() public view returns (uint256) {
        return _balances[msg.sender];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value <= _balances[from]);
        require(value <= _allowances[from][msg.sender]);
        require(to != address(0));
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(value);
        emit Transfer(from, to, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        _allowances[msg.sender][spender] = (_allowances[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        _allowances[msg.sender][spender] = (_allowances[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function _burn(address account, uint256 amount) private {
        require(amount != 0);
        require(amount <= _balances[account]);
        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function burnFrom(address account, uint256 amount) external {
        require(amount <= _allowances[account][msg.sender]);
        _allowances[account][msg.sender] = _allowances[account][msg.sender].sub(amount);
        _burn(account, amount);
    }
    
    
//=============================Public Sale Functionality==============================//

    /*
    mints the tokens which are used to generate the Origin Pool
    */
    function _mintOriginPool() private {
        require (poolMinted == false, 'POOL_NOT_MINTED');
        require(nonce == 0, 'NONCE_ERROR');
        uint poolTokens = (40 * (10 ** 18));
        _balances[msg.sender] = _balances[msg.sender].add(poolTokens);
        _totalSupply = _totalSupply.add(poolTokens);
        emit Transfer(address(0), msg.sender, poolTokens);
        poolMinted = true;
        nonce ++;
    }
    
    /*
    sets startDate to now and defines the sale stages off of that. 
    */
    function startSale() onlyOwner public {
        require(poolMinted == true, 'POOL_NOT_MINTED');
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
        require(now <= endDate, 'ENDDATE_PASSED');
        require(nonce == 2);
        uint tokens;
        if (now <= stage1) {
            tokens = msg.value.mul(225);
        } else if (now <= stage2) {
                tokens = msg.value.mul(200);
        } else if (now <- endDate) {
            tokens = msg.value.mul(175);
        }
        require((_totalSupply + tokens) <= 1000000 * (10 ** 18), 'TOTAL_SUPPLY_OVERFLOW');
        uint currentReserve = reserves[msg.sender];
        uint newReserve = currentReserve.add(tokens);
        reserves[msg.sender] = newReserve;
        ethPaid[msg.sender] = ethPaid[msg.sender].add(msg.value);
        _totalReserved = _totalReserved.add(tokens);
    }
    
    /*
    any ETH sent directly to the contract falls back to the buySale function
    */
    function() payable external {
        buySale();
    }
    
    /*
    This function requires the user to have funds reserved, as well as requiring the withdrawal
    dates to be active. Because unwithrawn tokens are eventually forfeit, tokens are added to
    the total supply only when withdrawn.
    */
    function withdraw() public {
        require(reserves[msg.sender] > 0, 'INPUT_TOO_LOW');
        require(withdrawable == true, 'WITHDRAWABLE_FALSE');
        require(now >= endDate, 'END_DATE_NOT_REACHED');
        require(now <= withdrawalLimit, 'WITHDRAW_LIMIT_PASSED');
        uint withdrawal = reserves[msg.sender];
        _balances[msg.sender] = _balances[msg.sender].add(withdrawal);
        emit Transfer(address(0), msg.sender, withdrawal);
        reserves[msg.sender] = 0;
        _totalReserved = _totalReserved.sub(withdrawal);
        _totalSupply = _totalSupply.add(withdrawal);
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
    

//===================================view fucntions============================//
    
    /*
    all the see functions return uint values in wei, and so need to be divided by (10 ** 18) to give an accurate decimal count
    */
    
    function viewStage() public view returns(string memory) {
        if(now <= startDate) {
            return("Public sale has not yet started");
        } else if(now <= stage1) {
            return("Stage 1 of the sale, 250 BUOY per ETH");
        } else if(now <= stage2) { 
            return("Stage 2 of the sale, 225 BUOY per ETH");
        } else if(now <= endDate) { 
            return("Stage 3 of the sale, 200 BUOY per ETH");
        } else return("Sale over, please withdraw your Buoy");
    }

    function viewPossibleReserved(uint256 a) public view returns(uint) {
        uint bonus;
        if(now <= stage1) {
            bonus = (a * (10 ** 18)) * 250;
        } else if(now <= stage2) { 
            bonus = (a * (10 ** 18)) * 225;
        } else if(now <= endDate) {
            bonus =  (a * (10 ** 18)) * 200;
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
    function setDavysAddress(address payable a) onlyOwner public {
        require(addressLocked == false, 'ADDRESS_ALREADY_LOCKED');
        davysAddress = a;
    }
    
    /*
    the addresses must be locked in order to start the sale, ensuring the destination of the sale funds
    cannot be changed
    */
    function lockDavysAddress() onlyOwner public {
        addressLocked = true;
    }
    
    /*
    trasfers eth to locking contract, mints and transters liquidity tokens to the locking contract, 
    gives dev funds, then ends the sale, locking out sale functions
    */
    function injectLiquidity(uint gasPrice) onlyOwner public {
        require(now >= endDate, 'END_DATE_NOT_REACHED');
        require(nonce == 2, 'NONCE_ERROR');
        require(ethInjected == false, 'ETH_INJECTED_TRUE');
        _injectEth(gasPrice);
        _injectLiquidityTokens();
        ethInjected = true;
        _giveDevFunds(gasPrice);
        _finalize();
    }
    
    
    /*
    Sends 90% of the ETH to the locking contract.
    */
    function _injectEth(uint gasPrice) private returns(bytes memory) {
        require(now >= endDate, 'END_DATE_NOT_REACHED');
        require(nonce == 2, 'NONCE_ERROR');
        uint256 funds = address(this).balance;
        uint ethToInject = (funds / 10).mul(9);
        (bool success, bytes memory data) = davysAddress.call.value(ethToInject).gas(gasPrice) ("f");
        ethInjected = true;
        if (!success)
        revert();
        return data;
    }
    
    /*
    Mints liquidity token and sends them to the locking contract. 
    */
    function _injectLiquidityTokens() private {
        require(now >= endDate, 'END_DATE_NOT_REACHED');
        require(nonce == 2, 'NONCE_ERROR');
        require(withdrawable == false, 'WITHDRAWABLE_TRUE');
        uint tokens = _totalReserved.div(2);
        _balances[davysAddress] = _balances[davysAddress].add(tokens);
        _totalSupply = _totalSupply.add(tokens);
        emit Transfer(address(0), davysAddress, tokens);
    }
    
    /*
    Deposits 10% of the raised funds into the owners wallet. Can only be called via 
    the functions to inject liquidity
    */
    function _giveDevFunds(uint gasPrice) private returns (bytes memory) {
        require(now >= endDate, 'END_DATE_NOT_REACHED');
        require(nonce == 2, 'NONCE_ERROR');
        require(ethInjected == true, 'ETH_INJECTED_FALSE');
        uint256 funds = (address(this).balance);
        (bool success, bytes memory data) = owner.call.value(funds).gas(gasPrice) ("f");
        if (!success) 
        revert();
        return data;
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
        require(now <= endDate, 'ENDDATE_PASSED'); 
        require(nonce == 2, 'NONCE_ERROR');
        require(saleHalted == false, 'SALE_HALTED');
        nonce --;   
        saleHalted = true;
    }
    
    /*
    allows users to refund their ETH in case of the sale being
    halted
    */
    function emergencyRefund(uint gasPrice) public returns (bytes memory) {
        require(now <= endDate, 'ENDDATE_PASSED'); 
        require(saleHalted == true); 
        require(ethPaid[msg.sender] > 0);
        uint256 refund = ethPaid[msg.sender];
        (bool success, bytes memory data) = msg.sender.call.value(refund).gas(gasPrice) ("f");
        if (!success)
        revert();
        ethPaid[msg.sender] = 0;
        return data;
    }
    
    /*
    If the sale sells all the supply, the sale can be ended early
    */
    function endSaleEarly() public {
        require(now < endDate, 'END_DATE_NOT_REACHED');
        require(_totalReserved >= 999999 * (10 ** 18), 'TOTAL_SUPPLY_NOT_REACHED');
        require(nonce == 2, 'NONCE_ERROR');
        endDate = now + 1 seconds;
    }

    /*
    if the liquidity isn't injected 48 hours after the sale ends, functionality is 
    opened to the public. uint gasPrice is used twice
    */
    function publicInjectLiquidity(uint gasPrice) public {
        require(now >= endDate, 'END_DATE_NOT_REACHED');
        require(nonce == 2, 'NONCE_ERROR');
        require(ethInjected == false, 'ETH_INJECTED_TRUE');
        require(now >= safetySwitch, 'SAFETY_SWITCH_NOT_PASSED');
        _injectEth(gasPrice);
        _injectLiquidityTokens();
        ethInjected = true;
        _giveDevFunds(gasPrice);
        _finalize();
    }    
    
}