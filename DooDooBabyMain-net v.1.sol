// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title DooDooBaby Token
 * @dev Implementation of the DooDooBaby token, inheriting from ERC20, ERC20Burnable, and Ownable.
 */
contract DooDooBaby {
    // State variables
    bytes32 private immutable _name;
    bytes32 private immutable _symbol;
    uint256 private immutable _decimals;
    uint256 private _totalSupply;
    address private _owner;
    uint256 private locked = 1; // Reentrancy guard

    struct Account {
        uint256 balance;
        mapping(address => uint256) allowances;
    }

    mapping(address => Account) private _accounts;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Constructor
     * @param initialOwner The initial owner of the contract
     */
    constructor(address initialOwner) payable {
        _name = "DooDoo Baby";
        _symbol = "DooDoo";
        _decimals = 18;
        _owner = initialOwner;
        _totalSupply = 1e9 * 10**_decimals; // 1 billion tokens with 18 decimals
        _accounts[initialOwner].balance = _totalSupply;
        emit Transfer(address(0), initialOwner, _totalSupply);
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Modifier to prevent reentrancy
     */
    modifier nonReentrant() {
        require(locked == 1, "Reentrant call");
        locked = 2;
        _;
        locked = 1;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _bytes32ToString(_name);
    }

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _bytes32ToString(_symbol);
    }

    /**
     * @dev Returns the number of decimals of the token.
     */
    function decimals() public view returns (uint256) {
        return _decimals;
    }

    /**
     * @dev Returns the total supply of the token.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the balance of the specified `account`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _accounts[account].balance;
    }

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) public nonReentrant returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the allowance mechanism. `amount` is then deducted from the caller's allowance.
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public nonReentrant returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _accounts[sender].allowances[msg.sender] - amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     * Emits an {Approval} event.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _accounts[msg.sender].allowances[spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     * Emits an {Approval} event.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _accounts[msg.sender].allowances[spender] - subtractedValue);
        return true;
    }

    /**
     * @dev Returns the amount of tokens approved by the `owner` that can be transferred to the `spender`'s account.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _accounts[owner].allowances[spender];
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     * This internal function is equivalent to {transfer}, and can be used to implement automatic token fees, slashing mechanisms, etc.
     * Emits a {Transfer} event.
     * Requirements:
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Invalid sender");
        require(recipient != address(0), "Invalid recipient");

        uint256 senderBalance = _accounts[sender].balance;
        require(senderBalance >= amount, "Insufficient balance");

        _accounts[sender].balance = senderBalance - amount;
        _accounts[recipient].balance += amount;
        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`'s tokens.
     * This internal function is equivalent to `approve`, and can be used to e.g. set automatic allowances for certain subsystems, etc.
     * Emits an {Approval} event.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Invalid owner");
        require(spender != address(0), "Invalid spender");

        _accounts[owner].allowances[spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Converts a bytes32 to a string.
     */
    function _bytes32ToString(bytes32 _bytes32) private pure returns (string memory) {
        uint256 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            ++i;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; ++i) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * @param newOwner The new owner of the DooDooBaby contract.
     * Requirements:
     * - The caller must be the current owner.
     */
    function transferOwnership(address newOwner) public {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }
}