import { Socket } from "phoenix";

let socket = new Socket("/socket", {params: {token: (<any>window).userToken}});

socket.connect();

let channel = socket.channel("session:" + (<any>window).sessionId, {});
channel.join()
  .receive("ok", (resp: Object) => { console.log("Joined successfully", resp) })
  .receive("error", (resp: Object) => { console.log("Unable to join", resp) })

export default socket
