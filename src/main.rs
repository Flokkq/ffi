extern "C" {
    fn add(a: i32, b: i32) -> i32;
}

fn main() {
    let result = unsafe { add(2, 3) };
    println!("2 + 3 = {}", result);
}
