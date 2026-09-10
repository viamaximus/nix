use std::hint::black_box;

use criterion::{Criterion, criterion_group, criterion_main};

use {{crate_name}}::{count_words, report};

/// Deterministic synthetic corpus, so runs are comparable across machines.
fn corpus(lines: usize) -> Vec<String> {
    let vocab = [
        "alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta",
    ];

    (0..lines)
        .map(|i| {
            (0..12)
                .map(|j| vocab[(i * 7 + j * 3) % vocab.len()])
                .collect::<Vec<_>>()
                .join(" ")
        })
        .collect()
}

fn bench_word_count(c: &mut Criterion) {
    let mut group = c.benchmark_group("word_count");

    for size in [100usize, 2_000, 20_000] {
        let data = corpus(size);

        group.throughput(criterion::Throughput::Elements(size as u64));
        group.bench_function(format!("count_words/{size}"), |b| {
            b.iter(|| count_words(black_box(&data)))
        });
        group.bench_function(format!("report_top10/{size}"), |b| {
            b.iter(|| report(black_box(&data), 10))
        });
    }

    group.finish();
}

criterion_group!(benches, bench_word_count);
criterion_main!(benches);
