mod move {
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
    use godai::systems::actions::{IActionsDispatcher, IActionsDispatcherTrait};
    use godai::tests::setup::setup::{create_game, SystemDispatchers, spawn_empty_link, PLAYER};

    #[test]
    #[available_gas(60000000)]
    fn move() {
        let (world, systems, game_id) = create_game();
        systems.game.join(game_id, 1, 1, 1);
        let block_id = spawn_empty_link(world, game_id, 1, 2, 1);

        systems.actions.move(game_id, 1, 0, 1);
    }
}
