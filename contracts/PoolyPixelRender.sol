// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { svg } from "@erc721k/periphery-sol/contracts/svg/svg.sol";
import { SVGLibrary } from "@erc721k/periphery-sol/contracts/svg/SVGLibrary.sol";
import { SVGRegistry } from "@erc721k/periphery-sol/contracts/svg/SVGRegistry.sol";
import { Base64 } from "base64-sol/base64.sol";

contract PoolyPixelRender is Ownable {
  address internal svgLibrary;
  address internal svgRegistry;

  string private constant ENCODING = "data:image/svg+xml;base64,";
  bytes32 private constant PIXEL_POOLY_V0 =
    0x464f554e44455200000000000000000000000000000000000000000000000000;

  constructor(address _svgLibrary_, address _svgRegistry_) {
    svgLibrary = _svgLibrary_;
    svgRegistry = _svgRegistry_;
  }

  /* ===================================================================================== */
  /* External Functions                                                                    */
  /* ===================================================================================== */

  function render(bytes memory input) external view returns (string memory) {
    return encodeSvgToDataURI(_render(input));
  }

  /* ===================================================================================== */
  /* Internal Functions                                                                    */
  /* ===================================================================================== */
  function encodeSvgToDataURI(string memory data) internal view returns (string memory) {
    return string(abi.encodePacked(ENCODING, Base64.encode(bytes(data))));
  }

  function _render(bytes memory input) internal view returns (string memory) {
    (uint8 head, uint8 body, uint8 headAcc, uint8 bodyAcc, uint8 bg) = abi.decode(
      input,
      (uint8, uint8, uint8, uint8, uint8)
    );
    return
      string(
        abi.encodePacked(
          svg.start(),
          _registry(PIXEL_POOLY_V0, abi.encode(4, bg)),
          _registry(PIXEL_POOLY_V0, abi.encode(0, head)),
          _registry(PIXEL_POOLY_V0, abi.encode(1, body)),
          _registry(PIXEL_POOLY_V0, abi.encode(2, headAcc)),
          _registry(PIXEL_POOLY_V0, abi.encode(3, bodyAcc)),
          svg.end()
        )
      );
  }

  function _lib(bytes32 _key, bytes memory _value) internal view returns (string memory) {
    return SVGLibrary(svgLibrary).execute(_key, _value);
  }

  function _registry(bytes32 _key, bytes memory _value) internal view returns (string memory) {
    return SVGRegistry(svgRegistry).fetch(_key, _value);
  }
}
