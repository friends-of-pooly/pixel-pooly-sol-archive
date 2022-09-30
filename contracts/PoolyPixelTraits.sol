// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IStream } from "@erc721k/core-sol/contracts/interfaces/IStream.sol";
import { ITraitsFetch } from "@erc721k/periphery-sol/contracts/interfaces/ITraitsFetch.sol";

/**
 * @title PoolyPixelTraits
 * @author Kames Geraghty
 */
contract PoolyPixelTraits is ITraitsFetch, Ownable {
  constructor() {}

  /* ===================================================================================== */
  /* External Functions                                                                    */
  /* ===================================================================================== */

  function fetch(bytes memory _input) external view returns (string memory) {
    // TODO: Destruct _input and generate correct traits
    return string.concat(_generateTrait("friend", "true"));
  }

  /* ===================================================================================== */
  /* Internal Functions                                                                    */
  /* ===================================================================================== */

  function _generateTrait(string memory _key, string memory _value)
    internal
    pure
    returns (string memory __traits)
  {
    return
      string.concat(
        '{"trait_type":'
        '"',
        _key,
        '",',
        '"value":',
        '"',
        _value,
        '"}'
      );
  }

  function _generateTraits(string[] memory _keys, string[] memory _values)
    internal
    pure
    returns (string memory __traits)
  {
    string memory _traits = "";
    for (uint256 i = 0; i < _keys.length; i++) {
      if (bytes(_values[i]).length > 0) {
        _traits = string.concat(_traits, _generateTrait(_keys[i], _values[i]), ",");
      }
    }
    return _traits;
  }
}
