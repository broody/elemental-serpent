mod setup {
    // Starknet imports

    use starknet::{ContractAddress, contract_address_const};
    use starknet::testing::{set_contract_address, set_transaction_hash};
    use starknet::class_hash::Felt252TryIntoClassHash;
    use starknet::Zeroable;

    // Dojo imports

    use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
    use dojo::test_utils::{spawn_test_world, deploy_with_world_address};

    // Internal imports

    use godai::models::config::{config, Config};
    use godai::models::cell::{cell, Cell};
    use godai::models::owner::{owner, Owner};
    use godai::models::link::{
        link, Link, Position, PositionTrait
    };
    use godai::systems::game::{game, IGameDispatcher, IGameDispatcherTrait};
    use godai::systems::actions::{actions, IActionsDispatcher, IActionsDispatcherTrait};

    fn PLAYER() -> ContractAddress {
        contract_address_const::<'PLAYER'>()
    }

    #[derive(Copy, Clone, Drop)]
    struct SystemDispatchers {
        game: IGameDispatcher,
        actions: IActionsDispatcher,
    }

    fn spawn_world() -> (IWorldDispatcher, SystemDispatchers) {
        let mut models = array![
            config::TEST_CLASS_HASH,
            cell::TEST_CLASS_HASH,
            owner::TEST_CLASS_HASH,
            link::TEST_CLASS_HASH,
        ];
        let world = spawn_test_world(models);
        let systems = SystemDispatchers {
            game: IGameDispatcher {
                contract_address: world
                    .deploy_contract('game', game::TEST_CLASS_HASH.try_into().unwrap())
            },
            actions: IActionsDispatcher {
                contract_address: world
                    .deploy_contract('actions', actions::TEST_CLASS_HASH.try_into().unwrap())
            },
        };

        (world, systems)
    }

    fn create_game() -> (IWorldDispatcher, SystemDispatchers, u32) {
        let HEIGHT = 10_u32;
        let WIDTH = 10_u32;
        let DEPTH = 10_u32;
        let MAX_LINKS = 10_u32;
        let MAX_PLAYERS = 10_u8;
        let START_TIME = 0_u64;
        let MAX_TIME = 0_u64;

        starknet::testing::set_contract_address(PLAYER());
        let (world, systems) = spawn_world();
        let game_id = systems
            .game
            .create(HEIGHT, WIDTH, DEPTH, MAX_LINKS, MAX_PLAYERS, START_TIME, MAX_TIME);

        let config = get!(world, game_id, Config);
        assert(config.creator == PLAYER(), 'Creator is not caller');
        assert(config.width == WIDTH, 'Width is not 10');
        assert(config.height == HEIGHT, 'Height is not 10');
        assert(config.max_links == MAX_LINKS, 'Max blocks is not 10');

        (world, systems, game_id)
    }

    fn spawn_link(world: IWorldDispatcher, game_id: u32, position: Position, next: u32) -> u32 {
        let cell = get!(world, (game_id, position.x, position.y, position.z), Cell);
        assert(cell.link_id == Zeroable::zero(), 'Cell is not empty');

        let link_id = world.uuid();
        set!(
            world,
            (
                Link { game_id, link_id, next, position },
                Cell { game_id, link_id, x: position.x, y: position.y, z: position.z, player_id: PLAYER() }
            )
        );

        link_id
    }
}
