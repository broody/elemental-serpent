use godai::models::block::position::{Position};

#[derive(Model, Copy, Drop, Serde)]
struct Link {
    #[key]
    game_id: u32,
    #[key]
    block_id: u32,
    position: Position,
    next: u32,
    prev: u32
}
