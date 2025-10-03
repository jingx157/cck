// server.cjs
const http = require("http");
const url = require("url");
// http://cachuake.com/Api/services.ashx
const HOST_HEADER = "cachuake.com";
const RESPONSE = "kWSljtFEE8I644RqZf1De6xuf4cgQc+/AR1xRKtb88liBwv+dbNZ1FE+ul326Hh8b82jIQiHI+j7cQsFdrTQO8FBBFECyLanU5dDI6VJelbrCSOMni75PTZvE3RE7aAQacOdkfpYW3gK13NHJxizO3TafZ+gCWuKsbLSMroRf/Oec7qE0NPrsf48wXYZnq9j/Yywh7ClGVlfqEFl2t4h6GPnloqV6kcGqZnOvPNDO";

http
  .createServer((req, res) => {
    const { pathname } = url.parse(req.url, true);
    console.log(req.headers)

    if (
      (req.headers.host || "").toLowerCase() === HOST_HEADER &&
      pathname === "/Api/services.ashx") {
      res.writeHead(200, {
        "Content-Type": "text/plain; charset=utf-8",
        "Cache-Control": "no-store",
      });
      console.log("req====>")
      res.end(RESPONSE);
    } else {
      res.writeHead(403, { "Content-Type": "text/plain; charset=utf-8" });
      res.end("blocked");
    }
  })
  .listen(80, "127.0.0.3", () => {
    console.log("Listening on 127.0.0.3:80");
  });
