mod constants;

mod systems {
    mod actions;
    mod game;
}

mod models {
    mod config;
    mod head;
    mod owner;
    mod block;
    mod tile;
    mod position;
}

#[cfg(test)]
mod tests {
    mod setup;
    mod join;
    mod move;
}
