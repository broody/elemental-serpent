mod move {
    use core::debug::PrintTrait;
    use starknet::{ContractAddress, contract_address_const};
    use starknet::class_hash::Felt252TryIntoClassHash;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    use godai::models::config::{config, Config};
    use godai::models::cell::Cell;
    use godai::models::owner::Owner;
    use godai::models::link::{Link, Element, Position, PositionTrait};

    use godai::systems::game::{IGameDispatcher, IGameDispatcherTrait};
    use godai::systems::actions::{IActionsDispatcher, IActionsDispatcherTrait};
    use godai::tests::setup::setup::{create_game, SystemDispatchers, spawn_link, PLAYER};

    #[test]
    #[available_gas(100000000)]
    fn move_after_join() {
        let (world, systems, game_id) = create_game();
        systems.game.join(game_id, 1, 1, 1);
        systems.actions.move(game_id, 1, 0, 1);

        let owner = get!(world, (game_id, PLAYER()), (Owner));
        let link = get!(world, (game_id, owner.head_link), (Link));
        let target_cell = get!(world, (game_id, 1, 0, 1), (Cell));
        let prev_cell = get!(world, (game_id, 1, 1, 1), (Cell));

        assert(target_cell.link_id == owner.head_link, 'Target cell id not updated');
        assert(prev_cell.link_id == 0, 'Previous cell id not zeroed');
        assert(owner.head_link == owner.tail_link, 'Head and tail block not equal');
        assert(link.next == 0, 'Link next not zeroed');
    }

    #[test]
    #[available_gas(100000000)]
    fn move_with_two_links() {
        let (world, systems, game_id) = create_game();
        systems.game.join(game_id, 1, 1, 0);

        let mut owner = get!(world, (game_id, PLAYER()), (Owner));
        let tail_link = spawn_link(
            world, game_id, Element::None, Position { x: 2, y: 1, z: 0 }, PLAYER(), owner.head_link
        );
        owner.total_links += 1;
        owner.tail_link = tail_link;
        set!(world, (owner));

        // move up
        systems.actions.move(game_id, 1, 2, 0);
        let mut owner = get!(world, (game_id, PLAYER()), (Owner));
        let head_link = get!(world, (game_id, owner.head_link), (Link));
        let tail_link = get!(world, (game_id, owner.tail_link), (Link));

        assert(
            head_link.position == Position { x: 1, y: 2, z: 0 }, 'Head link position not updated'
        );
        assert(
            tail_link.position == Position { x: 1, y: 1, z: 0 }, 'Tail link position not updated'
        );

        // move Right
        systems.actions.move(game_id, 2, 2, 0);
        let mut owner = get!(world, (game_id, PLAYER()), (Owner));
        let head_link = get!(world, (game_id, owner.head_link), (Link));
        let tail_link = get!(world, (game_id, owner.tail_link), (Link));

        assert(
            head_link.position == Position { x: 2, y: 2, z: 0 }, 'Head link position not updated'
        );
        assert(
            tail_link.position == Position { x: 1, y: 2, z: 0 }, 'Tail link position not updated'
        );
    }
}
