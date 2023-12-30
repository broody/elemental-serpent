use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct Cell {
    #[key]
    game_id: u32,
    #[key]
    x: u32,
    #[key]
    y: u32,
    #[key]
    z: u32,
    link_id: u32,
    player_id: ContractAddress,
}
