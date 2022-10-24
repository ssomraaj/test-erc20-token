// SPDX-License-Identifier: UNLICENSED

/**
 * npm imports
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

/**
 * @dev a mintable, burnable, pausable and blacklistable token contract with transfer fees.
 */
contract TestToken is ERC20Pausable, Ownable {
    mapping(address => bool) public blacklisted;
    address public feeWallet;
    uint256 public feePercent; // can be from 1 - 100

    constructor(uint256 startingSupply) ERC20("TEST", "TST") {
        _mint(msg.sender, startingSupply);
    }

    /**
     * @dev allows owner to update fee wallet.
     */
    function updateFeeWallet(address feeWalletAddress) external onlyOwner {
        feeWallet = feeWalletAddress;
    }

    /**
     * @dev allows owner to update fee percent.
     */
    function updateFeePercent(uint256 feePercentAmount) external onlyOwner {
        feePercent = feePercentAmount;
    }

    /**
     * @dev allows admin to mint tokens to a _to address
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev allows admin to add a user to blacklist
     */
    function blacklist(address user) external onlyOwner {
        require(!blacklisted[user], "User already blacklisted");
        blacklisted[user] = true;
    }

    /**
     * @dev allows admin to remove user from blacklist
     */
    function removeFromBlacklist(address user) external onlyOwner {
        require(blacklisted[user], "User not blacklisted");
        blacklisted[user] = false;
    }

    /**
     * @dev allows users to burn their tokens.
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /**
     * @dev override transfer to check for blacklist.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        uint256 fees = (amount * feePercent) / 100;
        uint256 transferAmount = amount - fees;
        _transfer(msg.sender, to, transferAmount);
        _transfer(msg.sender, feeWallet, fees);
        return true;
    }

    /**
     * @dev override transfer from function.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        uint256 fees = (amount * feePercent) / 100;
        uint256 transferAmount = amount - fees;
        _transfer(msg.sender, to, transferAmount);
        _transfer(msg.sender, feeWallet, fees);
        return true;
    }

}