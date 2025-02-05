use std::ffi::{c_char, CStr};

/// Parses a math expression (e.g., "5+2") and returns the result.
/// Supports `+`, `-`, `*`, and `/` (integer division).
#[no_mangle]
pub extern "C" fn calculate(expression: *const c_char) -> i32 {
    // Convert C string to Rust string
    let c_str = unsafe { CStr::from_ptr(expression) };
    let expr = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => return 0, // Return 0 if there's an error
    };

    // Simple parsing (supports "a+b", "a-b", "a*b", "a/b")
    let tokens: Vec<&str> = expr.split_whitespace().collect();
    if tokens.len() != 3 {
        return 0;
    }

    let left: i32 = tokens[0].parse().unwrap_or(0);
    let op = tokens[1];
    let right: i32 = tokens[2].parse().unwrap_or(0);

    match op {
        "+" => left + right,
        "-" => left - right,
        "*" => left * right,
        "/" => {
            if right != 0 {
                left / right
            } else {
                0
            }
        } // Prevent division by zero
        _ => 0,
    }
}
