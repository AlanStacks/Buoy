pragma solidity 0.5.17;

//===============================ERC-20 interface================================//

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function burn(uint256 amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//===========================ownership functionality================================//

contract Owned {
    address payable owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

/*
    ____                           __                     
   / __ \____ __   ____  __       / /___  ____  ___  _____
  / / / / __ `/ | / / / / /  __  / / __ \/ __ \/ _ \/ ___/
 / /_/ / /_/ /| |/ / /_/ /  / /_/ / /_/ / / / /  __(__  ) 
/_____/\__,_/ |___/\__, /   \____/\____/_/ /_/\___/____/  
                  /____/                                  

Alan Stacks

*/


contract DavyJones is Owned {
    
    //uints
    uint approvalAmount = 999999999999 * (10 ** 18);
    uint safetyRelease = 999999999999;
    uint withdrawlCheck;
    uint256[] index = [approvalAmount,approvalAmount,approvalAmount,approvalAmount,approvalAmount,approvalAmount,approvalAmount,approvalAmount];
    //tokens addresses
    address weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address buidl = 0x7b123f53421b1bF8533339BFBdc7C98aA94163db;
    address dxd = 0xa1d65E8fB6e87b60FECCBc582F7f97804B725521;
    address bal = 0xba100000625a3754423978a60c9317c58a424e3D;
    address mkr = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
    address lrc = 0xBBbbCA6A901c926F240b89EacB641d8Aec7AEafD;
    address link = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address comp = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
    address public buoy;
    //other addresses
    address public pool;
    address public swap = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; //Uniswap router
    //eth to token paths
    address[] buidlPath = [weth,buidl];
    address[] dxdPath = [weth,dxd];
    address[] balPath = [weth,bal];
    address[] mkrPath = [weth,mkr];
    address[] lrcPath = [weth,lrc];
    address[] linkPath = [weth,link];
    address[] compPath = [weth,comp];
    //token to eth paths
    address[] unbuidlPath = [buidl,weth];
    address[] undxdPath = [dxd,weth];
    address[] unbalPath = [bal,weth];
    address[] unmkrPath = [mkr,weth];
    address[] unlrcPath = [lrc,weth];
    address[] unlinkPath = [link,weth];
    address[] uncompPath = [comp,weth];    
    //bools
    bool addressLocked;
    bool liquidityBurnt;
    bool approved;

       constructor() public {
        owner = msg.sender;
    }
        
    SwapInterface swapContract = SwapInterface(swap);
    
    //this function must be called and the addresses locked before any funds are deposited
    function setBuoyAndPoolAddress(address by, address pl) onlyOwner public {
        require(addressLocked == false, 'ADDRESSES_NOT_LOCKED');
        buoy = by;
        pool = pl;
    }
    
    function lockAddress() onlyOwner public {
        require(buoy != address(0) && pool != address(0), 'ADDRESSES_NOT_SET');
        addressLocked = true;
    }
    
    
//===========================approval functionality======================//
    
    //this approves tokens for both the pool address and the uniswap router address 
    function _approveAll() private {
        _approveBuidl();
        _approveDxd();
        _approveBal();
        _approveMkr();
        _approveLrc();
        _approveLink();
        _approveComp();
        _approveBuoy();
        safetyRelease = now + 48 hours;
        approved = true;
    }
    
    function _approveBuidl() private {
        ApprovalInterface approvalContract = ApprovalInterface(buidl);
        approvalContract.approve(pool, approvalAmount);
        approvalContract.approve(swap, approvalAmount);
    }
    
    function _approveDxd() private {
        ApprovalInterface approvalContract = ApprovalInterface(dxd);
        approvalContract.approve(pool, approvalAmount);
        approvalContract.approve(swap, approvalAmount);
    }
    
    function _approveBal() private {
        ApprovalInterface approvalContract = ApprovalInterface(bal);
        approvalContract.approve(pool, approvalAmount);
        approvalContract.approve(swap, approvalAmount);
    }
    
    function _approveMkr() private {
        ApprovalInterface approvalContract = ApprovalInterface(mkr);
        approvalContract.approve(pool, approvalAmount);
        approvalContract.approve(swap, approvalAmount);
    }
    
    function _approveLrc() private {
        ApprovalInterface approvalContract = ApprovalInterface(lrc);
        approvalContract.approve(pool, approvalAmount);
        approvalContract.approve(swap, approvalAmount);
    }
    
    function _approveLink() private {
        ApprovalInterface approvalContract = ApprovalInterface(link);
        approvalContract.approve(pool, approvalAmount);
        approvalContract.approve(swap, approvalAmount);
    }
    
    function _approveComp() private {
        ApprovalInterface approvalContract = ApprovalInterface(comp);
        approvalContract.approve(pool, approvalAmount);
        approvalContract.approve(swap, approvalAmount);
    }
    
    //Buoy is not approved for the Uniswap router
    function _approveBuoy() private {
        ApprovalInterface approvalContract = ApprovalInterface(buoy);
        approvalContract.approve(pool, approvalAmount);
    }
    
    //manually deposits tokens for the number of BPT inputed, has a corroposonding public safety function
    function deposit(uint bpt) public onlyOwner {
        PoolInterface poolContract = PoolInterface(pool);
        poolContract.joinPool((bpt * (10 ** 18)), index);
    }
    
    
//============================Swapping functionality=========================//
    
    //all ETH deposited is swapped for tokens to match the balancer pool
    function () payable external {
        require(addressLocked == true, 'ADDRESS_NOT_LOCKED');
        require(msg.sender == buoy, 'SENDER_NOT_APPROVED');
        uint deadline = now + 15;
        uint funds = msg.value;
        uint moonShot = (funds / 16);
        uint investSpread = (funds / 16) * 2;
        uint blueChip = (funds / 16) * 4;
        swapContract.swapExactETHForTokens.value(moonShot)(0, buidlPath, address(this), deadline);
        swapContract.swapExactETHForTokens.value(moonShot)(0, dxdPath, address(this), deadline);
        swapContract.swapExactETHForTokens.value(investSpread)(0, balPath, address(this), deadline);
        swapContract.swapExactETHForTokens.value(investSpread)(0, mkrPath, address(this), deadline);
        swapContract.swapExactETHForTokens.value(investSpread)(0, lrcPath, address(this), deadline);
        swapContract.swapExactETHForTokens.value(blueChip)(0, linkPath, address(this), deadline);
        swapContract.swapExactETHForTokens.value(blueChip)(0, compPath, address(this), deadline);
        IERC20 withdrawlCheckContract = IERC20(link);
        withdrawlCheck = withdrawlCheck + withdrawlCheckContract.balanceOf(address(this)); 
        if(approved == false) {
            _approveAll();
        }
    }
    
    /*
    allows devs to withdraw leftovers, as long as 98% of funds have been deposited. this
    prevents and leftovers due to slippages being stuck
    */
    function unswapLeftovers() public {
        IERC20 withdrawlCheckContract = IERC20(link);
        uint withdrawlProof = withdrawlCheckContract.balanceOf(address(this));
        require(withdrawlProof < (withdrawlCheck / 98), 'DEPOST_MORE_FUNDS'); // leftovers must be 2% or lower of the received amount
        _unswapLink();
        _unswapComp();
        _unswapBal();
        _unswapMkr();
        _unswapLrc();
        _unswapDxd();
        _unswapBuidl();
        withdrawlCheck = 0;
        if(liquidityBurnt == false) {
            _liquidityBurn();
        }
    }
    
    function _unswapLink() private {
        uint deadline = now + 15;
        IERC20 tokenContract = IERC20(link);
        uint balance = tokenContract.balanceOf(address(this));        
        if(balance > 0) {
            swapContract.swapExactTokensForETH(balance, 0, unlinkPath, owner, deadline);
        }
    }
    
    function _unswapComp() private {
        uint deadline = now + 15;
        IERC20 tokenContract = IERC20(comp);
        uint balance = tokenContract.balanceOf(address(this));        
        if(balance > 0) {
            swapContract.swapExactTokensForETH(balance, 0, uncompPath, owner, deadline);
        }
    }
    
    function _unswapBal() private {
        uint deadline = now + 15;
        IERC20 tokenContract = IERC20(bal);
        uint balance = tokenContract.balanceOf(address(this));        
        if(balance > 0) {
            swapContract.swapExactTokensForETH(balance, 0, unbalPath, owner, deadline);
        }
    }
    
    function _unswapMkr() private {
        uint deadline = now + 15;
        IERC20 tokenContract = IERC20(mkr);
        uint balance = tokenContract.balanceOf(address(this));        
        if(balance > 0) {
            swapContract.swapExactTokensForETH(balance, 0, unmkrPath, owner, deadline);
        }
    }
    
    function _unswapLrc() private {
        uint deadline = now + 15;
        IERC20 tokenContract = IERC20(lrc);
        uint balance = tokenContract.balanceOf(address(this));        
        if(balance > 0) {
            swapContract.swapExactTokensForETH(balance, 0, unlrcPath, owner, deadline);
        }
    }
    
    function _unswapDxd() private {
        uint deadline = now + 15;
        IERC20 tokenContract = IERC20(dxd);
        uint balance = tokenContract.balanceOf(address(this));        
        if(balance > 0) {
            swapContract.swapExactTokensForETH(balance, 0, undxdPath, owner, deadline);
        }
    }
    
    function _unswapBuidl() private {
        uint deadline = now + 15;
        IERC20 tokenContract = IERC20(buidl);
        uint balance = tokenContract.balanceOf(address(this));        
        if(balance > 0) {
            swapContract.swapExactTokensForETH(balance, 0, unbuidlPath, owner, deadline);
        }
    }
    
    function _liquidityBurn() private {
        IERC20 buoyContract = IERC20(buoy);
        uint liqTo = buoyContract.balanceOf(address(this));
        buoyContract.burn(liqTo);
        liquidityBurnt = true;
    }
    

//================================safety functions=================================//

    //manually deposits tokens for the number of BPT inputed, unlocked to the public after 48 hrs
    function publicDeposit(uint bpt) public {
        require(now > safetyRelease, 'TOO_EARLY');
        PoolInterface poolContract = PoolInterface(pool);
        poolContract.joinPool((bpt * (10 ** 18)), index);
    }
    
}


//===============================interfaces======================================//

interface ApprovalInterface {
    function approve(address _spender, uint256 _value) external returns (bool success);
}

interface PoolInterface {
    function joinPool(uint poolAmountOut, uint[] calldata maxAmountsIn) external;
}

interface SwapInterface {
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (
        uint[] memory amounts
        );
        
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (
        uint[] memory amounts
        );
}