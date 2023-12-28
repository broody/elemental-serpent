mod create {
    use core::debug::PrintTrait;
    use starknet::{ContractAddress, contract_address_const};
    use starknet::class_hash::Felt252TryIntoClassHash;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    use godai::models::config::{config, Config};
    use godai::models::owner::Owner;
    use godai::models::cell::Cell;
    use godai::models::block::{head::Head, link::Link, position::{Position, PositionTrait}};

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

        let block_id = owner.block_id;
        let head = get!(world, (game_id, block_id), (Head));
        assert(head.owner_id == PLAYER(), 'Head owner is not caller');
        assert(head.position.x == JOIN_X, 'Position X is not 1');
        assert(head.position.y == JOIN_Y, 'Position Y is not 2');
        assert(head.position.z == JOIN_Z, 'Position Z is not 3');

        let cell = get!(world, (game_id, JOIN_X, JOIN_Y, JOIN_Z), Cell);
        assert(cell.block_id == block_id, 'cell block id is not block id');
        assert(cell.x == JOIN_X, 'Cell X is not 1');
        assert(cell.y == JOIN_Y, 'Cell Y is not 2');
        assert(cell.z == JOIN_Z, 'Cell Z is not 3');
    }
}
