pragma solidity 0.6.12;

// Locks Uniswap liquidity and releases 1/8th of the liquidity every 3 months to the devs
contract DevFund {
    
    uint share;
    uint nonce = 1;
    uint public withdrawCheck;
    uint quarter = 92 days;
    uint timeStarted;
    address owner;
    address uniswapTokens;
    bool addressLocked;

    constructor() public payable {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    //set with the address of the uniswap liquidity token
    function setAddress(address a) onlyOwner public {
        require(addressLocked == false, 'DEPOSIT_CONFIRMED');
        uniswapTokens = a;
    }
    
    //Locks the address 
    //takes balance of tokens, makes sure it's not 0, and splits that value into a share at the rate of 1/8.
    //assigns the time of confirmation to timeStarted
    //sets the next withdrawl 92 days from the confirmation
    function confirmDeposit() onlyOwner public {
        require(uniswapTokens != address(0), 'ADDRESS_NOT_SET');
        require(addressLocked == false, 'DEPOSIT_CONFIRMED');
        addressLocked = true;
        IERC20 ERC20Interface = IERC20(uniswapTokens);
        uint balance = ERC20Interface.balanceOf(address(this));
        require(balance != 0, 'FUNDS_NOT_DEPOSITED');
        share = balance/8;
        timeStarted = now;
        withdrawCheck = timeStarted + quarter;
    }

    //requires it to be past the current withdral date
    //withdraws 1/8th of the liquidity tokens
    //sets the next withdral date 92 days past the last withdrawl date
    function withdrawShare() onlyOwner public {
        require(addressLocked == true, 'DEPOSIT_NOT_CONFIRMED');
        require(now > withdrawCheck);
        IERC20 ERC20Interface = IERC20(uniswapTokens);
        ERC20Interface.transfer(msg.sender, share);
        nonce++;
        withdrawCheck = timeStarted + (nonce * quarter);
    }

}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}