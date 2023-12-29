mod create {
    use core::debug::PrintTrait;
    use starknet::{ContractAddress, contract_address_const};
    use starknet::class_hash::Felt252TryIntoClassHash;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    use godai::models::config::{config, Config};
    use godai::models::cell::Cell;
    use godai::models::block::{owner::Owner, link::Link, position::{Position, PositionTrait}};

    use godai::systems::game::{IGameDispatcher, IGameDispatcherTrait};
    use godai::tests::setup::setup::{create_game, SystemDispatchers, PLAYER};

    #[test]
    #[available_gas(60000000)]
    fn join() {
        let JOIN_X = 1_u32;
        let JOIN_Y = 2_u32;
        let JOIN_Z = 3_u32;

        let (world, systems, game_id) = create_game();
        systems.game.join(game_id, JOIN_X, JOIN_Y, JOIN_Z);

        let owner = get!(world, (game_id, PLAYER()), Owner);
        assert(owner.player_id == PLAYER(), 'Player id is not caller');

        let link = get!(world, (game_id, owner.head_block), Link);
        assert(link.position.x == JOIN_X, 'Link X is not 1');
        assert(link.position.y == JOIN_Y, 'Link Y is not 2');
        assert(link.position.z == JOIN_Z, 'Link Z is not 3');

        let cell = get!(world, (game_id, JOIN_X, JOIN_Y, JOIN_Z), Cell);
        assert(cell.block_id == owner.head_block, 'cell block id is not block id');
        assert(cell.x == JOIN_X, 'Cell X is not 1');
        assert(cell.y == JOIN_Y, 'Cell Y is not 2');
        assert(cell.z == JOIN_Z, 'Cell Z is not 3');
    }
}
