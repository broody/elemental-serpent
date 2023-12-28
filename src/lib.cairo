mod constants;

mod systems {
    mod actions;
    mod game;
}

mod models {
    mod config;
    mod owner;
    mod cell;
    mod block {
        mod head;
        mod link;
        mod position;
    }
}

#[cfg(test)]
mod tests {
    mod setup;
    mod join;
    mod move;
}
