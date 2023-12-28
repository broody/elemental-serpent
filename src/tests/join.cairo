mod create {
    use core::debug::PrintTrait;
    use starknet::{ContractAddress, contract_address_const};
    use starknet::class_hash::Felt252TryIntoClassHash;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    use godai::models::config::{config, Config};
    use godai::models::tile::{tile, Tile};
    use godai::models::position::{position, Position, PositionTrait};
    use godai::models::block::{block, Block};
    use godai::models::owner::{owner, Owner};
    use godai::models::head::{head, Head, Element};
    use godai::systems::game::{IGameDispatcher, IGameDispatcherTrait};
    use godai::tests::setup::setup::{create_game, SystemDispatchers, PLAYER};

    #[test]
    #[available_gas(60000000)]
    fn join() {
        let JOIN_X = 6_u32;
        let JOIN_Y = 9_u32;

        let (world, systems, game_id) = create_game();
        systems.game.join(game_id, JOIN_X, JOIN_Y);

        let owner = get!(world, (game_id, PLAYER()), Owner);
        assert(owner.player_id == PLAYER(), 'Player id is not caller');

        let block_id = owner.block_id;
        let (head, position) = get!(world, (game_id, block_id), (Head, Position));
        assert(head.owner_id == PLAYER(), 'Head owner is not caller');
        assert(position.x == JOIN_X, 'Position X is not 6');
        assert(position.y == JOIN_Y, 'Position Y is not 9');

        let tile = get!(world, (game_id, JOIN_X, JOIN_Y), Tile);
        assert(tile.block_id == block_id, 'Tile block id is not block id');
        assert(tile.x == JOIN_X, 'Tile X is not 6');
        assert(tile.y == JOIN_Y, 'Tile Y is not 9');
    }
}
