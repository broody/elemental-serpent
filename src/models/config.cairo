use box::BoxTrait;
use traits::Into;
use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct Config {
    #[key]
    game_id: u32,
    creator: ContractAddress,
    height: u32,
    width: u32,
    num_players: u8,
    max_players: u8,
    min_players: u8,
    start_time: u64,
    max_time: u64,
}

trait ConfigTrait {
    fn check(self: @Config) -> bool;
}

impl ConfigImpl of ConfigTrait {
    fn check(self: @Config) -> bool {
        let info = starknet::get_block_info().unbox();

        // game not started yet
        if info.block_timestamp < *self.start_time {
            return false;
        }

        // game over
        if info.block_timestamp > *self.start_time + *self.max_time {
            return false;
        }

        true
    }
}

