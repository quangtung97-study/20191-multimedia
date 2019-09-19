import css from "../css/app.css"
import "phoenix_html"
// import socket from "./socket"
import {Socket} from "phoenix";
import LiveSocket from "phoenix_live_view";

const liveSocket = new LiveSocket("/live", Socket);
liveSocket.connect();
