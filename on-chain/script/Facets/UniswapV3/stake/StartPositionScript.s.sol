//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

//Foundry Stuff
import { Script, console } from "forge-std/Script.sol";

//Protocol Scripts
import { DeployInit } from "script/DeployInit.s.sol";
import { HelperConfig } from "script/Helpers/HelperConfig.s.sol";

//Protocol Contracts
import { DiamondCutFacet } from "src/diamond/DiamondCutFacet.sol";
import { Diamond } from "src/Diamond.sol";
import { StartUniswapV3PositionFacet } from "src/facets/stake/UniswapV3/StartUniswapV3PositionFacet.sol";

//Protocol Interfaces
import { IDiamondCut } from "src/interfaces/IDiamondCut.sol";

contract StartPositionScript is Script {
    //Scripts Instances
    DeployInit s_deploy;

    //Contracts Instances
    Diamond s_diamond;
    DiamondCutFacet s_cut;

    //Wraps
    DiamondCutFacet s_cutWrapper;

    function run(HelperConfig _helperConfig) public {
        HelperConfig.NetworkConfig memory config = _helperConfig.getConfig();
        // HelperConfig.DexSpecifications memory dex = config.dex;
        HelperConfig.StakingSpecifications memory stake = config.stake;

        vm.startBroadcast(config.admin);
        StartUniswapV3PositionFacet facet = new StartUniswapV3PositionFacet(
            config.diamond,
            stake.uniswapV3PositionManager,
            config.multisig
        );
        
        s_cutWrapper = DiamondCutFacet(address(config.diamond));
        _addNewFacet(s_cutWrapper, address(facet));
        vm.stopBroadcast();
    }

    function _addNewFacet(DiamondCutFacet cutWrapper_, address facet_) public {
        bytes4[] memory selectors = new bytes4[](1);
        ///@notice update accordingly with the action being performed
        selectors[0] = StartUniswapV3PositionFacet.startPositionUniswapV3.selector;

        ///@notice update accordingly with the action to be performed
        IDiamondCut.FacetCut memory facetCut = IDiamondCut.FacetCut({
            facetAddress: facet_,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: selectors
        });

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);        
        cuts[0] = facetCut;

        cutWrapper_.diamondCut(
            cuts,
            address(0), ///@notice update it if the facet needs initialization
            "" ///@notice update it if the facet needs initialization
        );
    }

}