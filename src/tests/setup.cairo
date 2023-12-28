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
    use godai::models::tile::{tile, Tile};
    use godai::models::position::{position, Position, PositionTrait};
    use godai::models::block::{block, Block};
    use godai::models::owner::{owner, Owner};
    use godai::models::head::{head, Head, Element};
    use godai::systems::game::{game, IGameDispatcher, IGameDispatcherTrait};

    fn PLAYER() -> ContractAddress {
        contract_address_const::<'PLAYER'>()
    }

    #[derive(Copy, Clone, Drop)]
    struct SystemDispatchers {
        game: IGameDispatcher
    }

    fn spawn_world() -> (IWorldDispatcher, SystemDispatchers) {
        let mut models = array![
            config::TEST_CLASS_HASH,
            tile::TEST_CLASS_HASH,
            head::TEST_CLASS_HASH,
            position::TEST_CLASS_HASH,
            block::TEST_CLASS_HASH,
            owner::TEST_CLASS_HASH,
        ];
        let world = spawn_test_world(models);
        let systems = SystemDispatchers {
            game: IGameDispatcher {
                contract_address: world
                    .deploy_contract('game', game::TEST_CLASS_HASH.try_into().unwrap())
            }
        };

        (world, systems)
    }

    fn create_game() -> (IWorldDispatcher, SystemDispatchers, u32) {
        let HEIGHT = 10_u32;
        let WIDTH = 10_u32;
        let MAX_BLOCKS = 10_u32;
        let MAX_PLAYERS = 10_u8;
        let START_TIME = 0_u64;
        let MAX_TIME = 0_u64;

        starknet::testing::set_contract_address(PLAYER());
        let (world, systems) = spawn_world();
        let game_id = systems
            .game
            .create(HEIGHT, WIDTH, MAX_BLOCKS, MAX_PLAYERS, START_TIME, MAX_TIME);

        let config = get!(world, game_id, Config);
        assert(config.creator == PLAYER(), 'Creator is not caller');
        assert(config.width == WIDTH, 'Width is not 10');
        assert(config.height == HEIGHT, 'Height is not 10');
        assert(config.max_blocks == MAX_BLOCKS, 'Max blocks is not 10');

        (world, systems, game_id)
    }

    fn spawn_empty_block(world: IWorldDispatcher, game_id: u32, x: u32, y: u32,) -> u32 {
        let tile = get!(world, (game_id, x, y), Tile);
        assert(tile.block_id == Zeroable::zero(), 'Tile is not empty');

        let block_id = world.uuid();
        set!(
            world,
            (Block { game_id, block_id, next: 0, prev: 0, }, Tile { game_id, block_id, x, y })
        );

        block_id
    }
}
