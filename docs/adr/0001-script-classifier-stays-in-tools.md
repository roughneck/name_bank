# 1. The script classifier stays in tools/

Date: 2026-08-08

## Status

Accepted

## Context

`ScriptClassifier` maps a name to a writing system by Unicode code-point range.
It lives in `tools/`, which the gemspec does not package. Two things in the repo
use it:

- `tools/split_scripts.rb`, the build-time step that splits a mixed-script pool
  into a Latin pool and a native-script pool.
- `spec/name_bank_real_data_spec.rb`, which verifies that the committed data
  honours that split — the Russian native pool is all Cyrillic, the German pool
  is free of non-Latin noise, and so on.

That spec reaches out of `spec/` into `tools/` with a `require_relative`. It
reads like a misplaced module: a spec verifying *shipped data* depends on code
that is *not shipped*. An architecture review will keep proposing the obvious
fix — move the classifier to `lib/name_bank/script.rb` so both callers, and the
runtime, share one home for the concept.

We considered exactly that and rejected it.

## Decision

`ScriptClassifier` stays in `tools/`. Nothing in `lib/` classifies names.

The country-to-native-script table (`SplitScripts::NATIVE`) stays in
`tools/split_scripts.rb` alongside it.

## Consequences

Three facts make the move a net loss:

1. **Nothing in `lib/` would call it.** `NameBank#scripts(country:)` answers
   "which script forms does this country offer", and derives that from the
   presence of `*_native` keys — three hash lookups. It deliberately does *not*
   classify: the build pipeline already guarantees the invariant, and
   re-deriving it at runtime would mean walking up to 4500 names per call.
   Moving the classifier to `lib/` would ship code into every consuming project
   that the gem itself never executes.

2. **`Script.of(name)` is not a use case this gem serves.** name_bank generates
   names; it does not analyse them. A public classifier would be an interface we
   invented a user for.

3. **`SplitScripts::NATIVE` has a single caller, in its own file.** Relocating
   it would spread knowledge rather than concentrate it.

The apparent problem was a word collision, not a design fault. "Script" as a
*writing system* (a build-time property of a name string) and "script" as a
*selectable pool form* (`:latin` / `:native`, a runtime property of a country)
are different questions that share a noun. `CONTEXT.md` already separated them;
the review conflated them.

Cost we accept: a spec keeps a `require_relative` into `tools/`. That is
ordinary in a Ruby project — neither `spec/` nor `tools/` is packaged, so the
dependency never leaves the repo.

Revisit this if a caller-facing reason to classify a name appears, or if
`scripts(country:)` ever needs to verify rather than trust the data.
