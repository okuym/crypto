library(rvest)
library(dplyr)

#' Historical table scraper
#'
#' This web scrapes the historic price tables from CoinMarketCap
#' and provides back a dataframe for the coin provided as an input.
#'
#' @param attributes URL generated from \code{listCoins()}
#' @param slug Unique indentifier required for merging
#'
#' @return Raw OHLC market data in a dataframe:
#'   \item{slug}{Coin url slug}
#'   \item{symbol}{Coin symbol}
#'   \item{name}{Coin name}
#'   \item{date}{Market date}
#'   \item{open}{Market open}
#'   \item{high}{Market high}
#'   \item{low}{Market low}
#'   \item{close}{Market close}
#'   \item{volume}{Volume 24 hours}
#'   \item{market}{USD Market cap}
#'
scraper <- function(attributes, slug) {
  . <- "."
  history_url <- as.character(attributes)
  coin_slug <- as.character(slug)
  cpage <-
    xml2::read_html(history_url,
                    handle = curl::new_handle("useragent" = "Mozilla/5.0"))
  cnames <-
    cpage %>% rvest::html_nodes(css = ".col-sm-4 .text-large") %>% rvest::html_text(trim = TRUE) %>% replace(!nzchar(.), NA)
  cnodes <-
    cpage %>% rvest::html_nodes(css = "table") %>% .[1] %>% rvest::html_table(fill = TRUE) %>%
    replace(!nzchar(.), NA)
  scraper <- data.frame(cnodes = cnodes)
  scraper <- Reduce(rbind, cnodes)
  scraper$symbol <- gsub("\\(||\\n|\\)", "", toupper(cnames))
  scraper$symbol <-
    as.character(strsplit(scraper$symbol, " ")[[1]][1])
  scraper$slug <- as.character(coin_slug)
  return(scraper)
}