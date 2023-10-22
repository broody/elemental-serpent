use dojo::world::IWorldDispatcher;

#[starknet::interface]
trait IGame<TContractState> {
    fn create(self: @TContractState, height: u32, width: u32, max_players: u8, min_players: u8, start_time: u64, max_time: u64, num_random_links: u8);
    fn join(self: @TContractState, game_id: u32, spawn_x: u32, spawn_y: u32);
}


#[dojo::contract]
mod game {
    use traits::Into;
    use box::BoxTrait;
    use array::ArrayTrait;
    use starknet::Zeroable;
    use starknet::{ContractAddress, get_caller_address};

    use elemental_serpent::models::config::Config;
    use elemental_serpent::models::tile::Tile;
    use elemental_serpent::models::node::{PositionTrait, Link, Position, Owner, Head};
    use super::IGame;

    #[external(v0)]
    fn create(
        self: @ContractState,
        height: u32,
        width: u32,
        max_players: u8,
        min_players: u8,
        start_time: u64,
        max_time: u64,
        num_random_links: u8,
    ) {
        let world = self.world_dispatcher.read();
        let player_id = get_caller_address();
        let game_id = world.uuid();

        set !(
            world,
            (Config {
                game_id,
                creator: player_id,
                height,
                width,
                num_players: 0,
                max_players,
                min_players,
                start_time,
                max_time,
            })
        );

        let mut seed = starknet::get_tx_info().unbox().transaction_hash;

        let mut i = 0;
        loop {
            if i == num_random_links {
                break;
            }

            let (x, y) = PositionTrait::rnd_coord(seed, width, height);
            let tile = get !(world, (game_id, x, y), Tile);
            if tile.node_id != 0 {
                continue;
            }

            let node_id = world.uuid();

            set !(
                world,
                (
                    Position {
                        game_id, node_id, x, y, 
                        }, Link {
                        game_id, node_id, next: 0, prev: 0, 
                        }, Tile {
                        game_id, x, y, node_id, 
                    }
                )
            );

            i += 1;
            seed = pedersen::pedersen(seed, i.into());
        };

        ()
    }

    #[external(v0)]
    fn join(self: @ContractState, game_id: u32, spawn_x: u32, spawn_y: u32) {
        let world = self.world_dispatcher.read();

        let mut config = get !(world, game_id, Config);
        assert(config.num_players < config.max_players, 'Game is full');
        assert(config.height > spawn_y, 'Spawn Y is out of bounds');
        assert(config.width > spawn_x, 'Spawn X is out of bounds');

        let player_id = get_caller_address();
        let owner = get !(world, (game_id, player_id), Owner);
        assert(owner.head_id == Zeroable::zero(), 'Player is already in a game');

        let mut tile = get !(world, (game_id, spawn_x, spawn_y), Tile);
        assert(tile.node_id == Zeroable::zero(), 'Cannot spawn on filled tile');

        let node_id = world.uuid();

        // spawn node
        set !(
            world,
            (
                Owner {
                    game_id, player_id, head_id: node_id
                    }, Head {
                    game_id, node_id, owner_id: player_id, prev: 0, total_links: 0
                    }, Position {
                    game_id, node_id, x: spawn_x, y: spawn_y
                }
            )
        );

        config.num_players += 1;
        tile.node_id = node_id;

        // update config and tile
        set !(world, (config, tile));

        ()
    }
}
