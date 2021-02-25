/// nif: apply_count/2
const std = @import("std");

test "apply_count" {
    std.testing.expect(apply_count(1, 2) == 3);
}

fn apply_count(count: i64, change: i64) i64 {
    std.debug.print("apply_count in zig {} + {} = {}\n", .{ count, change, count + change });
    return count + change;
}
