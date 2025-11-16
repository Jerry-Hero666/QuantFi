 // // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// import "forge-std/Test.sol";
// import {TradingContract} from "../../src/hyper/CoreWriterCaller.sol";
// import {CoreWriter} from "../../src/hyper/CoreWriter.sol";
// import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
// import "../../src/hyper/L1Read.sol";
// import "../../src/hyper/SpotPriceOracle.sol";
// contract CoreWriterCallerTest is Test {
//     TradingContract public tradingContract;
//     address public user;
//     SpotPriceOracleReader public spotPriceOracleReader;
//     CoreWriter public coreWriter;

//     // 声明 RawAction 事件，与 CoreWriter 中定义的保持一致
//     event RawAction(address sender, bytes data);

//     function setUp() public {
//         bytes32 privateKey = vm.envBytes32("PRIVATE_KEY_2");
//         user = vm.addr(uint256(privateKey));
//         console.log("user: ", user);
//         vm.startPrank(user);
//         tradingContract = new TradingContract();
//         // 结束 prank，再以 user 身份调用 initialize
//         ERC1967Proxy proxy = new ERC1967Proxy(
//             address(tradingContract),、
//             abi.encodeWithSelector(TradingContract.initialize.selector, user)
//         );
//         tradingContract = TradingContract(address(proxy));
//         console.log("tradingContract: ", address(tradingContract));
//         spotPriceOracleReader = new SpotPriceOracleReader();
//         coreWriter = CoreWriter(
//             address(0x3333333333333333333333333333333333333333)
//         );
//         vm.stopPrank();
//     }

//     function test_PlaceLimitOrder() public {
//         vm.startPrank(user);
//         uint32 asset = 1;
//         bool isBuy = true;
//         uint64 limitPx = 1000;
//         uint64 sz = 50;
//         bool reduceOnly = false;
//         uint8 encodedTif = 1;
//         uint128 cloid = 12345;

//         //vm.expectEmit(address(coreWriter));
//         // emit RawAction(address(tradingContract),
//         //     abi.encodePacked(
//         //         bytes1(0x01), // version
//         //         bytes1(0x00), bytes1(0x00), bytes1(0x01), // actionId
//         //         abi.encode(asset, isBuy, limitPx, sz, reduceOnly, encodedTif, cloid)
//         //     )
//         // );

//         tradingContract.placeLimitOrder(
//             asset,
//             isBuy,
//             limitPx,
//             sz,
//             reduceOnly,
//             encodedTif,
//             cloid
//         );
//         vm.stopPrank();
//     }

//     function test_SendUsdClassTransfer() public {
//         vm.startPrank(user);

//         uint64 ntl = 100;
//         bool toPerp = true;

//         // vm.expectEmit(address(coreWriter));
//         // emit RawAction(
//         //     address(tradingContract),
//         //     abi.encodePacked(
//         //         bytes1(0x01), // version
//         //         bytes1(0x00),
//         //         bytes1(0x00),
//         //         bytes1(0x07), // actionId
//         //         abi.encode(ntl, toPerp)
//         //     )
//         // );

//         tradingContract.sendUsdClassTransfer(ntl, toPerp);
//         // SpotInfo memory spotInfo = spotPriceOracleReader.spotInfo(0);
//         // console.log(spotInfo);
//         // 获取记录的日志
//         Vm.Log[] memory entries = vm.getRecordedLogs();

//         //验证日志内容
//         for (uint i = 0; i < entries.length; i++) {
//             // 检查事件内容
//             console.logBytes32(entries[i].topics[0]);
//         }
//         vm.stopPrank();
//     }
// }
