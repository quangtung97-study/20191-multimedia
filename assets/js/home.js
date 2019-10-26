import { Elm } from "../src/Home.elm";
import "../css/home.css";
import { channel } from "./socket.js";

const home = Elm.Home.init({
  node: document.getElementById("root")
});


home.ports.sendMessage.subscribe(([name, data]) => {
  channel.push(name, data);
});


home.ports.subscribeOn.subscribe(name => {
  channel.on(name, data => {
    home.ports.recvMessage.send([name, data])
  });
});


let _connection = null;

const getConnection = () => {
  if (_connection) {
    return _connection;
  }
  else {
    const yours = document.getElementById("yours");
    const stream = yours.srcObject;

    const config = {
      "iceServers": [
        {url: 'stun:192.168.1.174:3478'},
        {url: 'stun:stun.ekiga.net'},
        {url: 'stun:stun.fwdnet.net'},
        {url: 'stun:stun.ideasip.com'},
        {url: 'stun:stun.iptel.org'},
        {url: 'stun:stun.rixtelecom.se'},
        {url: 'stun:stun.schlund.de'}
      ]
    };

    _connection = new RTCPeerConnection(config);

    stream.getTracks().forEach(track => _connection.addTrack(track, stream));

    _connection.ontrack = ({streams}) => {
      const theirs = document.getElementById("theirs");
      streams.forEach(stream => theirs.srcObject = stream);
    };

    _connection.onicecandidate = event => {
      if (event.candidate) {
        const candidate = event.candidate;
        console.log(candidate);
        home.ports.gotICE.send(candidate);
      }
    };

    return _connection;
  }
};

/*
const exchange = async function() {
  const offer = await yourConnection.createOffer();
  await yourConnection.setLocalDescription(offer);
  await theirConnection.setRemoteDescription(offer);
  const answer = await theirConnection.createAnswer();
  await theirConnection.setLocalDescription(answer);
  await yourConnection.setRemoteDescription(answer);
};
*/

home.ports.startRTC.subscribe(() => {
  getConnection().createOffer()
    .then(offer => {
      console.log(offer);
      getConnection().setLocalDescription(offer)
        .then(() => {
          home.ports.gotOffer.send(offer);
        });
    });
});

home.ports.gotRemoteOffer.subscribe(offer => {
  console.log("OFFER", offer);
  getConnection().setRemoteDescription(offer);

  getConnection().createAnswer()
    .then(answer => {
      getConnection().setLocalDescription(answer)
        .then(() => {
          console.log("BEFORE GOT ANSWER");
          home.ports.gotAnswer.send(answer);
        });
    });
});

home.ports.gotRemoteAnswer.subscribe(answer => {
  console.log("ANSWER", answer);
  getConnection().setRemoteDescription(answer);
});

home.ports.gotRemoteICE.subscribe(ice => {
  console.log("ICE", ice);
  getConnection().addIceCandidate(new RTCIceCandidate(ice));
});

home.ports.initUserMedia.subscribe(() => {
  const constraints = {
      video: true,
      audio: false
  };

  navigator.mediaDevices.getUserMedia(constraints)
    .then(stream => {
      const yours = document.getElementById("yours");
      yours.srcObject = stream;
    });
});

