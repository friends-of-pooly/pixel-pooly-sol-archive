import { utils } from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import svg1 from '../svgs/head-pooly-cooly';
import svg2 from '../svgs/body-pooly-wings';
import svg3 from '../svgs/head-accessory-snorkel-blue';
import svg4 from '../svgs/body-accessory-unicron';

export default async function deploy(hardhat: HardhatRuntimeEnvironment) {
    const { deployments, getNamedAccounts, ethers } = hardhat;

    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    const SVGRegistry = await deployments.get("SVGRegistry");
    const SVGLibrary = await deployments.get("SVGLibrary");

    const svgRegistry = await ethers.getContractAt("SVGRegistry", SVGRegistry.address);
    
    const PoolyPixelSvgModule = await deploy("PoolyPixelSvgModule", {
      contract: "PoolyPixelSvgModule",
      from: deployer,
      args: [SVGLibrary.address],
      skipIfAlreadyDeployed: false,
      log: true,
    });

    const poolyPixel = await ethers.getContractAt("PoolyPixelSvgModule", PoolyPixelSvgModule.address);
    poolyPixel.setElement(0, 1, svg1);
    poolyPixel.setElement(1, 1, svg2);
    poolyPixel.setElement(2, 1, svg3);
    poolyPixel.setElement(3, 1, svg4);

    await svgRegistry.setWidget("0x464f554e44455200000000000000000000000000000000000000000000000000", PoolyPixelSvgModule.address);

    const PoolyPixelRender = await deploy("PoolyPixelRender", {
      contract: "PoolyPixelRender",
      from: deployer,
      args: [SVGLibrary.address, SVGRegistry.address],
      skipIfAlreadyDeployed: false,
      log: true,
    });
    
    const PoolyPixelTraits = await deploy("PoolyPixelTraits", {
      contract: "PoolyPixelTraits",
      from: deployer,
      args: [],
      skipIfAlreadyDeployed: false,
      log: true,
    });

    const contactInformation = {
      name: "PoolyPixel",
      description: "PoolyDefender.",
      image: "",
      externalLink: "https://PoolyPixel.art",
      sellerFeeBasisPoints: "0",
      feeRecipient: "0x0000000000000000000000000000000000000000",
    };

    const PoolyPixelStorage = await deploy("PoolyPixelStorage", {
      contract: "PoolyPixelStorage",
      from: deployer,
      args: [PoolyPixelRender.address, PoolyPixelTraits.address, contactInformation],
      skipIfAlreadyDeployed: false,
      log: true,
    });
    

    const PoolyPixel = await deploy("PoolyPixel", {
      contract: "PoolyNFT",
      from: deployer,
      args: ["Pooly Pixel", "BIRBI", PoolyPixelStorage.address, deployer],
      skipIfAlreadyDeployed: false,
      log: true,
    });
    
    const PoolyMinter = await deploy("PoolyMinter", {
      contract: "PoolyMinter",
      from: deployer,
      args: [],
      skipIfAlreadyDeployed: false,
      log: true,
    });
    
    const pooly = await ethers.getContractAt("PoolyNFT", PoolyPixel.address);
    await pooly.setMinter(PoolyMinter.address);
}
