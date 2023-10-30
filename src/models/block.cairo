#[derive(Model, Copy, Drop, Serde)]
struct Block {
    #[key]
    game_id: u32,
    #[key]
    block_id: u32,
    next: u32,
    prev: u32
}
