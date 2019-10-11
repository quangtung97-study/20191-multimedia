import "regenerator-runtime/runtime";
import "../css/home.css"
import * as React from "react";
import { useEffect } from "react";
import { render } from "react-dom";
import { createStore, applyMiddleware } from "redux";
import { Provider, connect } from "react-redux";
import createSagaMiddleware from "redux-saga";
import { composeWithDevTools } from "redux-devtools-extension";
import { delay, put, takeEvery, all } from "redux-saga/effects";

const root = document.getElementById("root");

type State = number;
type Action = { type: string };

interface HelloProps {
  counter: number;
  incrementAsync: () => void;
  decrementAsync: () => void;
};

const HelloWorld = (props: HelloProps) => {
  return (
    <div>
      <h2>TUNG QUANG</h2>
      <h3>{props.counter}</h3>
      <button onClick={props.incrementAsync} >INCREASE</button>
      <button onClick={props.decrementAsync} >DECREASE</button>
    </div>
  );
};

const mapStateToProps = (counter: State) => ({ counter });
const mapDispatchToProps = (dispatch: any) => ({
  incrementAsync: () => dispatch({ type: "INCREMENT_ASYNC" }),
  decrementAsync: () => dispatch({ type: "DECREMENT_ASYNC" })
});

const Hello = connect(mapStateToProps, mapDispatchToProps)(HelloWorld);

const rootReducer = (counter: State = 0, action: Action): State => {
  switch (action.type) {
    case "INCREMENT":
      return counter + 1;
    case "DECRMENT":
      return counter - 1;
    default:
      return counter;
  }
};

const sagaMiddleware = createSagaMiddleware();
const store = createStore(
  rootReducer,
  composeWithDevTools(
    applyMiddleware(sagaMiddleware)
  )
);

function *incrementAsync() {
  yield delay(1000);
  yield put({ type: "INCREMENT" });
}

function *decrementAsync() {
  yield delay(1000);
  yield put({ type: "DECRMENT" });
}

function *watchCounterAsync() {
  yield takeEvery("INCREMENT_ASYNC", incrementAsync);
  yield takeEvery("DECREMENT_ASYNC", decrementAsync);
}

function *rootSaga() {
  yield all([
    watchCounterAsync()
  ])
}

sagaMiddleware.run(rootSaga);

const startConnection = (stream) => {
  const config = {
  };

  const yourConnection = new RTCPeerConnection(config);
  const theirConnection = new RTCPeerConnection(config);

  stream.getTracks().forEach((track: any) => yourConnection.addTrack(track, stream));

  theirConnection.ontrack = ({streams: [stream]}) => {
    const theirs: any = document.getElementById("theirs");
    theirs.srcObject = stream;
  };

  yourConnection.onicecandidate = event => {
    if (event.candidate) {
      console.log(event.candidate);
      theirConnection.addIceCandidate(new RTCIceCandidate(event.candidate));
    }
  };

  theirConnection.onicecandidate = event => {
    if (event.candidate) {
      yourConnection.addIceCandidate(new RTCIceCandidate(event.candidate));
    }
  };

  const exchange = async function() {
    const offer = await yourConnection.createOffer();
    await yourConnection.setLocalDescription(offer);
    await theirConnection.setRemoteDescription(offer);
    const answer = await theirConnection.createAnswer();
    await theirConnection.setLocalDescription(answer);
    await yourConnection.setRemoteDescription(answer);
  };

  exchange();
};

const Video = () => {
  useEffect(() => {
    navigator.getUserMedia(
      {
        video: true,
        audio: false
      },
      stream => {
        const yours: any = document.getElementById("yours");
        yours.srcObject = stream;
        startConnection(stream);
      },
      error => {
        console.log(error);
      }
    );
  });

  return (
    <div>
      <video id="yours" className="video" autoPlay></video>
      <video id="theirs" className="video" autoPlay></video>
    </div>
  );
};

if (root)
  render(
    <Provider store={store}>
      <Hello />
      <Video />
    </Provider>,
    root);
