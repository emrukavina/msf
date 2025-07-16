use clap::Parser;

#[derive(Parser, Debug, Clone)]
#[clap(version, about = "An available film site finder.")]
pub struct Options {
    /// Port to run the server on
    #[clap(short = 'p', long, required = true)]
    pub port: u16,

    /// Enable debug logging
    #[clap(short = 'd', long, default_value_t = false)]
    pub enable_debug: bool,
}