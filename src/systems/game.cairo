use dojo::world::IWorldDispatcher;

#[starknet::interface]
trait IGame<TContractState> {
    fn create(
        self: @TContractState,
        height: u32,
        width: u32,
        depth: u32,
        max_blocks: u32,
        max_players: u8,
        start_time: u64,
        max_time: u64,
    ) -> u32;
    fn join(self: @TContractState, game_id: u32, x: u32, y: u32, z: u32);
}


#[dojo::contract]
mod game {
    use core::debug::PrintTrait;
    use core::traits::Into;
    use core::box::BoxTrait;
    use core::array::ArrayTrait;
    use starknet::Zeroable;
    use starknet::{ContractAddress, get_caller_address};

    use godai::models::config::Config;
    use godai::models::cell::Cell;
    use godai::models::owner::Owner;
    use godai::models::block::{head::{Head, Element}, link::Link, position::{Position, PositionTrait}};
    use super::IGame;

    #[external(v0)]
    fn create(
        self: @ContractState,
        height: u32,
        width: u32,
        depth: u32,
        max_blocks: u32,
        max_players: u8,
        start_time: u64,
        max_time: u64,
    ) -> u32 {
        let world = self.world_dispatcher.read();
        let player_id = get_caller_address();
        let game_id = world.uuid();

        set!(
            world,
            (Config {
                game_id,
                creator: player_id,
                height,
                width,
                depth,
                num_blocks: 0,
                max_blocks,
                num_players: 0,
                max_players,
                start_time,
                max_time,
            })
        );

        // let mut seed = starknet::get_tx_info().unbox().transaction_hash;

        // let mut i = 0;
        // loop {
        //     if i == num_random_links {
        //         break;
        //     }

        //     let (x, y) = PositionTrait::rnd_coord(seed, width, height);
        //     let tile = get!(world, (game_id, x, y), Tile);
        //     if tile.block_id != 0 {
        //         continue;
        //     }

        //     let block_id = world.uuid();

        //     set!(
        //         world,
        //         (
        //             Position { game_id, block_id, x, y, },
        //             Link { game_id, block_id, next: 0, prev: 0, },
        //             Tile { game_id, x, y, block_id, }
        //         )
        //     );

        //     i += 1;
        //     seed = pedersen::pedersen(seed, i.into());
        // };

        game_id
    }

    #[external(v0)]
    fn join(self: @ContractState, game_id: u32, x: u32, y: u32, z: u32) {
        let world = self.world_dispatcher.read();
        let mut config = get!(world, game_id, Config);
        assert(config.num_players < config.max_players, 'Game is full');
        assert(config.height > x, 'Spawn Y is out of bounds');
        assert(config.width > y, 'Spawn X is out of bounds');
        assert(config.depth > z, 'Spawn Z is out of bounds');

        let player_id = get_caller_address();
        let owner = get!(world, (game_id, player_id), Owner);
        assert(owner.block_id == Zeroable::zero(), 'Player is already in a game');

        let mut cell = get!(world, (game_id, x, y, z), Cell);
        assert(cell.block_id == Zeroable::zero(), 'Cannot spawn in occupied cell');

        let block_id = world.uuid();

        set!(
            world,
            (
                Owner { game_id, player_id, block_id },
                Head {
                    game_id,
                    block_id,
                    owner_id: player_id,
                    prev: 0,
                    total_links: 0,
                    element: Element::None,
                    position: Position { x, y, z },
                },
                Cell { game_id, block_id, x, y, z}
            )
        );

        config.num_players += 1;

        // update config 
        set!(world, (config));
    }
}
