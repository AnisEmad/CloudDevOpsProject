const express = require("express");
const session = require("express-session");
const axios = require("axios");
const path = require("path");

const app = express();
const PORT = 3000;
const AUTH_SERVICE_URL = process.env.AUTH_SERVICE_URL || "http://localhost:5000";
const ROADMAP_SERVICE_URL = process.env.ROADMAP_SERVICE_URL || "http://localhost:8080";

app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));

app.use(
  session({
    secret: process.env.SESSION_SECRET || "change-me-in-k8s",
    resave: false,
    saveUninitialized: false,
    cookie: { httpOnly: true, maxAge: 60 * 60 * 1000 }
  })
);

function renderDbError(res) {
  return res.status(503).render("error", {
    title: "MySQL Connection Error",
    message: "There is an issue connecting to the MySQL database. Please check the database configuration and try again."
  });
}

app.get("/", (req, res) => {
  if (req.session.user) return res.redirect("/roadmap");
  res.render("auth", { error: null, mode: "login" });
});

app.get("/signup", (req, res) => {
  res.render("auth", { error: null, mode: "signup" });
});

app.post("/signup", async (req, res) => {
  try {
    await axios.post(`${AUTH_SERVICE_URL}/api/auth/signup`, {
      username: req.body.username,
      password: req.body.password
    });
    res.redirect("/");
  } catch (err) {
    if (err.response?.status === 503) return renderDbError(res);
    const message = err.response?.data?.message || "Signup failed.";
    res.status(400).render("auth", { error: message, mode: "signup" });
  }
});

app.post("/login", async (req, res) => {
  try {
    const response = await axios.post(`${AUTH_SERVICE_URL}/api/auth/login`, {
      username: req.body.username,
      password: req.body.password
    });
    req.session.user = response.data.user;
    res.redirect("/roadmap");
  } catch (err) {
    if (err.response?.status === 503) return renderDbError(res);
    const message = err.response?.data?.message || "Login failed.";
    res.status(401).render("auth", { error: message, mode: "login" });
  }
});

app.get("/roadmap", async (req, res) => {
  if (!req.session.user) return res.redirect("/");

  try {
    const response = await axios.get(`${ROADMAP_SERVICE_URL}/api/roadmap`);
    res.render("roadmap", {
      user: req.session.user,
      roadmap: response.data
    });
  } catch (err) {
    if (err.response?.status === 503) return renderDbError(res);
    res.status(500).render("error", {
      title: "Application Error",
      message: "The roadmap service is unavailable."
    });
  }
});

app.post("/logout", (req, res) => {
  req.session.destroy(() => res.redirect("/"));
});

app.listen(PORT, () => {
  console.log(`Frontend listening on port ${PORT}`);
});
