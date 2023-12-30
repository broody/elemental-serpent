use core::traits::TryInto;
use core::traits::Into;
use core::option::OptionTrait;

use godai::utils::math::{MathTrait};

#[derive(Model, Copy, Drop, Serde)]
struct Link {
    #[key]
    game_id: u32,
    #[key]
    link_id: u32,
    element: Element,
    position: Position,
    next: u32
}

#[derive(Serde, Copy, Drop, Introspect)]
enum Element {
    None: (),
    Void: (),
    Earth: (),
    Water: (),
    Fire: (),
    Wind: (),
}

impl ElementIntoFelt252 of Into<Element, felt252> {
    fn into(self: Element) -> felt252 {
        match self {
            Element::None => 0,
            Element::Void => 1,
            Element::Earth => 2,
            Element::Water => 3,
            Element::Fire => 4,
            Element::Wind => 5,
        }
    }
}

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
struct Position {
    x: u32,
    y: u32,
    z: u32,
}

trait PositionTrait {
    fn rnd_coord(seed: felt252, width: u32, height: u32, depth: u32) -> (u32, u32, u32);
    fn is_equal(self: Position, b: Position) -> bool;
    fn is_adjacent(self: Position, x: u32, y: u32, z: u32) -> bool;
}

impl PositionImpl of PositionTrait {
    // not really random but whatever
    fn rnd_coord(seed: felt252, width: u32, height: u32, depth: u32) -> (u32, u32, u32) {
        let seed: u256 = seed.into();
        let x: u128 = seed.low % width.into();

        // use upper 64 bits of seed to get y
        let y: u128 = (seed.low / 2 ^ 64) % height.into();

        let z: u128 = (seed.high / 2 ^ 64) % depth.into();

        // safe unwrap because we know that x and y are less than width and height
        (x.try_into().unwrap(), y.try_into().unwrap(), z.try_into().unwrap())
    }

    fn is_equal(self: Position, b: Position) -> bool {
        self.x == b.x && self.y == b.y
    }

    fn is_adjacent(self: Position, x: u32, y: u32, z: u32) -> bool {
        self.x.abs_sub(x) <= 1 && self.y.abs_sub(y) <= 1 && self.z.abs_sub(z) <= 1
    }
}

