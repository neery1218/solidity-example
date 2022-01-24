// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0;

// https://onbjerg.github.io/foundry-book/reference/cheatcodes.html?highlight=expectEmit#cheatcodes
// HEVM_ADDRESS is a special address that has these cheat codes available.
interface CheatCodes {
    function expectEmit(bool, bool, bool, bool) external;
    function expectRevert(bytes calldata msg) external;

    // Sets the *next* call's msg.sender to be the input address
    function prank(address) external;
}

import "../../lib/ds-test/src/test.sol";
import "../Coin.sol";

contract CoinTest is DSTest {
    Coin c;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    address v = address(0x1);

    function setUp() public {
        c = new Coin();
    }

    function testExample() public {
        assertTrue(true);
    }

    function testInit() public {
        assertEq(c.minter(), address(this));
    }

    function testMint() public {
        assertEq(c.balances(v), 0);
        c.mint(v, 5);
        assertEq(c.balances(v), 5);
    }

    event Sent(address from, address to, uint amount);
    function testSend() public {
        address u = address(0x2);
        c.mint(address(this), 5);
        assertEq(c.balances(address(this)), 5);

        cheats.expectEmit(true, true, true, true);
        emit Sent(address(this), u, 3);
        c.send(u, 3);

        assertEq(c.balances(address(this)), 2);
        assertEq(c.balances(u), 3);
    }

    function testSendMoreThanExpected() public {
        address u = address(0x3);
        c.mint(address(this), 5);

        cheats.expectRevert(
            abi.encodeWithSelector(Coin.InsufficientBalance.selector, 6, 5)
        );
        c.send(u, 6);
    }

    function testMintWithNonOwner() public {
        address u = address(0x3);

        cheats.expectRevert(bytes(""));
        cheats.prank(u);
        c.mint(address(this), 4);
    }
}
