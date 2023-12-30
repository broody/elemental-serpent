use dojo::world::IWorldDispatcher;

#[starknet::interface]
trait IActions<TContractState> {
    fn move(self: @TContractState, game_id: u32, x: u32, y: u32, z: u32);
    fn consume(self: @TContractState, game_id: u32, x: u32, y: u32, z: u32);
}

#[dojo::contract]
mod actions {
    use core::debug::PrintTrait;
    use core::traits::Into;
    use core::box::BoxTrait;
    use core::array::ArrayTrait;

    use starknet::Zeroable;
    use starknet::{ContractAddress, get_caller_address};
    use godai::models::config::{ConfigTrait, Config};
    use godai::models::cell::Cell;
    use godai::models::owner::Owner;
    use godai::models::link::{Link, Position, PositionTrait};
    use super::IActions;

    #[external(v0)]
    fn move(self: @ContractState, game_id: u32, x: u32, y: u32, z: u32) {
        let world = self.world_dispatcher.read();
        let player_id = get_caller_address();

        //  let config = get!(world, game_id, (Config));
        //  config.check();

        let mut target_cell = get!(world, (game_id, x, y, z), (Cell));
        assert(target_cell.player_id == Zeroable::zero(), 'Cell is not empty');

        let mut owner = get!(world, (game_id, player_id), (Owner));
        let mut head_link = get!(world, (game_id, owner.head_link), (Link));
        let mut tail_link = get!(world, (game_id, owner.tail_link), (Link));
        let mut tail_cell = get!(
            world,
            (game_id, tail_link.position.x, tail_link.position.y, tail_link.position.z),
            (Cell)
        );
        assert(head_link.position.is_adjacent(x, y, z), 'Target is not adjacent to head');

        // update cells
        target_cell.link_id = tail_link.link_id;
        tail_cell.link_id = Zeroable::zero();
        tail_cell.player_id = Zeroable::zero();

        // update new head position
        tail_link.position.x = x;
        tail_link.position.y = y;
        tail_link.position.z = z;

        // handle case when player only has one link (just joined game)
        if owner.total_links == 1 {
            set!(world, (head_link, target_cell, tail_cell));
            return;
        }

        // update owner head and tail blocks
        owner.head_link = tail_link.link_id;
        owner.tail_link = tail_link.next;

        // tail is the new head
        head_link.next = tail_link.link_id;
        tail_link.next = 0;

        set!(world, (owner, head_link, tail_link, target_cell, tail_cell));
    }

    #[external(v0)]
    fn consume(self: @ContractState, game_id: u32, x: u32, y: u32, z: u32) {
        let world = self.world_dispatcher.read();
        let player_id = get_caller_address();

        // let config = get!(world, game_id, (Config));
        // config.check();

        let mut owner = get!(world, (game_id, player_id), (Owner));
        let mut head_link = get!(world, (game_id, owner.head_link), (Link));
        assert(head_link.position.is_adjacent(x, y, z), 'Target is not adjacent to head');

        // can only consume free links
        let mut target_cell = get!(world, (game_id, x, y, z), (Cell));
        assert(target_cell.player_id == Zeroable::zero(), 'Cell is occupied');
        assert(target_cell.link_id != Zeroable::zero(), 'Cell is not linked');

        let mut target_link = get!(world, (game_id, target_cell.link_id), (Link));
        assert(is_headless(world, game_id, target_link), 'Target is not headless');

        target_link.next = Zeroable::zero();
        head_link.next = target_link.link_id;
        target_cell.player_id = player_id;

        owner.head_link = target_link.link_id;
        owner.total_links += 1;

        set!(world, (owner, head_link, target_link, target_cell));
    }

    fn is_headless(world: IWorldDispatcher, game_id: u32, mut link: Link) -> bool {
        loop {
            if link.next == 0 {
                let cell = get!(
                    world, (game_id, link.position.x, link.position.y, link.position.z), (Cell)
                );
                let owner = get!(world, (game_id, cell.player_id), (Owner));

                if cell.link_id == owner.head_link {
                    break false;
                }

                break true;
            }

            link = get!(world, (game_id, link.next), (Link));
        }
    }
}
