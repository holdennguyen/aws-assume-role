use aws_assume_role::config::{Config, RoleConfig};
use criterion::{black_box, criterion_group, criterion_main, Criterion};
use tempfile::TempDir;

fn benchmark_config_operations(c: &mut Criterion) {
    c.bench_function("config_creation", |b| {
        b.iter(|| {
            let config = Config::new();
            black_box(config);
        });
    });

    c.bench_function("role_addition", |b| {
        b.iter(|| {
            let mut config = Config::new();
            let role = RoleConfig {
                name: "test-role".to_string(),
                role_arn: "arn:aws:iam::123456789012:role/TestRole".to_string(),
                account_id: "123456789012".to_string(),
                source_profile: None,
                session_duration: Some(3600),
            };
            config.add_role(black_box(role));
            black_box(config);
        });
    });

    let mut config = Config::new();
    for i in 0..100 {
        let role = RoleConfig {
            name: format!("test-role-{}", i),
            role_arn: format!("arn:aws:iam::123456789012:role/TestRole{}", i),
            account_id: "123456789012".to_string(),
            source_profile: None,
            session_duration: Some(3600),
        };
        config.add_role(role);
    }

    c.bench_function("role_lookup", |b| {
        b.iter(|| {
            let role = config.get_role(black_box("test-role-50"));
            black_box(role);
        });
    });

    c.bench_function("config_serialization", |b| {
        b.iter(|| {
            let json = serde_json::to_string(&config).unwrap();
            black_box(json);
        });
    });

    let json = serde_json::to_string(&config).unwrap();
    c.bench_function("config_deserialization", |b| {
        b.iter(|| {
            let config: Config = serde_json::from_str(black_box(&json)).unwrap();
            black_box(config);
        });
    });
}

fn benchmark_config_io(c: &mut Criterion) {
    let temp_dir = TempDir::new().unwrap();
    std::env::set_var("HOME", temp_dir.path());

    let mut config = Config::new();
    for i in 0..10 {
        let role = RoleConfig {
            name: format!("benchmark-role-{}", i),
            role_arn: format!("arn:aws:iam::123456789012:role/BenchmarkRole{}", i),
            account_id: "123456789012".to_string(),
            source_profile: None,
            session_duration: Some(3600),
        };
        config.add_role(role);
    }

    c.bench_function("config_save", |b| {
        b.iter(|| {
            config.save().unwrap();
        });
    });

    c.bench_function("config_load", |b| {
        b.iter(|| {
            let loaded_config = Config::load().unwrap();
            black_box(loaded_config);
        });
    });
}

fn benchmark_role_operations(c: &mut Criterion) {
    c.bench_function("role_creation", |b| {
        b.iter(|| {
            let role = RoleConfig {
                name: black_box("benchmark-role".to_string()),
                role_arn: black_box("arn:aws:iam::123456789012:role/BenchmarkRole".to_string()),
                account_id: black_box("123456789012".to_string()),
                source_profile: None,
                session_duration: Some(3600),
            };
            black_box(role);
        });
    });

    let mut config = Config::new();

    c.bench_function("multiple_role_additions", |b| {
        b.iter(|| {
            for i in 0..10 {
                let role = RoleConfig {
                    name: format!("temp-role-{}", i),
                    role_arn: format!("arn:aws:iam::123456789012:role/TempRole{}", i),
                    account_id: "123456789012".to_string(),
                    source_profile: None,
                    session_duration: Some(3600),
                };
                config.add_role(role);
            }

            // Clean up for next iteration
            for i in 0..10 {
                config.remove_role(&format!("temp-role-{}", i));
            }
        });
    });
}

criterion_group!(
    benches,
    benchmark_config_operations,
    benchmark_config_io,
    benchmark_role_operations
);
criterion_main!(benches);
