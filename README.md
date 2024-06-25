# Mylar
Mylar is an automated Comic Book (cbr/cbz) downloader program for use with NZB and torrents.

Mylar allows you to create a watchlist of series that it monitors for various things (new issues, updated information, etc). It will grab, sort, and rename downloaded issues. It will also allow you to monitor weekly pull-lists for items belonging to said watchlisted series to download, as well as being able to monitor and maintain story-arcs.

Docker
-----------------------------------------------
This repo will periodically check mylar3 for updates and build a container image from scratch using an Alpine base layout:

```
docker pull ghcr.io/elegant996/mylar3:0.8.0
```