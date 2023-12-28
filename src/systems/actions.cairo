use dojo::world::IWorldDispatcher;

#[derive(Serde, Copy, Drop)]
enum Direction {
    Up: (),
    Down: (),
    Left: (),
    Right: (),
}

#[starknet::interface]
trait IActions<TContractState> {
    fn move(self: @TContractState, game_id: u32, x: u32, y: u32, z: u32);
//fn consume(self: @TContractState, game_id: u32, x: u32, y: u32, z: u32);
}

#[dojo::contract]
mod actions {
    use core::debug::PrintTrait;
    use core::traits::Into;
    use core::box::BoxTrait;
    use core::array::ArrayTrait;

    use starknet::{ContractAddress, get_caller_address};
    use godai::models::config::{ConfigTrait, Config};
    use godai::models::owner::Owner;
    use godai::models::cell::Cell;
    use godai::models::block::{head::Head, link::Link, position::{Position, PositionTrait}};
    use super::IActions;
    use super::Direction;

    #[external(v0)]
    fn move(self: @ContractState, game_id: u32, x: u32, y: u32, z: u32) {
        let world = self.world_dispatcher.read();
        let player_id = get_caller_address();

        let mut target_cell = get!(world, (game_id, x, y, z), (Cell));
        assert(target_cell.block_id == 0, 'Cell is not empty');

        let owner = get!(world, (game_id, player_id), (Owner));
        let (mut head_position, mut head) = get!(
            world, (game_id, owner.block_id), (Position, Head)
        );
    let mut head_cell = get!(world, (game_id, head_position.x, head_position.y, head_position.z), (Cell));
    // assert(head_position.is_adjacent(x, y), 'Target is not adjacent to head');

    // get the tail and set its position to the head
    // let tail_link = tail(ctx, game_id, head.prev);
    // let mut tail_position = get !(world, (game_id, tail_link.block_id), (Position));
    // let mut tail_tile = get !(world, (game_id, tail_position.x, tail_position.y), (Tile));
    // tail_position.x = head_position.x;
    // tail_position.y = head_position.y;
    // tail_tile.block_id = 0;

    // // get new tail and zero out prev pointer
    // let mut new_tail = get !(world, (game_id, tail_link.next), (Link));
    // new_tail.prev = 0;

    // // set head position to target
    // head_position.x = target_x;
    // head_position.y = target_y;
    // target_tile.block_id = head.block_id;

    }

    // #[external(v0)]
    // fn consume(self: @ContractState, game_id: u32, target_x: u32, target_y: u32) {
    //     let world = self.world_dispatcher.read();
    //     let player_id = get_caller_address();

    //     let config = get!(world, game_id, (Config));
    //     config.check();

    //     let mut tile = get!(world, (game_id, target_x, target_y), (Tile));
    //     assert(tile.block_id != 0, 'Nothing at target position');

    //     let owner = get!(world, (game_id, player_id), (Owner));
    //     let (mut head_position, mut head) = get!(
    //         world, (game_id, owner.block_id), (Position, Head)
    //     );
    //     assert(head_position.is_adjacent(target_x, target_y), 'Target is not adjacent to head');

    //     // can only consume headless nodes
    //     let (mut target_block, mut target_position) = get!(
    //         world, (game_id, tile.block_id), (Block, Position)
    //     );
    //     if !is_headless(world, game_id, target_block) {
    //         return;
    //     }

    //     target_block.next = head.block_id;
    //     target_block.prev = head.prev;

    //     head.prev = target_block.block_id;
    //     head.total_blocks += 1;

    //     tile.block_id = head.block_id;

    //     // swap target_position and head_position
    //     target_position.x = head_position.x;
    //     target_position.y = head_position.y;
    //     head_position.x = tile.x;
    //     head_position.y = tile.y;

    //     set!(world, (head, head_position, tile, target_block, target_position));
    // }

    fn is_headless(world: IWorldDispatcher, game_id: u32, mut link: Link) -> bool {
        loop {
            let (next_link, head) = get!(world, (game_id, link.next), (Link, Head));

            if head.total_links != 0 {
                break false;
            }

            if next_link.next == 0 {
                break true;
            }

            link = next_link;
        }
    }

    fn tail(world: IWorldDispatcher, game_id: u32, mut link: Link) -> Link {
        loop {
            let prev_link = get!(world, (game_id, link.prev).into(), (Link));

            if prev_link.prev == 0 {
                break link;
            }

            link = prev_link;
        }
    }
}
