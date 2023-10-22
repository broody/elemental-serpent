#[derive(Model, Copy, Drop, Serde)]
struct Tile {
    #[key]
    game_id: u32,
    #[key]
    x: u32,
    #[key]
    y: u32,
    node_id: u32,
}
