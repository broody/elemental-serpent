mod constants;

mod systems {
    mod actions;
    mod game;
}

mod models {
    mod config;
    mod owner;
    mod cell;
    mod link;
}

mod utils {
    mod math;
}

#[cfg(test)]
mod tests {
    mod setup;
    mod join;
    mod move;
    mod consume;
}
