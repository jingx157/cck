// server.cjs
const http = require("http");
const url = require("url");

const HOST_HEADER = "cck.toolpe.com";
const RESPONSE =
  "expired=false&date=lifetime&devices=100&yandex=active&myOption=";
const code = "SR-B81FB8E214B42BC11329C6F6C7D41E6E";

http
  .createServer((req, res) => {
    const { query } = url.parse(req.url, true);

    if (
      (req.headers.host || "").toLowerCase() === HOST_HEADER &&
      query.key === code
    ) {
      res.writeHead(200, {
        "Content-Type": "text/plain; charset=utf-8",
        "Cache-Control": "no-store",
      });
      res.end(RESPONSE);
    } else {
      res.writeHead(403, { "Content-Type": "text/plain; charset=utf-8" });
      res.end("blocked");
    }
  })
  .listen(80, "127.0.0.4", () => {
    console.log("Listening on 127.0.0.4:80");
  });
