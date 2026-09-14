import RegexBuilder

/**
 Builds a regex matching any one of `alternatives`, tried in the order given.

 `ChoiceOf` only accepts a statically-known list of alternatives, so a run-time list is
 folded with the same builder `ChoiceOf` uses. Each alternative is matched literally,
 which keeps regex metacharacters in the alternatives from being interpreted.

 - Parameter alternatives: The strings to match, in the order the engine should try them.
 - Returns: A regex matching the first alternative that matches.
 */
func regexAlternation(of alternatives: [String]) -> Regex<Substring> {
  guard let firstAlternative = alternatives.first else {
    preconditionFailure("A regex alternation needs at least one alternative")
  }
  return alternatives.dropFirst().reduce(Regex { firstAlternative }) { alternation, alternative in
    AlternationBuilder.buildPartialBlock(accumulated: alternation, next: alternative).regex
  }
}
