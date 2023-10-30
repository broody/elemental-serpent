use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct Owner {
    #[key]
    game_id: u32,
    #[key]
    player_id: ContractAddress,
    block_id: u32,
}
