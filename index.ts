const server = Bun.serve({
  port: process.env.PORT || 8080,
  routes: {
    "/": (req) => {
      return new Response(JSON.stringify({ message: "Hello via Bun!" }), {
        headers: { "Content-Type": "application/json" },
      });
    },
    "/health": (req) => {
      return new Response(JSON.stringify({ status: "ok" }), {
        headers: { "Content-Type": "application/json" },
      });
    },
  },
});

console.log(`Server running at http://localhost:${server.port}`);

// Print hello world and current time every 5 seconds
setInterval(() => {
  const now = new Date().toISOString();
  console.log("hello world", now);
}, 5000);

console.log("hello world", new Date().toISOString());