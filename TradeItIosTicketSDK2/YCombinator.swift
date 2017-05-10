// YCombinator: this allows us to have self referencing/recursive closures.
// See http://mvanier.livejournal.com/2897.html for the explanation.
func YCombinator<In, Out>(_ f: @escaping (@escaping (In) -> Out) -> ((In) -> Out)) -> ((In) -> Out) {
    return { x in
        f(YCombinator(f))(x)
    }
}
