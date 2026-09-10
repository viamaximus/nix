use std::path::{Path, PathBuf};

use clap::{Parser, Subcommand};
use color_eyre::eyre::{Result, WrapErr, eyre};
use command_run::Command;
use tokio::io::AsyncReadExt;

use {{crate_name}}::report;

#[derive(Debug, Parser)]
#[command(name = env!("CARGO_PKG_NAME"), version, about = env!("CARGO_PKG_DESCRIPTION"))]
struct Cli {
    /// Emit machine-readable JSON instead of a table.
    #[arg(long, global = true)]
    json: bool,

    #[command(subcommand)]
    command: Cmd,
}

#[derive(Debug, Subcommand)]
enum Cmd {
    /// Count word frequencies in a file.
    Words {
        /// Input file; `-` reads standard input.
        #[arg(default_value = "-")]
        path: PathBuf,

        /// How many entries to report.
        #[arg(short = 'n', long, default_value_t = 10, env = "TOP_N")]
        top: usize,
    },

    /// Print the git revision of the working tree.
    Rev,
}

#[tokio::main]
async fn main() -> Result<()> {
    // Installs the panic and error report handlers. Must come before any
    // fallible work so those errors get the pretty formatting too.
    color_eyre::install()?;

    let cli = Cli::parse();

    match cli.command {
        Cmd::Words { path, top } => {
            let text = read_input(&path).await?;
            let lines: Vec<String> = text.lines().map(str::to_owned).collect();
            let rep = report(&lines, top);

            if cli.json {
                println!("{}", serde_json::to_string_pretty(&rep)?);
            } else {
                println!(
                    "{} words, {} distinct, generated {}",
                    rep.total_words, rep.distinct_words, rep.generated_at
                );
                for entry in &rep.top {
                    println!("{:>8}  {}", entry.count, entry.word);
                }
            }
        }

        Cmd::Rev => println!("{}", git_rev()?),
    }

    Ok(())
}

async fn read_input(path: &Path) -> Result<String> {
    if path.as_os_str() == "-" {
        let mut buf = String::new();
        tokio::io::stdin()
            .read_to_string(&mut buf)
            .await
            .wrap_err("reading standard input")?;
        Ok(buf)
    } else {
        tokio::fs::read_to_string(path)
            .await
            .wrap_err_with(|| format!("reading {}", path.display()))
    }
}

/// `command-run` checks the exit status for us and returns an error if the
/// child failed, so there is no `status.success()` dance here.
fn git_rev() -> Result<String> {
    let mut cmd = Command::with_args("git", ["rev-parse", "--short", "HEAD"]);
    cmd.enable_capture();

    let output = cmd
        .run()
        .map_err(|err| eyre!("{err}"))
        .wrap_err("running git rev-parse")?;

    Ok(output.stdout_string_lossy().trim().to_owned())
}
