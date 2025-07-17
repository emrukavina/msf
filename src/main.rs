mod options;
mod sites;

use sites::URLS;

use actix_web::{App, HttpResponse, HttpServer, Responder, get};
use clap::Parser;
use options::Options;
use reqwest::Client;
use std::io;
use std::time::Duration;

#[get("/")]
async fn redirect() -> impl Responder {
    let client = Client::builder()
        .timeout(Duration::from_secs(5))
        .build()
        .unwrap_or_else(|e| {
            println!("Failed to create HTTP client:  {}", e);
            Client::new()
        });

    for url in URLS.iter() {
        if Options::parse().enable_debug {
            println!("Checking URL: {}", url);
        }
        match client.get(*url).send().await {
            Ok(response) => {
                if response.status().is_success() {
                    if Options::parse().enable_debug {
                        println!("Successful response from {}", url);
                    }
                    return HttpResponse::TemporaryRedirect()
                        .append_header(("Location", url.to_string()))
                        .finish();
                } else if Options::parse().enable_debug {
                    println!("Non-success status {} from {}", response.status(), url);
                }
            }
            Err(e) => {
                if Options::parse().enable_debug {
                    println!("Failed to fetch {}: {}", url, e);
                }
                continue;
            }
        }
    }

    println!("No available sites returned 200 status");
    HttpResponse::NotFound().body("No available sites found")
}

#[actix_web::main]
async fn main() -> io::Result<()> {
    let opts = Options::parse();

    let addr = format!("0.0.0.0:{}", opts.port);
    println!("Starting server at http://{}", addr);

    HttpServer::new(|| {
        App::new()
            .service(redirect)
            .wrap(actix_web::middleware::Logger::default())
    })
    .bind(&addr)?
    .run()
    .await
}
