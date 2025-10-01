// server.cjs
const http = require("http");
const url = require("url");

function formatDate(ts) {
  const d = new Date(ts);
  const yyyy = d.getUTCFullYear();
  const mm = String(d.getUTCMonth() + 1).padStart(2, "0");
  const dd = String(d.getUTCDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}

const HOST_HEADER = "cck.toolpe.com";
const CODE = "SR-EDA58412F718E5C5D0AB5B9D31EA84EF";
const isLifeTime = false;
const isHideDate = true;
const RESPONSE =
  "expired=false&date=lifetime&devices=100&yandex=active&myOption=";


// Set expiration (UTC). Change this to the date you want the license to expire.
const EXPIRES_AT = isLifeTime ? 2553490556000 : 1764572156000;

// Response template (we'll inject actual date for clarity)
function makeResponse(isExpired) {
  return `expired=${isExpired ? "true" : "false"}&expires=${formatDate(EXPIRES_AT)}&devices=100&yandex=active&myOption=`;
}

http
  .createServer((req, res) => {
    const { query } = url.parse(req.url, true);
    const now = Date.now();

    console.log(now)

    // Host match and code match
    const hostOk = (req.headers.host || "").toLowerCase() === HOST_HEADER;
    const keyOk = (query.key || "").toUpperCase() === CODE;

    // Expiration check
    const isExpired = now > EXPIRES_AT;

    if (!hostOk || !keyOk || isExpired) {
      // Wrong host or key -> blocked
      res.writeHead(403, { "Content-Type": "text/plain; charset=utf-8" });
      res.end("blocked");
      return;
    }


    // All checks passed -> return valid license body (not cached)
    res.writeHead(200, {
      "Content-Type": "text/plain; charset=utf-8",
      "Cache-Control": "no-store",
    });
    res.end(isHideDate ? RESPONSE : makeResponse(false, now));
  })
  .listen(80, "127.0.0.4", () => {
    console.log("Fake License Server → http://127.0.0.4:80");
  });


