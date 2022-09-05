//SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "hardhat/console.sol";
import { ERC721K } from "@erc721k/core-sol/contracts/ERC721K.sol";
import { ERC721Storage } from "@erc721k/core-sol/contracts/ERC721Storage.sol";
import {LicenseVersion, CantBeEvil} from "@a16z/contracts/licenses/CantBeEvil.sol";

/**
 * @title PixelPooly
 * @author Kames Geraghty
 */
contract PixelPooly is ERC721K, CantBeEvil {
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
   * @notice Trait
   * @param id          hash of position and image to make unique id
   * @param position    the position of the image
   * @param image       the image code
   * @param traitName   the key of the trait
   * @param traitValue  the value of the trait
   * @param tier        the tier level this trait is in
   * @param expiry      the timestamp in seconds of when this trait expires (0 if does not expire)
   */
  struct Trait {
    bytes32 id;
    uint8 position;
    uint8 image;
    string traitName;
    string traitValue;
    uint8 tier;
    uint256 expiry;
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
  ) ERC721K(name, symbol, erc721Storage) CantBeEvil(LicenseVersion.CBE_NECR_HS) {}

  /// @notice TokenID mapped to the svg metadata bytes
  mapping(uint256 => Metadata) internal tokenIdToMetadata;

  /// @notice Tier mapping for traits - tier level to price
  mapping(uint8 => uint256) internal tierToPrice; // this could be array instead

  /// @notice Trait hash to trait details
  mapping(bytes32 => Trait) internal traitMap;

  /* ===================================================================================== */
  /* EIP Functions                                                                     */
  /* ===================================================================================== */
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(CantBeEvil, ERC721K)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }

  /* ===================================================================================== */
  /* External Functions                                                                    */
  /* ===================================================================================== */

  function mint(bytes memory _image) external payable {
    bytes memory traits_ = _validateMetadata(msg.value, _image);
    uint256 tokenId = _issue(_msgSender(), ++_idCounter);
    tokenIdToMetadata[tokenId] = Metadata(_image, traits_);
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

  // TODO: internal function to validate traits picked and amount of eth sent in
  function _validateMetadata(uint256 _ethReceived, bytes memory _image)
    internal
    returns (bytes memory)
  {
    (uint8 head, uint8 body, uint8 headAcc, uint8 bodyAcc, uint8 bg, uint8 handAcc) = abi.decode(
      _image,
      (uint8, uint8, uint8, uint8, uint8, uint8)
    );

    uint256 cost = 0;

    bytes memory traits = new bytes(6);

    uint8[6] memory traitsArr = [head, body, headAcc, bodyAcc, bg, handAcc];
    // validate all these trait are correct codes and find cost if any
    for (uint8 index; index < traitsArr.length; index++) {
      // index = position
      // value = trait image code
      uint8 value = traitsArr[index];
      if (value == 0) continue; // value 0 means no image trait for this position

      // get trait id
      // abi.encode(index, value);
      bytes32 traitId = keccak256(abi.encode(index, value));

      // get trait details
      Trait memory mTrait = traitMap[traitId];
      require(mTrait.id == traitId, "PIXEL-POOLY:trait-not-found");

      cost += tierToPrice[mTrait.tier];

      // check for expiry time
      if (mTrait.expiry > 0) {
        // if expiry is 0 then it does not expire
        require(block.timestamp < mTrait.expiry, "PIXEL-POOLY:expired-trait");
      }

      // not sure how to handle the trait key and value
      traits[index] = bytes1(bytes(string.concat(mTrait.traitName, mTrait.traitValue)));
    }

    require(_ethReceived >= cost, "PIXEL-POOLY:insufficient-eth");

    return traits;
  }
}
