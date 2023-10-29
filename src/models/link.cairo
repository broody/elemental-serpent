#[derive(Model, Copy, Drop, Serde)]
struct Link {
    #[key]
    game_id: u32,
    #[key]
    node_id: u32,
    next: u32,
    prev: u32
}
