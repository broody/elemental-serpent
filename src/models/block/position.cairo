use core::traits::TryInto;
use core::traits::Into;
use core::option::OptionTrait;

use godai::utils::math::{MathTrait};

#[derive(Copy, Drop, Serde, Introspect)]
struct Position {
    x: u32,
    y: u32,
    z: u32,
}

trait PositionTrait {
    fn rnd_coord(seed: felt252, width: u32, height: u32) -> (u32, u32);
    fn is_equal(self: Position, b: Position) -> bool;
    fn is_adjacent(self: Position, x: u32, y: u32, z: u32) -> bool;
}

impl PositionImpl of PositionTrait {
    // not really random but whatever
    fn rnd_coord(seed: felt252, width: u32, height: u32) -> (u32, u32) {
        let seed: u256 = seed.into();
        let x: u128 = seed.low % width.into();

        // use upper 64 bits of seed to get y
        let y: u128 = (seed.low / 2 ^ 64) % height.into();

        // safe unwrap because we know that x and y are less than width and height
        (x.try_into().unwrap(), y.try_into().unwrap())
    }

    fn is_equal(self: Position, b: Position) -> bool {
        self.x == b.x && self.y == b.y
    }

    fn is_adjacent(self: Position, x: u32, y: u32, z: u32) -> bool {
        self.x.abs_sub(x) <= 1 && self.y.abs_sub(y) <= 1 && self.z.abs_sub(z) <= 1
    }
}

