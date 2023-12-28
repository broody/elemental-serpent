mod move {
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
    use godai::tests::setup::setup::{create_game, SystemDispatchers, spawn_empty_block, PLAYER};

    #[test]
    #[available_gas(60000000)]
    fn move() {
        let JOIN_X = 6_u32;
        let JOIN_Y = 9_u32;

        let (world, systems, game_id) = create_game();
        systems.game.join(game_id, JOIN_X, JOIN_Y);

        let block_id = spawn_empty_block(world, game_id, 1, 1);
    }
}
