/**
 * Express Server — Health endpoint para demonstracao Docker.
 */

const express = require("express");
const os = require("os");

const app = express();
const PORT = process.env.PORT || 3000;
const START_TIME = Date.now();

app.get("/", (_req, res) => {
  res.json({
    service: "node-app",
    status: "running",
    hostname: os.hostname(),
  });
});

app.get("/health", (_req, res) => {
  const uptimeSeconds = ((Date.now() - START_TIME) / 1000).toFixed(2);
  res.json({
    status: "healthy",
    uptime_seconds: parseFloat(uptimeSeconds),
    version: process.env.APP_VERSION || "1.0.0",
    node_version: process.version,
  });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});
