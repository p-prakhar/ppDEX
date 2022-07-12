// SPDX-License-Identifier: PRATHAM
pragma solidity >=0.8.0 <0.9.0;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}





library SafeMathLibrary {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // require(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // require(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}





contract ppSwapExchangeCreator{
    event ExchangeLaunch(address indexed exchange, address indexed token);

    // index of tokens with registered exchanges
    address[] public tokenList;
    mapping(address => address) tokenToExchange;
    mapping(address => address) exchangeToToken;

    function launchExchange(address _token) public returns (address exchange) {
        require(tokenToExchange[_token] == address(0));             //There can only be one exchange per token
        require(_token != address(0) && _token != address(this));
        ppSwap newExchange = new ppSwap(_token);
        tokenList.push(_token);
        tokenToExchange[_token] = address(newExchange);
        exchangeToToken[address(newExchange)] = _token;
        emit ExchangeLaunch(address(newExchange), _token);
        return address(newExchange);
    }

    function getExchangeCount() public view returns (uint exchangeCount) {
        return tokenList.length;
    }

    function tokenToExchangeLookup(address _token) public view returns (address exchange) {
        return tokenToExchange[_token];
    }

    function exchangeToTokenLookup(address _exchange) public view returns (address token) {
        return exchangeToToken[_exchange];
    }
}





contract ppSwap {
  using SafeMathLibrary for uint256;

  // Events
  event EthToTokenPurchase(address indexed buyer, uint256 indexed ethIn, uint256 indexed tokensOut);
  event TokenToEthPurchase(address indexed buyer, uint256 indexed tokensIn, uint256 indexed ethOut);
  event ProvidingLiquidity(address indexed liquidityProvider, uint256 indexed lpTokensPurchased);
  event RemovingLiquidity(address indexed liquidityProvider, uint256 indexed lpTokensBurned);

  // CONSTANTS
  uint256 public constant FEE_RATE = 500;        //fee = 1/feeRate = 0.2%

  // STORAGE
  uint256 public ethPool;
  uint256 public tokenPool;
  uint256 public invariant;
  uint256 public totalLpTokens;
  address public tokenAddress;
  address public factoryAddress;
  mapping(address => uint256) lpTokens;
  IERC20 token;
  ppSwapExchangeCreator factory;

  // MODIFIERS

  // checks if there is a swap i.e. liquidity pool initialized
  modifier exchangeInitialized() {
      require(invariant > 0 && totalLpTokens > 0);
      _;
  }

  // CONSTRUCTOR
  constructor(address _tokenAddress) {
      tokenAddress = _tokenAddress;
      factoryAddress = msg.sender;
      token = IERC20(tokenAddress);
      factory = ppSwapExchangeCreator(factoryAddress);
  }

  // FALLBACK FUNCTION
  receive () external payable{
    require(msg.value != 0);
    ethToToken(msg.sender, msg.sender, msg.value, 1);
  }

  fallback() external payable{}

  // EXTERNAL FUNCTIONS
  function initializeExchange(uint256 _tokenAmount) external payable {
      require(invariant == 0 && totalLpTokens == 0);
      require(msg.value != 0 && _tokenAmount != 0);
      ethPool = msg.value;
      tokenPool = _tokenAmount;
      invariant = ethPool.mul(tokenPool);
      lpTokens[msg.sender] = 10000;
      totalLpTokens = 10000;
      require(token.transferFrom(msg.sender, address(this), _tokenAmount));
  }

  // Invest liquidity and receive lp tokens
  function investLiquidity(
      uint256 _minlpTokens
  )
      external
      payable
      exchangeInitialized
  {
      require(msg.value > 0 && _minlpTokens > 0);
      uint256 ethPerLpToken = ethPool.div(totalLpTokens);
      require(msg.value >= ethPerLpToken);
      uint256 lpTokensPurchased = msg.value.div(ethPerLpToken);
      require(lpTokensPurchased >= _minlpTokens);
      uint256 tokensPerLpToken = tokenPool.div(totalLpTokens);
      uint256 tokensRequired = lpTokensPurchased.mul(tokensPerLpToken);
      lpTokens[msg.sender] = lpTokens[msg.sender].add(lpTokensPurchased);
      totalLpTokens = totalLpTokens.add(lpTokensPurchased);
      ethPool = ethPool.add(msg.value);
      tokenPool = tokenPool.add(tokensRequired);
      invariant = ethPool.mul(tokenPool);
      emit ProvidingLiquidity(msg.sender, lpTokensPurchased);
      require(token.transferFrom(msg.sender, address(this), tokensRequired));
  }

  // Divest lp tokens and receive liquidity
  function divestLiquidity(
      uint256 _lpTokensBurned,
      uint256 _minEth,
      uint256 _minTokens
  )
      external
  {
      require(_lpTokensBurned > 0);
      lpTokens[msg.sender] = lpTokens[msg.sender].sub(_lpTokensBurned);
      uint256 ethPerLpToken = ethPool.div(totalLpTokens);
      uint256 tokensPerLpToken = tokenPool.div(totalLpTokens);
      uint256 ethDivested = ethPerLpToken.mul(_lpTokensBurned);
      uint256 tokensDivested = tokensPerLpToken.mul(_lpTokensBurned);
      require(ethDivested >= _minEth && tokensDivested >= _minTokens);
      totalLpTokens = totalLpTokens.sub(_lpTokensBurned);
      ethPool = ethPool.sub(ethDivested);
      tokenPool = tokenPool.sub(tokensDivested);
      if (totalLpTokens == 0) {
          invariant = 0;
      } else {
          invariant = ethPool.mul(tokenPool);
      }
      emit RemovingLiquidity(msg.sender, _lpTokensBurned);
      require(token.transfer(msg.sender, tokensDivested));
      payable(msg.sender).transfer(ethDivested);
  }

  // View lp token balance of an address
  function lpTokensBalance(
      address _provider
  )
      external
      view
      returns(uint256 _lpTokens)
  {
      return lpTokens[_provider];
  }


  // Buyer swaps ETH for Tokens
  function ethToTokenSwap(
      uint256 _minTokens
  )
      external
      payable
  {
      require(msg.value > 0 && _minTokens > 0);
      ethToToken(msg.sender, msg.sender, msg.value,  _minTokens);
  }

  // Payer pays in ETH, recipient receives Tokens
  function ethToTokenPayment(
      uint256 _minTokens,
      address _recipient
  )
      external
      payable
  {
      require(msg.value > 0 && _minTokens > 0);
      require(_recipient != address(0) && _recipient != address(this));
      ethToToken(msg.sender, _recipient, msg.value,  _minTokens);
  }

  // Buyer swaps Tokens for ETH
  function tokenToEthSwap(
      uint256 _tokenAmount,
      uint256 _minEth
  )
      external
  {
      require(_tokenAmount > 0 && _minEth > 0);
      tokenToEth(msg.sender, payable(msg.sender), _tokenAmount, _minEth);
  }

  // Payer pays in Tokens, recipient receives ETH
  function tokenToEthPayment(
      uint256 _tokenAmount,
      uint256 _minEth,
      address payable _recipient
  )
      external
  {
      require(_tokenAmount > 0 && _minEth > 0);
      require(_recipient != address(0) && _recipient != address(this));
      tokenToEth(msg.sender, _recipient, _tokenAmount, _minEth);
  }


  // INTERNAL FUNCTIONS
  function ethToToken(
      address buyer,
      address recipient,
      uint256 ethIn,
      uint256 minTokensOut
  )
      internal
      exchangeInitialized
  {
      uint256 fee = ethIn.div(FEE_RATE);
      uint256 newEthPool = ethPool.add(ethIn);
      uint256 tempEthPool = newEthPool.sub(fee);
      uint256 newTokenPool = invariant.div(tempEthPool);
      uint256 tokensOut = tokenPool.sub(newTokenPool);
      require(tokensOut >= minTokensOut && tokensOut <= tokenPool);
      ethPool = newEthPool;
      tokenPool = newTokenPool;
      invariant = newEthPool.mul(newTokenPool);
      emit EthToTokenPurchase(buyer, ethIn, tokensOut);
      require(token.transfer(recipient, tokensOut));
  }

  function tokenToEth(
      address buyer,
      address payable recipient,
      uint256 tokensIn,
      uint256 minEthOut
  )
      internal
      exchangeInitialized
  {
      uint256 fee = tokensIn.div(FEE_RATE);
      uint256 newTokenPool = tokenPool.add(tokensIn);
      uint256 tempTokenPool = newTokenPool.sub(fee);
      uint256 newEthPool = invariant.div(tempTokenPool);
      uint256 ethOut = ethPool.sub(newEthPool);
      require(ethOut >= minEthOut && ethOut <= ethPool);
      tokenPool = newTokenPool;
      ethPool = newEthPool;
      invariant = newEthPool.mul(newTokenPool);
      emit TokenToEthPurchase(buyer, tokensIn, ethOut);
      require(token.transferFrom(buyer, address(this), tokensIn));
      recipient.transfer(ethOut);
  }


}