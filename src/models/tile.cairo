#[derive(Model, Copy, Drop, Serde)]
struct Tile {
    #[key]
    game_id: u32,
    #[key]
    x: u32,
    #[key]
    y: u32,
    block_id: u32,
}
