// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// CD token is ERC20 token for ICO
import "@openzeppelin/contracts/access/Ownable.sol";
// imported to check ownership of NFTs to see whether one can claim or has to mint CD token
import "./ICryptoDevs.sol";
// uses for ERC721Enum.tokenOfOwnerByIndex() and ERC721.balanceOf()

contract CryptoDevToken is ERC20, Ownable {
    // Price of one Crypto Dev token
    uint256 public constant TOKEN_PRICE = 0.001 ether;
    uint256 public constant AMOUNT_PER_NFT = 10 * 10**18;           // 10 full tokens
    uint256 public constant MAX_TOTAL_SUPPLY = 10000 * 10**18;      // 10,000 full tokens
    // we need both of the above metrics with10^18
    // bcz under the hood, S/C processes values in wei (10^18) 
    // and not full tokens

    // ICryptoDevsNFT interface instance
    ICryptoDevs CryptoDevsNFT;
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD") {
        // usually, we input contract address as arg. inside the constructor
        // and initialize the Interface-instance
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    /**
       * @dev Mints `amount` number of CryptoDevTokens (amount = full tokens, not "amount in wei")
       * bcz user does not know / rather doesn't care how full tokens work in "wei" under the hood
       *  user will always want to mint in terms of full-tokens
       * Requirements:
       * - `msg.value` should be equal or greater than the tokenPrice * amount
       */
      function mint(uint256 amount) public payable {
        uint256 _requiredAmount = TOKEN_PRICE * amount;
        // tokenPrice refers to full-token, and so does the amount entered
        // (tokenPrice * amount) returns, say, 10^15 figure (0.001 ether) for 1 token
        // it won't return "0.001 ether"
        // _requiredAmount returns the same qty, 10^15 figure, in wei for comparison with msg.value
        require(msg.value >= _requiredAmount, "Ether sent is incorrect");
        // total tokens + amount <= 10000, otherwise revert the transaction
        uint256 amountWithDecimals = amount * 10**18;
        
        // below, I did not mint() inside constructor,
        // hence, I do not own all the _totalSupply
        // hence, _totalSupply is not set at deployment unlike ususal test-scenarios
        // hence, it's zero for now and we restricted it / put a check using custom var: MAX_TOTAL_SUPPLY
        // this scenario is different
        // we're launching an ICO that's open to public for minting

        // Private-owning/minting is different than public-minting/ICO
        require(
              (totalSupply() + amountWithDecimals) <= MAX_TOTAL_SUPPLY,
              "Exceeds the max total supply available."
          );
        // totalSupply() also returns in wei
        // we made the comparison in wei, rater than full-tokens
        // call the internal function from Openzeppelin's ERC20 contract
        _mint(msg.sender, amountWithDecimals);
        // amountWithDecimals should be in wei bcz this gets stored in the mapping of ERC20
    }
    /**
       * @dev Mints tokens based on the number of NFT's held by the sender
       * Requirements:
       * balance of Crypto Dev NFT's owned by the sender should be greater than 0
       * Tokens should have not been claimed for all the NFTs owned by the sender
       */
    function claim() public {
        // minimalist functionality:
        // msg.sender will be sent all CDtokens vis-a-vis NFTs held by it.
        // no input arg = holder not given option to claim CDtokens...
        // pertaining to NFTs held less than the count of NFTs it actually holds
        // Also, no payable bcz amount already paid while minting NFTs earlier in CryptoDevs NFT dApp
        address sender = msg.sender;
        // Get the number of CryptoDev NFT's held by a given sender address
        uint256 balance = CryptoDevsNFT.balanceOf(sender);  // ERC721 
        // If the balance is zero, revert the transaction
        // part-1: requirement
        require(balance > 0, "You don't own any Crypto Dev NFT");
        
        // part 2: requirement
        // amount keeps track of number of unclaimed tokenIds
        uint256 amount = 0;
        // loop over the list of TokenIds held by the Owner with 'i'
        // has to be less than the balance (CryptoDevsNFT.balanceOf(sender);)
        // use the locally declared mapping 'tokenIdsClaimed'
        // first time claimer = false, turned true, now he can't claim ever
        // he has to mint() if more tokens needed
        for (uint256 i = 0; i < balance; i++) {
              uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);   //ERC721Enum
              // if the tokenId has not been claimed, increase the amount
              if (!tokenIdsClaimed[tokenId]) {
                  // amount is full-tokens (not wei)
                  amount += 1;
                  tokenIdsClaimed[tokenId] = true;
              }
          }
        // If all the token Ids have been claimed, revert the transaction;
        require(amount > 0, "You have already claimed all the tokens");
        // call the internal function from Openzeppelin's ERC20 contract
        // Mint (amount * 10) tokens for each NFT
        _mint(msg.sender, amount * AMOUNT_PER_NFT);
        // bcz _mint() always takes qty. in wei to be minted
    }
    
    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        // address(this).balance will have some value bczusers minted tokens and sent 0.001 ether-equivalent amount
        require(amount > 0, "Nothing to withdraw, contract balance empty");
        // retrieve the _owner if amount>0
        address _owner = owner();
        // send now
        (bool sucess, ) = _owner.call{value: amount}("");
        require(sucess, "Failed to send Ether");
    }
    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}

