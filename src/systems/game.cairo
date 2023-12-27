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
    );
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

        // spawn node
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
        tile.block_id = block_id;

        // update config and tile
        set!(world, (config, tile));

        ()
    }
}


#[cfg(test)]
mod tests {
    use core::debug::PrintTrait;
    use starknet::{ContractAddress, contract_address_const};
    use starknet::class_hash::Felt252TryIntoClassHash;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    //use godai::tests::setup;
    use godai::models::config::{config, Config};
    use godai::models::tile::{tile, Tile};
    use godai::models::position::{position, Position, PositionTrait};
    use godai::models::block::{block, Block};
    use godai::models::owner::{owner, Owner};
    use godai::models::head::{head, Head, Element};
    use super::{game, IGameDispatcher, IGameDispatcherTrait};

    #[test]
    #[available_gas(60000000)]
    fn create_and_join() {
        let HEIGHT = 10_u32;
        let WIDTH = 10_u32;
        let MAX_BLOCKS = 10_u32;
        let MAX_PLAYERS = 10_u8;
        let START_TIME = 0_u64;
        let MAX_TIME = 0_u64;
        let JOIN_X = 6_u32;
        let JOIN_Y = 9_u32;

        let mut models = array![
            config::TEST_CLASS_HASH,
            tile::TEST_CLASS_HASH,
            head::TEST_CLASS_HASH,
            position::TEST_CLASS_HASH,
            block::TEST_CLASS_HASH,
            owner::TEST_CLASS_HASH
        ];
        let world = spawn_test_world(models);  

        // let player = contract_address_const::<0x123>();
        // starknet::testing::set_contract_address(player);
        // let (world, game_dispatcher) = setup();
        // let game_id = 0_u32;

        // game_dispatcher.create(HEIGHT, WIDTH, MAX_BLOCKS, MAX_PLAYERS, START_TIME, MAX_TIME);
        // game_dispatcher.join(game_id, JOIN_X, JOIN_Y);

        // let config = get!(world, game_id, Config);
        // assert(config.creator == player, 'Creator is not caller');
        // assert(config.width == WIDTH, 'Width is not 10');
        // assert(config.height == HEIGHT, 'Height is not 10');
        // assert(config.max_blocks == MAX_BLOCKS, 'Max blocks is not 10');

        // let owner = get!(world, (game_id, player), Owner);
        // assert(owner.player_id == player, 'Player id is not caller');

        // let block_id = owner.block_id;
        // let (head, position) = get!(world, (game_id, block_id), (Head, Position));
        // assert(head.owner_id == player, 'Head owner is not caller');
        // assert(position.x == JOIN_X, 'Position X is not 6');
        // assert(position.y == JOIN_Y, 'Position Y is not 9');

        // let tile = get!(world, (game_id, JOIN_X, JOIN_Y), Tile);
        // assert(tile.block_id == block_id, 'Tile block id is not block id');
    }
}
