import { Elm } from "../src/Home.elm";
import "../css/home.css";
import { channel } from "./socket.js";

const home = Elm.Home.init({
  node: document.getElementById("root")
});

const sendMessage = ([name, data]) => {
  channel.push(name, data);
};

const subscribeOn = name => {
  channel.on(name, data => {
    home.ports.recvMessage.send([name, data])
  });
};


let yourStream = null;
const theirConnections = {};

const newConnection = (theirsId) => {
  if (theirsId in theirConnections) {
    return theirConnections[theirsId];
  }
  else {
    const yours = document.getElementById("yours");
    const stream = yours.srcObject;

    const config = {
      "iceServers": [
        // {url: 'stun:192.168.1.174:3478'},
        {url: 'stun:stun.ekiga.net'},
        {url: 'stun:stun.fwdnet.net'},
        {url: 'stun:stun.ideasip.com'},
        // {url: 'stun:stun.iptel.org'},
        // {url: 'stun:stun.rixtelecom.se'},
        // {url: 'stun:stun.schlund.de'}
      ]
    };

    const connection = new RTCPeerConnection(config);
    theirConnections[theirsId] = connection;

    stream.getTracks().forEach(track => {
      connection.addTrack(track, stream);
    });

    connection.ontrack = ({streams}) => {
      const theirs = document.getElementById("theirs:" + theirsId);
      console.log(theirs);
      streams.forEach(stream => theirs.srcObject = stream);
    };

    connection.onicecandidate = event => {
      if (event.candidate) {
        const candidate = event.candidate;
        console.log(candidate);
        home.ports.gotICE.send({
          sessionId: theirsId,
          data: candidate
        });
      }
    };

    return connection;
  }
};

const startRTC = (theirsId) => {
  requestAnimationFrame(() => {
    console.log("startRTC", theirsId);
    newConnection(theirsId);

    const connection = theirConnections[theirsId];

    connection.createOffer()
      .then(offer => {
        console.log("OFFER", offer);
        connection.setLocalDescription(offer)
          .then(() => {
            home.ports.gotOffer.send({
              sessionId: theirsId,
              data: offer
            });
          });
      });
  });
};

const startPassiveRTC = (theirsId) => {
  requestAnimationFrame(() => {
    console.log("startPassiveRTC", theirsId);
    newConnection(theirsId);
  });
};

const gotRemoteOffer = data => {
  console.log("OFFER", data);

  const theirsId = data.sessionId;
  const offer = data.offer;

  const connection = theirConnections[theirsId];

  connection.setRemoteDescription(offer)
    .then(() => {
      connection.createAnswer()
        .then(answer => {
          connection.setLocalDescription(answer)
            .then(() => {
              console.log("BEFORE GOT ANSWER");
              home.ports.gotAnswer.send({
                sessionId: theirsId,
                data: answer
              });
            });
        });
    });
};

const gotRemoteAnswer = data => {
  console.log("ANSWER", data);

  const theirsId = data.sessionId;
  const answer = data.answer;

  console.log(theirConnections);

  const connection = theirConnections[theirsId];
  connection.setRemoteDescription(answer);
};


const gotRemoteICE = data => {
  console.log("ICE", data);

  const theirsId = data.sessionId;
  const ice = data.ice;

  const connection = theirConnections[theirsId];
  connection.addIceCandidate(new RTCIceCandidate(ice));
};


const requestMedia = () => {
  const constraints = {
      video: true,
      audio: true
  };

  navigator.mediaDevices.getUserMedia(constraints)
    .then(stream => {
      yourStream = stream;
      home.ports.mediaReady.send();
    })
    .catch(error => {
      home.ports.mediaFailed.send([error.name, error.message]);
    });
};

const setUpYourStream = () => {
  requestAnimationFrame(() => {
    const yours = document.getElementById("yours");
    yours.srcObject = yourStream;
  });
};

home.ports.sendMessage.subscribe(sendMessage);
home.ports.subscribeOn.subscribe(subscribeOn);

home.ports.requestMedia.subscribe(requestMedia);

home.ports.setUpYourStream.subscribe(setUpYourStream);
home.ports.startRTC.subscribe(startRTC);
home.ports.startPassiveRTC.subscribe(startPassiveRTC);
home.ports.gotRemoteOffer.subscribe(gotRemoteOffer);
home.ports.gotRemoteAnswer.subscribe(gotRemoteAnswer);
home.ports.gotRemoteICE.subscribe(gotRemoteICE);
