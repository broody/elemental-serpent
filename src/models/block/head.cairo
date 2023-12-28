use starknet::ContractAddress;
use godai::models::block::position::{Position};

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

#[derive(Model, Copy, Drop, Serde)]
struct Head {
    #[key]
    game_id: u32,
    #[key]
    block_id: u32,
    position: Position,
    owner_id: ContractAddress,
    element: Element,
    prev: u32,
    total_links: u8
}
