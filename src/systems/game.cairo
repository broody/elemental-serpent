use dojo::world::IWorldDispatcher;

#[starknet::interface]
trait IGame<TContractState> {
    fn create(
        self: @TContractState,
        height: u32,
        width: u32,
        max_blocks: u32,
        max_players: u8,
        start_time: u64,
        max_time: u64,
    ) -> u32;
    fn join(self: @TContractState, game_id: u32, spawn_x: u32, spawn_y: u32);
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
    use godai::models::tile::Tile;
    use godai::models::position::{Position, PositionTrait};
    use godai::models::block::Block;
    use godai::models::owner::Owner;
    use godai::models::head::{Head, Element};
    use super::IGame;

    #[external(v0)]
    fn create(
        self: @ContractState,
        height: u32,
        width: u32,
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
    fn join(self: @ContractState, game_id: u32, spawn_x: u32, spawn_y: u32) {
        let world = self.world_dispatcher.read();
        let mut config = get!(world, game_id, Config);
        assert(config.num_players < config.max_players, 'Game is full');
        assert(config.height > spawn_y, 'Spawn Y is out of bounds');
        assert(config.width > spawn_x, 'Spawn X is out of bounds');

        let player_id = get_caller_address();
        let owner = get!(world, (game_id, player_id), Owner);
        assert(owner.block_id == Zeroable::zero(), 'Player is already in a game');

        let mut tile = get!(world, (game_id, spawn_x, spawn_y), Tile);
        assert(tile.block_id == Zeroable::zero(), 'Cannot spawn on filled tile');

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
                    total_blocks: 0,
                    element: Element::None
                },
                Position { game_id, block_id, x: spawn_x, y: spawn_y }
            )
        );

        config.num_players += 1;
        tile.game_id = game_id;
        tile.block_id = block_id;
        tile.x = spawn_x;
        tile.y = spawn_y;

        // update config and tile
        set!(world, (config, tile));
    }
}
