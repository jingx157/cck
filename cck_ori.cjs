// server.cjs
const http = require("http");
const url = require("url");
// http://cachuake.com/Api/services.ashx
const HOST_HEADER = "cachuake.com";
const RESPONSE = "lh+nbIWfeoO7wEtBplUDyMGwDJ6vFWEXgvpCDsOcYPyboWXIIt/WdyrNNdN+MHRC1JxcEzykrxqqCoBstwEllpWF/mcm8LgYQcCpuIgueOVW+mAuJ7YuLnIIW0I57o28jYmEjauTstxabkIrmCm/uGTGxNopBy8lKJ/jhlwa2lDYz6WPRRiOdpZoxmIpt1AVQxrJeZcnPPAW7W6gEPS6DCnghSZMXRpwzcexsPo5w";

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
      res.end(RESPONSE);
    } else {
      res.writeHead(403, { "Content-Type": "text/plain; charset=utf-8" });
      res.end("blocked");
    }
  })
  .listen(80, "127.0.0.3", () => {
    console.log("Listening on 127.0.0.3:80");
  });
