use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct Owner {
    #[key]
    game_id: u32,
    #[key]
    player_id: ContractAddress,
    head_link: u32,
    tail_link: u32,
    total_links: u8
}
