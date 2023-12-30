mod move {
    use core::debug::PrintTrait;
    use starknet::{ContractAddress, contract_address_const};
    use starknet::class_hash::Felt252TryIntoClassHash;
    use starknet::Zeroable;
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
    fn consume_free_link() {
        let (world, systems, game_id) = create_game();
        systems.game.join(game_id, 1, 1, 1);

        let free_link = spawn_link(
            world,
            game_id,
            Element::None,
            Position { x: 2, y: 1, z: 0 },
            Zeroable::zero(),
            Zeroable::zero()
        );

        systems.actions.consume(game_id, 2, 1, 0);

        let mut owner = get!(world, (game_id, PLAYER()), (Owner));
        let head_link = get!(world, (game_id, owner.head_link), (Link));
        let tail_link = get!(world, (game_id, owner.tail_link), (Link));
        let head_cell = get!(world, (game_id, head_link.position.x, head_link.position.y, head_link.position.z), (Cell));
        let tail_cell = get!(world, (game_id, tail_link.position.x, tail_link.position.y, tail_link.position.z), (Cell));

        assert(owner.total_links == 2, 'Owner total links not updated');
        assert(owner.head_link == free_link, 'Owner head link not updated');
        assert(tail_link.next == head_link.link_id, 'Tail link next not updated');
        assert(head_cell.link_id == head_link.link_id, 'Head cell link id not updated');
        assert(tail_cell.link_id == tail_link.link_id, 'Tail cell link id not updated');
        assert(head_cell.player_id == PLAYER(), 'Head cell player id not updated');
        assert(tail_cell.player_id == PLAYER(), 'Tail cell player id not updated');

    }

}
