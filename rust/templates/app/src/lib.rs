//! Library half of the crate. Keeping the logic here (rather than in
//! `main.rs`) is what lets `benches/` and integration tests reach it.

use std::collections::HashMap;

use itertools::Itertools;
use jiff::Timestamp;
use rayon::prelude::*;
use serde::{Deserialize, Serialize};

/// A word and how often it occurred.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct WordCount {
    pub word: String,
    pub count: usize,
}

/// The result of one analysis run.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Report {
    pub generated_at: Timestamp,
    pub total_words: usize,
    pub distinct_words: usize,
    pub top: Vec<WordCount>,
}

/// Lower-case a token and strip punctuation. Returns `None` for tokens that
/// are nothing but punctuation.
fn normalize(token: &str) -> Option<String> {
    let cleaned: String = token
        .chars()
        .filter(|c| c.is_alphanumeric() || *c == '\'')
        .collect::<String>()
        .to_lowercase();

    if cleaned.is_empty() {
        None
    } else {
        Some(cleaned)
    }
}

/// Count word frequencies across `lines`.
///
/// Uses rayon's fold/reduce rather than a shared `Mutex<HashMap>`: each thread
/// builds a private map and they are merged pairwise at the end, so there is
/// no contention on the hot path.
pub fn count_words(lines: &[String]) -> HashMap<String, usize> {
    lines
        .par_iter()
        .fold(HashMap::new, |mut acc: HashMap<String, usize>, line| {
            for token in line.split_whitespace() {
                if let Some(word) = normalize(token) {
                    *acc.entry(word).or_insert(0) += 1;
                }
            }
            acc
        })
        .reduce(HashMap::new, |mut a, b| {
            for (word, count) in b {
                *a.entry(word).or_insert(0) += count;
            }
            a
        })
}

/// Build a report of the `n` most frequent words.
pub fn report(lines: &[String], n: usize) -> Report {
    let counts = count_words(lines);
    let total_words = counts.values().sum();
    let distinct_words = counts.len();

    let top = counts
        .into_iter()
        // Descending by count, then alphabetical so ties are deterministic.
        .sorted_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(&b.0)))
        .take(n)
        .map(|(word, count)| WordCount { word, count })
        .collect();

    Report {
        generated_at: Timestamp::now(),
        total_words,
        distinct_words,
        top,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn lines(text: &str) -> Vec<String> {
        text.lines().map(str::to_owned).collect()
    }

    #[test]
    fn normalizes_case_and_punctuation() {
        assert_eq!(normalize("Hello,"), Some("hello".to_owned()));
        assert_eq!(normalize("don't"), Some("don't".to_owned()));
        assert_eq!(normalize("---"), None);
    }

    #[test]
    fn counts_across_lines() {
        let counts = count_words(&lines("the cat\nthe hat\nTHE!"));
        assert_eq!(counts.get("the"), Some(&3));
        assert_eq!(counts.get("cat"), Some(&1));
    }

    #[test]
    fn report_is_sorted_and_truncated() {
        let rep = report(&lines("a a a b b c"), 2);
        assert_eq!(rep.total_words, 6);
        assert_eq!(rep.distinct_words, 3);
        assert_eq!(rep.top.len(), 2);
        assert_eq!(rep.top[0].word, "a");
        assert_eq!(rep.top[1].word, "b");
    }

    #[test]
    fn report_round_trips_through_json() {
        let rep = report(&lines("alpha beta"), 5);
        let encoded = serde_json::to_string(&rep).expect("serialize");
        let decoded: Report = serde_json::from_str(&encoded).expect("deserialize");
        assert_eq!(decoded.top, rep.top);
    }
}
