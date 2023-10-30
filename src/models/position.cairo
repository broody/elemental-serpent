use traits::TryInto;
use traits::Into;
use option::OptionTrait;

#[derive(Model, Copy, Drop, Serde)]
struct Position {
    #[key]
    game_id: u32,
    #[key]
    block_id: u32,
    x: u32,
    y: u32
}

trait PositionTrait {
    fn rnd_coord(seed: felt252, width: u32, height: u32) -> (u32, u32);
    fn is_equal(self: Position, b: Position) -> bool;
    fn is_adjacent(self: Position, x: u32, y: u32) -> bool;
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

    fn is_adjacent(self: Position, x: u32, y: u32) -> bool {
        if x == self.x {
            if y - 1 == self.y {
                return true;
            }

            if y + 1 == self.y {
                return true;
            }
        }

        if y == self.y {
            if x - 1 == self.x {
                return true;
            }

            if x + 1 == self.x {
                return true;
            }
        }

        return false;
    }
}

