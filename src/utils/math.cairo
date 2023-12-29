use starknet::Zeroable;

trait MathTrait<T> {
    fn abs_sub(self: T, value: T) -> T;
}

impl MathImpl<
    T,
    +PartialOrd<T>,
    +Add<T>,
    +AddEq<T>,
    +Sub<T>,
    +SubEq<T>,
    +Zeroable<T>,
    +Into<T, u128>,
    +TryInto<u128, T>,
    +Copy<T>,
    +Drop<T>
> of MathTrait<T> {
    fn abs_sub(self: T, value: T) -> T {
        if self > value {
            self - value
        } else {
            value - self
        }
    }
}

impl MathImplU8 = MathImpl<u8>;
impl MathImplU16 = MathImpl<u16>;
impl MathImplU32 = MathImpl<u32>;
impl MathImplU64 = MathImpl<u64>;
impl MathImplU128 = MathImpl<u128>;
impl MathImplUsize = MathImpl<usize>;
