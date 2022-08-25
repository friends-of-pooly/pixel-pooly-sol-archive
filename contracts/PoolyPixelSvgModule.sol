// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "hardhat/console.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { svg } from "@erc721k/periphery-sol/contracts/svg/svg.sol";
import { svgUtils } from "@erc721k/periphery-sol/contracts/svg/svgUtils.sol";
import { SVGLibrary } from "@erc721k/periphery-sol/contracts/svg/SVGLibrary.sol";
import { ISVGModule } from "../interfaces/ISVGModule.sol";

contract PoolyPixelSvgModule is ISVGModule, Ownable {
  SVGLibrary private svgLibrary;

  string private encoding = "(uint8)";
  bytes32 private constant BUILD = keccak256("BUILD");
  bytes32 private constant COLOR = keccak256("COLOR");
  bytes32 private constant UTILS = keccak256("UTILS");

  mapping(uint8 => mapping(uint8 => string)) private elements;

  constructor(address _svgLibrary_) {
    svgLibrary = SVGLibrary(_svgLibrary_);
  }

  function render(bytes memory _input) external view override returns (string memory) {
    return _render(_input);
  }

  function getEncoding() external view override returns (string memory) {
    return encoding;
  }

  function getElement(uint8 _element, uint8 _position) external view returns (string memory) {
    return elements[_element][_position];
  }

  function setElement(
    uint8 _element,
    uint8 _position,
    string memory _svg
  ) external onlyOwner {
    elements[_element][_position] = _svg;
  }

  function _color(string memory _sig, string memory _value) internal view returns (string memory) {
    return _svgLibrary.execute(COLOR, abi.encodeWithSignature(_sig, _value));
  }

  function _props(string memory _key, string memory _value) internal view returns (string memory) {
    return svgLibrary.execute(BUILD, abi.encodeWithSignature("prop(string,string)", _key, _value));
  }

  function _render(bytes memory _input) internal view returns (string memory) {
    (uint8 elementType, uint8 elementId) = abi.decode(_input, (uint8, uint8));
    return elements[elementType][elementId];
  }
}
