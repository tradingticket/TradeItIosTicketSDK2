infix operator ??=
func ??= <T>(left: inout T?, right: T) {
    left = left ?? right
}
