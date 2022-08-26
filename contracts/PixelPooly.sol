//SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "hardhat/console.sol";
import { ERC721K } from "@erc721k/core-sol/contracts/ERC721K.sol";
import { ERC721Storage } from "@erc721k/core-sol/contracts/ERC721Storage.sol";
import { PoolyPixelRender } from "./PoolyPixelRender.sol";

/**
 * @title PixelPooly
 * @author Kames Geraghty
 */
contract PixelPooly is ERC721K {


 /**
  * @notice Metadata
  * @param image       encoded byte data of the svg image
  * @param traits      encoded byte data of the traits
  */
  struct Metadata {
    bytes image;
    bytes traits;
  }


  /**
   * @notice PixelPooly Construction
   * @param name string - Name of ERC721 token
   * @param symbol string - Symbol of ERC721 token
   * @param erc721Storage address - ERC721Storage instance
   */
  constructor(
    string memory name,
    string memory symbol,
    address erc721Storage
  ) ERC721K(name, symbol, erc721Storage) {}


  /// @notice TokenID mapped to the svg metadata bytes
  mapping(uint256 => Metadata) internal tokenIdToMetadata;

  // TODO: figure out how to best hold the tier structure with the traits, expiry timestamp, and tier
  // will also need the tier number mapped to the price of that tier

  /* ===================================================================================== */
  /* External Functions                                                                    */
  /* ===================================================================================== */

  function mint(bytes memory _image, bytes memory _traits) external payable {
    // TODO: Do we validate here if the passed in traits are sent with the correct payment or in the `render` function
    uint256 tokenId = _issue(_msgSender(), ++_idCounter);
    tokenIdToMetadata[tokenId] = Metadata(_image, _traits);
  }


  /* ===================================================================================== */
  /* Internal Functions                                                                    */
  /* ===================================================================================== */

  function _tokenData(uint256 _tokenId)
    internal
    view
    virtual
    override
    returns (bytes memory, bytes memory)
  {
    bytes memory imageBytes = tokenIdToMetadata[_tokenId].image;
    bytes memory traitsBytes = tokenIdToMetadata[_tokenId].traits;
    return (imageBytes, traitsBytes);
  }

  function _issue(address _to, uint256 _tokenId) internal returns (uint256) {
    _mint(_to, _tokenId);
    return _tokenId;
  }
}
