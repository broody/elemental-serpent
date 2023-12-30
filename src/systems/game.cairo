use dojo::world::IWorldDispatcher;

#[starknet::interface]
trait IGame<TContractState> {
    fn create(
        self: @TContractState,
        height: u32,
        width: u32,
        depth: u32,
        max_links: u32,
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
    use godai::models::link::{Link, Element, Position, PositionTrait};
    use super::IGame;

    #[external(v0)]
    fn create(
        self: @ContractState,
        height: u32,
        width: u32,
        depth: u32,
        max_links: u32,
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
                max_links,
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
        //     if tile.link_id != 0 {
        //         continue;
        //     }

        //     let link_id = world.uuid();

        //     set!(
        //         world,
        //         (
        //             Position { game_id, link_id, x, y, },
        //             Link { game_id, link_id, next: 0, prev: 0, },
        //             Tile { game_id, x, y, link_id, }
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
        assert(owner.total_links == Zeroable::zero(), 'Player is already in a game');

        let mut cell = get!(world, (game_id, x, y, z), Cell);
        assert(cell.player_id == Zeroable::zero(), 'Cannot spawn in occupied cell');

        let link_id = world.uuid();
        config.num_players += 1;

        set!(
            world,
            (
                Owner {
                    game_id, player_id, head_link: link_id, tail_link: link_id, total_links: 1
                },
                Link {
                    game_id,
                    link_id,
                    element: Element::None,
                    position: Position { x, y, z },
                    next: 0
                },
                Cell { game_id, link_id, player_id, x, y, z },
                config
            )
        );
    }
}
