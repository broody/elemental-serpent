mod constants;

mod systems {
    mod actions;
    mod game;
}

mod models {
    mod config;
    mod cell;
    mod block {
        mod owner;
        mod link;
        mod position;
    }
}

mod utils {
    mod math;
}

#[cfg(test)]
mod tests {
    mod setup;
    mod join;
    mod move;
}
