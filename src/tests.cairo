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
use godai::systems::{game, IGameDispatcher, IGameDispatcherTrait};

fn setup() -> (IWorldDispatcher, IGameDispatcher) {
    let mut models = array![
        config::TEST_CLASS_HASH,
        tile::TEST_CLASS_HASH,
        head::TEST_CLASS_HASH,
        position::TEST_CLASS_HASH,
        block::TEST_CLASS_HASH,
        owner::TEST_CLASS_HASH
    ];
    let world = spawn_test_world(models);  
    let game_dispatcher = IGameDispatcher {
        contract_address: deploy_with_world_address(game::TEST_CLASS_HASH, world)
    };

    (world, game_dispatcher)
}