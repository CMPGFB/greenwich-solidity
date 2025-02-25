// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Greenwich Token
 * @dev Inspired by the NoCodeDevs at the University of Greenwich | Circa 2024 - 2025
 * A utility token that grants holders access to information in the form of PDFs or eBooks
 * Total supply: 21,000 tokens
 */
contract GreenwichToken is ERC20, Ownable {
    // Mapping from user address to resource IDs they have access to
    mapping(address => mapping(uint256 => bool)) private _userResources;
    
    // Resource pricing in tokens
    mapping(uint256 => uint256) private _resourcePrices;
    
    // Resource metadata
    mapping(uint256 => string) private _resourceNames;
    
    // Events
    event ResourceAccessed(address indexed user, uint256 indexed resourceId);
    event ResourceAdded(uint256 indexed resourceId, string name, uint256 price);
    
    constructor() ERC20("Greenwich", "GRN") Ownable(msg.sender) {
        // Mint the total supply to the contract creator
        _mint(msg.sender, 21000 * 10**decimals());
    }
    
    /**
     * @dev Add a new information resource to the system
     * @param resourceId Unique identifier for the resource
     * @param name Name of the resource
     * @param price Price in Greenwich tokens to access the resource
     */
    function addResource(uint256 resourceId, string memory name, uint256 price) external onlyOwner {
        require(_resourcePrices[resourceId] == 0, "Resource already exists");
        
        _resourcePrices[resourceId] = price;
        _resourceNames[resourceId] = name;
        
        emit ResourceAdded(resourceId, name, price);
    }
    
    /**
     * @dev Purchase access to a specific information resource
     * @param resourceId ID of the resource to purchase access to
     */
    function purchaseAccess(uint256 resourceId) external {
        uint256 price = _resourcePrices[resourceId];
        require(price > 0, "Resource does not exist");
        require(!_userResources[msg.sender][resourceId], "Already have access");
        
        // Transfer tokens from the user to this contract (tokens will be burned)
        _transfer(msg.sender, address(this), price);
        
        // Burn the tokens to reduce total supply
        _burn(address(this), price);
        
        // Grant access to the resource
        _userResources[msg.sender][resourceId] = true;
        
        emit ResourceAccessed(msg.sender, resourceId);
    }
    
    /**
     * @dev Check if a user has access to a specific resource
     * @param user Address of the user to check
     * @param resourceId ID of the resource
     * @return bool True if user has access, false otherwise
     */
    function hasAccess(address user, uint256 resourceId) external view returns (bool) {
        return _userResources[user][resourceId];
    }
    
    /**
     * @dev Get resource price
     * @param resourceId ID of the resource
     * @return uint256 Price in tokens
     */
    function getResourcePrice(uint256 resourceId) external view returns (uint256) {
        return _resourcePrices[resourceId];
    }
    
    /**
     * @dev Get resource name
     * @param resourceId ID of the resource
     * @return string Resource name
     */
    function getResourceName(uint256 resourceId) external view returns (string memory) {
        return _resourceNames[resourceId];
    }
}
